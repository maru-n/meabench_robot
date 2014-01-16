/* robot/robot.C: meabench module for experiment with real robot
*/
// robot.C

// This vsn needs to be aware of the `type' of any stream it records from.
// That need not be the case, but I haven't implemented the cleverness yet.

#include <base/Cmdr.H>
#include <base/Error.H>
#include <rawsrv/Defs.H>
#include <spikesrv/Defs.H>
#include <base/Sprintf.H>
#include <base/Sigint.H>
#include <base/Linebuf.H>
#include <common/AutoType.H>
#include <common/ChannelNrs.H>
#include <common/directory.H>
#include <common/CMOSServerTools.H>

#if CMDGUI
#else
#include <common/MEAB.H>
#endif

//#include "StreamRec.H"
#include "RobotServer.H"
#include "SourceSet.H"
#include "StimSrv.h"

#include <string>
#include <unistd.h>

#define PROGNAME "robot"

const int RECIVAL = 4096;
SourceSet sources;
bool describe = true;
string comments = "";
bool rerec_ok = false;
bool rerec_safe = false;
bool rerec_trig = false;
timeref_t rerec_pre = 0;
timeref_t rerec_post = 0;
string rerec_fn = "";
int limit_s = 0;
int ntk_sock = 0;   // db Filedescriptor used for starting/stopping record of ntk commands
int ntk_rec  = 0;  // db State of ntk recording
int slot;           // db use for threaded server, slot to record ntk commands

/*
void enabledesc(int argc=0, char **args=0) {
  if (argc) {
    int n = atoi(args[0]);
    if (n==0)
      describe=false;
    else if (n==1)
      describe=true;
    else
      throw Error("describe","Argument must be 0 or 1 to disable or enable description file");
  }
  fprintf(stderr,"Description file generation is %sabled",describe?"en":"dis");
}

void setlimit(int argc=0, char **args=0) {
  if (argc) {
    if (strcmp(args[0],"-")==0)
      limit_s = 0;
    else
      limit_s = atoi(args[0]);
  }
  if (limit_s)
    fprintf(stderr,"Recording time limit: %i s\n",limit_s);
  else
    fprintf(stderr,"No predetermined time limit\n");
}

*/
void rec_source(int argc = 0, char **args = 0)
{
    if (argc)
    {
        rerec_ok = false;
        sources.reset();
        for (int i = 0; i < argc; i++)
        {
            string sname = args[i];
            string::size_type slash = sname.find('/');
            if (slash == string::npos)
                // no explicit type
                sources.add(sname);
            else
                // explicit type
                sources.add(sname.substr(0, slash), sname.substr(slash + 1));
        }
    }
    fprintf(stderr, "Sources are:\n");
    for (SourceSet::const_iterator i = sources.begin(); i != sources.end(); ++i)
        fprintf(stderr, "  %s [%s]\n", (*i).stream.c_str(), (*i).type.c_str());
}

void dorec(string fn, bool date,
           bool trig = false, timeref_t pretrig = 0, timeref_t posttrig = 0,
           bool evenifexists = false)
{
  evenifexists = true;

    //rec_source();
    if (date)
    {
        char dt[8];
        time_t t = time(0);
        strftime(dt, 8, "%H%M%S", localtime(&t));
        fn += "-"; fn += dt;
    }

    rerec_fn = fn;
    rerec_trig = trig;
    rerec_pre = pretrig;
    rerec_post = posttrig;
    rerec_ok = true;
    rerec_safe = true;

    sdbx("(start of rec) rerec_fn now set to: %s. ok=%c safe=%c", rerec_fn.c_str(),
         rerec_ok ? 'y' : 'n', rerec_safe ? 'y' : 'n');

    vector<RobotServer *> srec;

    bool usestream = sources.needsstream();

    for (SourceSet::iterator i = sources.begin(); i != sources.end(); ++i)
    {
        try
        {
            RobotServer *sr = 0;
            if (trig)
                sr = new RobotServer((*i).stream, (*i).type, pretrig, posttrig,
                                   fn, describe, usestream, evenifexists);
            else
                sr = new RobotServer((*i).stream, (*i).type,
                                   fn, describe, usestream, evenifexists);
            sr->setcomments(comments);
            srec.push_back(sr);
        }
        catch (Error const &e)
        {
            e.report();
        }
    }
    if (!srec.size())
        throw Error("Record", "No working streams");

    for (vector<RobotServer *>::iterator i = srec.begin(); i != srec.end(); ++i)
        try
        {
            sdbx("Starting %s", (*i)->name().c_str());
            (*i)->run(limit_s);
        }
        catch (Error const &e)
        {
            e.report();
        }

    for (vector<RobotServer *>::iterator i = srec.begin(); i != srec.end(); ++i)
        try
        {
            sdbx("Waiting for %s to finish", (*i)->name().c_str());
            if ((*i)->wait() == RobotServer::SOURCE_END)
                rerec_safe = false;
        }
        catch (Error const &e)
        {
            e.report();
        }

    for (vector<RobotServer *>::iterator i = srec.begin(); i != srec.end(); ++i)
        try
        {
            sdbx("Deleting %s", (*i)->name().c_str());
            delete *i;
        }
        catch (Error const &e)
        {
            e.report();
        }
    sdbx("(end of rec) rerec_fn now set to: %s. ok=%c safe=%c", rerec_fn.c_str(),
         rerec_ok ? 'y' : 'n', rerec_safe ? 'y' : 'n');

}

void setcomments(int argc, char **args)
{
    comments = "";
    while (argc)
    {
        comments += *args;
        --argc; ++args;
        if (args)
            comments += " ";
    }
}

void run(int argc, char **args)
{
    printf("Now developing!\n");
    dorec("filename", false);
}

void test_stimulus(int argc, char **args)
{
    printf("Stimulus test for DAC#0, Channel#3");
    StimSrv stimSrv;
    stimSrv.setup();
    stimSrv.sendStim(0,3);
}

#if CMDGUI
// instead the main_function() in the CmdGui software, mearaw.cpp, is used
#else
struct Cmdr::Cmap cmds[] =
{
    { Cmdr::quit, "quit", 0, 0, "", },
    { run, "run", 0, 0, "", },
    { test_stimulus, "teststim", 0, 0, "", },
    { rec_source, "source", 0, 200, "[name[/type] ...]", },
    { cd, "cd", 0, 1, "[directory]", },
    { ls, "ls", 0, 100, "[ls args]", },
    { mkdir, "mkdir", 1, 100, "mkdir args", },
    //  { enabledesc, "describe", 0, 1, "[0/1]", },
    //  { setlimit, "limit", 0, 1, "[-/time_s]", },
    //  { setdbx, "dbx", 0, 1, "[0/1]", },
    0,
};

int main(int argc, char **argv)
{
    MEAB::announce(PROGNAME);
    Sigint sigi;
    cd();
    sources.add("spike");
    try
    {
        Cmdr::enable_shell();
        if (!Cmdr::exec(argc, argv, cmds))
        {
            Linebuf input;
            Cmdr::loop(PROGNAME, cmds, &input);
        }
    }
    catch (Error const &e)
    {
        e.report();
        exit(1);
    }
    return 0;
}
#endif
