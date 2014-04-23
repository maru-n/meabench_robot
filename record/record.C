/* record/record.C: part of meabench, an MEA recording and analysis tool
** Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

// record.C

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

#include "StreamRec.H"
#include "SourceSet.H"

#include <string>
#include <unistd.h>

#define PROGNAME "record"

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


void rec_source(int argc=0, char **args=0) {
  if (argc) {
    rerec_ok = false;
    sources.reset();
    for (int i=0; i<argc; i++) {
      string sname = args[i];
      string::size_type slash = sname.find('/');
      if (slash==string::npos) 
	// no explicit type
	sources.add(sname);
      else
	// explicit type
	sources.add(sname.substr(0,slash),sname.substr(slash+1));
    }
  }
  fprintf(stderr,"Sources are:\n");
  for (SourceSet::const_iterator i=sources.begin(); i!=sources.end(); ++i)
    fprintf(stderr,"  %s [%s]\n",(*i).stream.c_str(),(*i).type.c_str());
}


void dorec(string fn, bool date, 
	   bool trig=false, timeref_t pretrig=0, timeref_t posttrig=0,
	   bool evenifexists = false) {

  rec_source();
  if (date) {
    char dt[8];
    time_t t = time(0);
    strftime(dt,8,"%H%M%S",localtime(&t));
    fn += "-"; fn += dt;
  }

  rerec_fn = fn;
  rerec_trig = trig;
  rerec_pre = pretrig;
  rerec_post = posttrig;
  rerec_ok = true;
  rerec_safe = true;

  sdbx("(start of rec) rerec_fn now set to: %s. ok=%c safe=%c",rerec_fn.c_str(),
       rerec_ok?'y':'n',rerec_safe?'y':'n');

  vector<StreamRec *> srec;

  bool usestream = sources.needsstream();
  
  for (SourceSet::iterator i=sources.begin(); i!=sources.end(); ++i) {
    try {
      StreamRec *sr=0;
      if (trig)
	sr = new StreamRec((*i).stream,(*i).type, pretrig,posttrig,
			   fn, describe, usestream, evenifexists);
      else
	sr = new StreamRec((*i).stream,(*i).type,
			   fn, describe, usestream, evenifexists);
      sr->setcomments(comments);
      srec.push_back(sr);
    } catch (Error const &e) {
      e.report();
    }
  }
  if (!srec.size())
    throw Error("Record","No working streams");
  
  for (vector<StreamRec *>::iterator i=srec.begin(); i!=srec.end(); ++i)
    try {
      sdbx("Starting %s",(*i)->name().c_str());
      (*i)->run(limit_s);
    } catch (Error const &e) {
      e.report();
    }

  for (vector<StreamRec *>::iterator i=srec.begin(); i!=srec.end(); ++i)
    try {
      sdbx("Waiting for %s to finish",(*i)->name().c_str());
      if ((*i)->wait() == StreamRec::SOURCE_END)
	rerec_safe = false;
    } catch (Error const &e) {
      e.report();
    }

  for (vector<StreamRec *>::iterator i=srec.begin(); i!=srec.end(); ++i)
    try {
      sdbx("Deleting %s",(*i)->name().c_str());
      delete *i;
    } catch (Error const &e) {
      e.report();
    }
  sdbx("(end of rec) rerec_fn now set to: %s. ok=%c safe=%c",rerec_fn.c_str(),
       rerec_ok?'y':'n',rerec_safe?'y':'n');
 
}

void setcomments(int argc, char **args) {
  comments = "";
  while (argc) {
    comments+=*args;
    --argc; ++args;
    if (args)
      comments+=" ";
  }
}

void rerecord(int argc, char **args) {
  if (rerec_ok) {
    if (rerec_safe || argc) {
      if (rerec_trig) 
	dorec(rerec_fn,false, true, rerec_pre,rerec_post, true);
      else
	dorec(rerec_fn,false, false, 0,0, true);
    } else {
      throw Expectable("rerecord",
		       "Previous recording completed OK, won't re-record. Use 'rerecord force' to override.");
    }
  } else {
    throw Expectable("rerecord","Re-record not possible at this time. Use 'record' or 'trecord'.");
  }
}

void trecord(int argc, char **args) {
  setcomments(argc-3,args+3);
  dorec(args[0],false,true,atoi(args[1])*FREQKHZ,atoi(args[2])*FREQKHZ);
}

void record(int argc, char **args) {
  setcomments(argc-1,args+1);
  dorec(args[0],false);
}

void ntkstop(int sock){
      fprintf(stderr,"End recording ntk stream on the server (slot %i).\n",slot);
      save_stop_ntk_commands(sock); 	// db //
      close_server(sock); 		// db //
      ntk_rec=0;    // reset
}
void ntkrecord(int argc, char **args) {
  if(!argc){
        fprintf(stderr,"Usage:\tntkrecord 0 time_s [ stop recording raw ntk data in the server]\n");
        fprintf(stderr,"\tntkrecord 1 time_s [start recording raw ntk data in the server]\n");
        fprintf(stderr,"\tntkrecord 2 time_s [start recording command-only ntk data in the server]\n");
        return;
  }
  if(ntk_rec>0 && atoi(args[0])!=0){
        fprintf(stderr,"The server is already recording. Use 'ntkrecord 0' to stop. (ntkrecord=%i)\n",ntk_rec);
        return;
  }
  if(ntk_rec==0 && atoi(args[0])==0){
        fprintf(stderr,"The server is already not recording.\n");
        return;
  }
  int time_rec=0;
  if(args[1])
      time_rec=atoi(args[1]);


  //fprintf(stderr,"flagA   ntkrec::%i  args::%i\n",ntk_rec, atoi(args[0]));
        
  // need to get slot -- hacked dorec to create stream in order to be able to access the slot information
  rec_source();
  vector<StreamRec *> srec;
  bool usestream = sources.needsstream();
  for (SourceSet::iterator i=sources.begin(); i!=sources.end(); ++i) {
    try {
      StreamRec *sr=0;
      //sr = new StreamRec((*i).stream,(*i).type, "meabench_ntkstream_tmp", 0, 0, 0);
      sr = new StreamRec((*i).stream,NTKTYPE, "/tmp/meabench_ntkstream_tmp", 0, 0, 0); // created new TYPE -- need to connect to raw to get access to slot. then can tell server to record on that slot.
      //sr->setcomments(comments);
      srec.push_back(sr);
      slot = sr->getslot();
    } catch (Error const &e) {
      e.report();
    }
  }
  if (!srec.size())
    throw Error("ntkrecord","No working streams");
  for (vector<StreamRec *>::iterator i=srec.begin(); i!=srec.end(); ++i)
    try {
      sdbx("Deleting %s",(*i)->name().c_str());
      delete *i;
    } catch (Error const &e) {
      e.report();
    }
  ///////

  ntk_rec=atoi(args[0]);
  if(ntk_rec==0)
      ntkstop(ntk_sock);
  else if(ntk_rec==1){
      fprintf(stderr,"Begin recording full ntk stream on the server (slot %i)",slot);
      ntk_sock = connect_server(SERVER_ADDR,SERVER_PORT);
      send_client_name(ntk_sock,"ntkrecord");
      save_start_ntk_commands(ntk_sock, slot, 1); // db //////////////////////////
      if(time_rec){
          fprintf(stderr," for %i seconds.\n",time_rec);
          sleep(time_rec);
          ntkstop(ntk_sock);
      }else
          fprintf(stderr,".\n");
  }
  else if(ntk_rec==2){
      fprintf(stderr,"Begin recording command-only ntk stream on the server (slot %i)",slot);
      ntk_sock = connect_server(SERVER_ADDR,SERVER_PORT);
      send_client_name(ntk_sock,"ntkrecord");
      save_start_ntk_commands(ntk_sock, slot, 0); // db //////////////////////////
      if(time_rec){
          fprintf(stderr," for %i seconds.\n",time_rec);
          sleep(time_rec);
          ntkstop(ntk_sock);
      }else
          fprintf(stderr,".\n");
  }
  else{
      fprintf(stderr,"Usage:\tntkrecord 0 time_s [ stop recording raw ntk data in the server]\n");
      fprintf(stderr,"\tntkrecord time_s 1 [start recording raw ntk data in the server]\n");
      fprintf(stderr,"\tntkrecord time_s 2 [start recording command-only ntk data in the server]\n");
      return;
  }
}


void multitrecord(int argc, char **args) {
  setcomments(argc-3,args+3);
  while (1) {
    dorec(args[0],true,true,atoi(args[1])*FREQKHZ,atoi(args[2])*FREQKHZ);
  }
}

void multirecord(int argc, char **args) {
  setcomments(argc-1,args+1);
  while (1) {
    dorec(args[0],true);
  }
}

#if CMDGUI
// instead the main_function() in the CmdGui software, mearaw.cpp, is used
#else
struct Cmdr::Cmap cmds[] = {
  { Cmdr::quit, "quit",0,0,"", },
  { record, "record", 1, 200, "filename [comments]", },
  { multirecord, "multirecord", 1,200, "base-filename [comments]", },
  { trecord, "trecord", 3, 200, "filename pretrig-ms posttrig-ms [comments]", },
  { multitrecord, "multitrecord", 3,200, "base-filename pretrig-ms posttrig-ms [comments]", },
  { rerecord, "rerecord", 0, 1, "[force]", },
  { ntkrecord, "ntkrecord", 0, 2, "[0(off)/1(full stream)/2(command-only)] [time_s]", },
  { rec_source, "source", 0,200, "[name[/type] ...]", },
  { cd, "cd", 0,1, "[directory]", },
  { ls, "ls", 0, 100, "[ls args]", },
  { mkdir, "mkdir", 1, 100, "mkdir args", },
  { enabledesc, "describe", 0, 1, "[0/1]", },
  { setlimit, "limit", 0, 1, "[-/time_s]", },
  { setdbx, "dbx", 0, 1, "[0/1]", },
  0,
};

int main(int argc, char **argv) {
  MEAB::announce(PROGNAME);
  Sigint sigi;
  cd();
  try {
    Cmdr::enable_shell();
    if (!Cmdr::exec(argc,argv,cmds)) {
      Linebuf input;
      Cmdr::loop(PROGNAME,cmds,&input);
    }
  } catch (Error const &e) {
    e.report();
    exit(1);
  }
  return 0;
}
#endif
