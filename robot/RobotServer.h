// RobotServer.H

#ifndef ROBOTSERVER_H

#define ROBOTSERVER_H

#include <base/Error.H>
#include <pthread.h>
#include <string>

#define NTKTYPE "ntk"

class RobotServer {
public:
  static const int RECIVAL = 4096;
  static const int BUFUSEREPORTIVAL_S = 10;
  enum TerminationCode {
    SOURCE_END = 0,
    INTERRUPT,
    INCOMPLETE,
    TRANSMISSIONERROR,
    NOTRUNNING,
    TIME_LIMIT
  };
public:
  RobotServer(string const &stream, string const &type,
	    string const &basefn,
	    bool describe, bool usestream,
	    bool evenifexists=false) throw(Error);
  RobotServer(string const &stream, string const &type,
	    int pretrig, int posttrig,
	    string const &basefn,
	    bool describe, bool usestream,
	    bool evenifexists=false) throw(Error);
  ~RobotServer();
  void setcomments(string const &c) { comments=c; }
  int  getslot() { return slot; }
  void run(int limit_s=0) throw(Error);
  TerminationCode wait() throw(Error); //:f wait
  /*:R termination code, see enum.
   *:E Exc thrown only if thread fails.
  */
  string const &name() const { return filename; }
private:
  void construct(string const &stream, string const &type,
		 string const &basefn,
		 bool describe, bool usestream,
		 bool evenifexists=false) throw(Error);
  void exec();
  static void *thread_code(void *);
  static void ensurenonexistent(string const &fn) throw(Error);
private:
  TerminationCode termination_code;
  bool hasthread;
  pthread_t thread;
  pthread_attr_t attr;
  class Recorder *recorder;
  class WakeupCli *sleeper;
  class SFCVoid *source;
  bool trig;
  int pretrig, posttrig;
  string filename;
  string trigname;
  string sourcename;
  string typenam;
  bool describe;
  string comments;
  FILE *trigfh;
  //  time_t nextbufusereport_s;
  time_t starttime_s; // this is real time, not recording time!
  time_t limit_s;
  int slot; // db use for threaded server, slot to record ntk commands
//  int ntk_sock; // db filedescriptor used for starting record of ntk commands
};

#endif
