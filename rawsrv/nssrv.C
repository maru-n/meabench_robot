/* rawsrv/nssrv.C: part of meabench, an MEA recording and analysis tool
** Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)
**                          Michael Ryan Haynes (gtg647q@mail.gatech.edu)
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

#define PROGNAME "nssrv"
#define NSSRV 1

#include <common/CMOSServerTools.H>

#include <common/ChannelNrs.H>
#include <base/Error.H>
#include <rawsrv/Defs.H>
#include <rawsrv/RS_Sock.H>

long long doubleChannels  = 0;
long long excludeChannels = 0;
int  data_port            = SERVER_PORT; // port (update from cmdgui)
const char * data_ip      = SERVER_ADDR; // ip (update from cmdgui)
 

void setStimChannels(int argc=0, char **args=0) {
  if (argc) {
    doubleChannels=0;
    excludeChannels=0;
    if (argc==1 && !strcmp(args[0],"-")) {
      //
    } else {
      unsigned long long one=1;
      for (int i=0; i<argc; i++) {
	int cr=atoi(args[i]);
	if (!validcr(cr))
	  throw Error("setStimChannels","Invalid CR");
	int hw=cr12hw(cr);
	excludeChannels |= one<<hw;
	doubleChannels |= one<<(hw+1);
      }
    }
  }

  if (excludeChannels==0) {
    fprintf(stderr,"Stimulated channels: none\n");
  } else {
    unsigned long long one=1;
    fprintf(stderr,"Stimulated channels:");
    for (int i=0; i<64; i++) 
      if (excludeChannels & (one<<i)) 
	fprintf(stderr," %s",hw2string(i).c_str());
    fprintf(stderr,"\n");
  }
}

void setHostAddr(int argc=0, char **args=0) {
  if (argc>0) {
    RS_Sock::setHostAddress(args[0]);
  }
  fprintf(stderr,"Host address: %s - port 0x%04x\n",
	  RS_Sock::hostAddress().c_str(), RS_Sock::hostPort());
};

//Chooses which raw stream (raw or raw2) to use
void setSource(int &argc, char **&argv) {
  char *addr = getenv("NEUROSOCKIP");
  if (addr)
    RS_Sock::setHostAddress(addr);
  
  if (argc>2 && !strcmp(argv[1],"-s")) {     //-s for source

    if (!strcmp(argv[2],"raw")) {
      RS_Sock::setPort(NEUROSOCK_PORT0);
      RS_Base::rawname = "raw";
    } else if (!strcmp(argv[2],"raw2")) {
      RS_Sock::setPort(NEUROSOCK_PORT1);
      RS_Base::rawname = "raw2";
    } else {
      fprintf(stderr,"Error: Unknown source '%s'. Possible sources are 'raw' or 'raw2'\n",argv[2]);
      throw 0;
    };

    fprintf(stderr,"Source is '%s'.\n",RS_Base::rawname.c_str());
    argv[2]=argv[0]; argv+=2; argc-=2;

  } else {
    fprintf(stderr,"Source is 'raw' by default.\n");
    RS_Base::rawname = "raw";
    RS_Sock::setPort(NEUROSOCK_PORT0);
  };
};

// DB - added for use with gui code
#ifdef CMDGUI
void setSource(char * NAME, int NS_PORT, const char * SRV_IP, int SRV_PORT) {
  
  data_port = SRV_PORT;
  data_ip   = SRV_IP;

  char *addr = getenv("NEUROSOCKIP");
  if (addr)
    RS_Sock::setHostAddress(addr);

  fprintf(stderr,"Source is '%s'.\n", NAME);
  //  RS_Base::rawname = "raw";
    RS_Base::rawname = NAME;
    RS_Sock::setPort(NS_PORT);
    //RS_Base::rawname = RAWNAME;
    //RS_Sock::setPort(NEUROSOCK_PORT);

/*  if (!strcmp(RAWNAME,"raw")) {
      RS_Sock::setPort(NEUROSOCK_PORT0);
      RS_Base::rawname = "raw";
  } else if (!strcmp(RAWNAME,"raw2")) {
      RS_Sock::setPort(NEUROSOCK_PORT1);
      RS_Base::rawname = "raw2";
  } else {
      fprintf(stderr,"Error: Unknown source '%s'. Possible sources are 'raw' or 'raw2'\n",RAWNAME);
      throw 0;
  };
*/
};
#endif

#include "rawsrv.C"
