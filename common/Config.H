// modified by Douglas Bakkum 2009
/* common/Config.H: part of meabench, an MEA recording and analysis tool
** Copyright (C) 2000-2003  Daniel Wagenaar (wagenaar@caltech.edu)
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

// Config.H

#ifndef CONFIG_H

#define CONFIG_H

#include <common/Types.H>
//#include <config.h>

#define LOCAL_HOST "127.0.0.1" // put into common/Config.H
#define NEUROSOCK_PORT  0xdded //0xeeee // use this for changing CmdGui type names
#define NEUROSOCK_PORT0 0xdddd //0xeeee
#define NEUROSOCK_PORT1 0xddde //0xeeef

//#define RAWNAME "raw2"
#define RAWNAME "raw"
#define RAWTYPE "raw"

//#define SPKNAME "spike2"
#define SPKNAME "spike"
#define SPIKETYPE "spike"
#define RAWSHOWNAME "spraw"



#define SFSUFFIX ".sf"
#define WAKESUFFIX ".wake"

//#define MCS_RAWDEVICE "/dev/MCCard"
//#define UEI_RAWDEVICE "/dev/pdmeata"
#define SOUNDDEVICE "/dev/dsp"

#define SCOPENICENESS 5

//const int FREQKHZ = 25;
const int FREQKHZ = 20; // DB modified

const int LOGRAWFIFOLENGTH = 17; // 2^17/25000 = 5.2 sec in buffer
const int LOGSPIKEFIFOLENGTH = 15; // 2^15 = 32768 spikes in buffer
const int LOGSPIKERAWSHOWLENGTH = 16; // 2^16/25000 = 2.6 sec in buffer
const int LOGEVENTFIFOLENGTH = 15;

//const int LOGTRIGBUF = 14; // 2^14/25000 = .65 sec in buffer } PRESERVE
//const int MAXPRETRIG = 600; // 600 ms max pre trigger        } CONSISTENCY

const int MAXFNLEN = 256; //:n MAXFNLEN
/*:D Maximum length of a filename. */

//#ifdef MEA_ULTRAFAST
//const int MCC_FILLBYTES = 16384;
//#else
//const int MCC_FILLBYTES = 32768; //:n MCC_FILLBYTES
/*:D This is the number of bytes to be read at a time from the raw device.
     Tom DeMarse's device driver can only deal with requests of exactly
     32KB. [As of 5/1/2000.] */
//#endif

const int NSAMPLES      = 64; // DB - 64 -> 3.2ms for CMOS read per frame
const int MCC_FILLBYTES = NSAMPLES*TOTALCHANS*sizeof(raw_t); // DB modified
//const int MCC_FILLBYTES = 16384;//65536;//25600; // DB modified
//const int MCC_FILLBYTES = 65536;//25600; // DB modified  
					 // 65536 -> 12.8ms for CMOS
					 // 16384 ->  3.2ms for CMOS

const int MCC_FILLSAMS = MCC_FILLBYTES/sizeof(Sample); //:n MCC_FILLSAMS
/*:D The number of samples to read from the raw device in a single request. */

const int TRIG_CHANNEL = 127;//60;  // db
const int EPOCH_CHANNEL = 127;//60;  // db
const int TRIG_THRESHOLD = 2048+512;
const int TRIG_MINIVAL = FREQKHZ * 10;
//:D triggers won't be detected if they're less than [10ms] apart

#endif
