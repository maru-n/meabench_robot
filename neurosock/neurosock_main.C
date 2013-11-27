/* neurosock/neurosock.C: part of meabench, an MEA recording and analysis tool
** Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)
**               Changes by Michael Ryan Haynes (gtg647q@mail.gatech.edu)
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


#include "srvMeata.H"
#include "srvCMOS.H"  //// DB
#include "FrameBuffer.H"
#include "Neurosock.H"
#include <unistd.h>


//srvMeata *Neurosock::srv=0;
//FrameBuffer *Neurosock::fb=0;
//unsigned char srvMeata::card_setting;
//bool Neurosock::hwRunning=false;
//int srvMeata::n_softoverruns;
//int Neurosock::connections=0;

void usage() {
  fprintf(stderr,"Usage: neurosock\n");
  exit(1);
}

int main(int argc, char **argv) {
  try {
    //Version and Card Type info
    fprintf(stderr,
  	    "This is neurosock.\n"
  	    "By Daniel Wagenaar, Feb 5 2002 - Mar 10 2004\n   Michael Ryan Haynes, June 14 - July 29 2004\n   Douglas James Bakkum, 2008 - 2010\n");
    
    srvMeata *meata = 0;
    meata = new srvCMOS(); // DB    connect to hardware

    //Initialize variables, frame buffer, and sockets
    FrameBuffer fb(12, meata);
    Neurosock *ns1 = new Neurosock(meata,&fb,NEUROSOCK_PORT0,0);

    //Loop either to listen or to poll for commands
    fprintf(stderr,"\nNeurosock is now accepting connections...\n");
    while (1) {
      ns1->Poll();
    };
  } catch (Error const &e) {
    e.report();
    fprintf(stderr,"Exiting\n");
    return 1;
  } catch (...) {
    fprintf(stderr,"Exiting upon unknown exception. This is a bug.\n");
    return 1;
  }
  return 0;
}
    
