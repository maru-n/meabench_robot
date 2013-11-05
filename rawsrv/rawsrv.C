/* rawsrv/rawsrv.C: part of meabench, an MEA recording and analysis tool
** Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)
**               Changes by Michael Ryan Haynes 2004 (gtg647q@mail.gatech.edu)
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

// main.C

#include <base/Cmdr.H>
#include <base/Error.H>
#include <base/Sigint.H>
#include <base/Linebuf.H>
#include <base/Variance.H>
#include <common/Types.H>
#include <common/Config.H>
#include <common/CommonPath.H>
#include <common/ChannelNrs.H>

#if CMDGUI
#else
#include <common/MEAB.H>
#endif

#include <common/directory.H>
#include <common/CMOSServerTools.H>

#include "Defs.H"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <math.h>

WakeupSrv *raw_waker=0;
RawSFSrv *raw_sfsrv=0;

bool didstart  = false;
int  blankout         = 0;
int  blankout_config  = 0;
bool dotrig    = false;
int  trig_refract = TRIG_MINIVAL/FREQKHZ; // user can add additional refractory period after a trigger [ms]
int  trigch    = TRIG_CHANNEL;
int  trigel    = -1;
int  data_sock =  0; // socket to connect to CMOS server
int  epoch     =  0;
bool dotrigel  = false;
raw_t trigthresh = TRIG_THRESHOLD;
string RS_Base::rawname = RAWNAME;

int raw_gain; // set in main
int rawslot=4; // default value, updating by user input for nssrv, dummy value for rawsrv // db


void raw_setblankout(int argc=0, char **args=0) {
  if (argc) {
    blankout = int(atof(args[0]) * FREQKHZ);
  }
  if (blankout && trigch>=NCHANS)
    fprintf(stderr,"Stimulation blankout is set to %g ms. (1ms before the trigger will also be blanked.)\n",
	    blankout*1.0/FREQKHZ);
  else
    fprintf(stderr,"Stimulation blankout is disabled.\n");    
}

void raw_setblankout_config(int argc=0, char **args=0) {
  if (argc) {
    blankout_config = int(atof(args[0]) * FREQKHZ);
  }
  if (blankout_config)
    fprintf(stderr,"Configuration blankout is set to %g ms when epoch=-1 is detected on %s.\n",
	    blankout_config*1.0/FREQKHZ, hw2string(EPOCH_CHANNEL).c_str());
  else
    fprintf(stderr,"Configuration blankout is disabled.\n");    
}

void raw_settrig(int argc=0, char **args=0) {
  if (argc) {
    dotrig = atoi(args[0])!=0;
    if(!dotrig) dotrigel=false;
  }
  if (argc>1) {
    trig_refract = atoi(args[1]);
  }
  if (dotrig && dotrigel) 
    fprintf(stderr,
	    "Trigger detection is enabled on electrode %i (channel %i) - threshold is %i, refractory period is %i ms.\nWARNING: this is an experimental command and may be buggy.\n\n",
	    trigel,trigch,trigthresh,trig_refract);
  else if (dotrig) {
    fprintf(stderr,
	    "Trigger detection is enabled on channel %s - threshold is %i, refractory period is %i ms.\n",
	    hw2string(trigch).c_str(),trigthresh,trig_refract);
    if( trigch<NCHANS ) fprintf(stderr,"WARNING: using non-DAC channels to trigger is experimental and may be buggy.\n\n");
  }else{
    fprintf(stderr,"Trigger detection is disabled.\n");
  }
}

void raw_autothresh(int argc, char **args) {
  //gain(); // db
  RawSource src(raw_gain,rawslot);
  src.start();
  Sample *buffer = new Sample[RawSource::quantum()];
  if (trigch>=0){
   try {
    src.read(buffer,RawSource::quantum());
    int sum=0;
    for (int i=0; i<RawSource::quantum(); i++)
      sum+=buffer[i][trigch];
    Variance<double> v(sum*1./RawSource::quantum());
    for (int k=0; k<100; k++) {
      src.read(buffer,RawSource::quantum());
      for (int i=0; i<RawSource::quantum(); i++)
  	v.addexample(buffer[i][trigch]);
    }
    float multi = argc?atof(args[0]):5;
    fprintf(stderr,"Mean value on %s is %i,\n\tRMS variance is %.1f,\n\tsetting threshold at %4.2f RMS.\n",
  	    hw2string(trigch).c_str(), int(v.mean()),sqrt(v.var()), multi);
    //trigthresh = raw_t(v.mean() + multi * sqrt(v.var()));
    if( trigch < NCHANS )
	trigthresh = raw_t(v.mean() - multi * sqrt(v.var()) - 1); // db
    else
	trigthresh = raw_t(v.mean() + multi * sqrt(v.var()) + 1); // db
    raw_settrig();
    delete [] buffer;
   } catch (...) {
    delete [] buffer;
    throw;
   }
  } else {
   trigthresh = 0;
  }
}

int raw_trigel2trigch(){
  if(!data_sock){
  	/* connect to the ThreadedServer */
        fprintf(stderr,"rawsrv.C trigel2trigch  slot:%i  elc:%i\n",rawslot,trigel);
  	//data_sock = connect_server(SERVER_ADDR,SERVER_PORT);
  	data_sock = connect_server(data_ip,data_port);
        send_client_name(data_sock,"Elc to Ch mapping");
  	/* tell server which slot to read data from */
  	//set_chip_slot(data_sock, raw_sfsrv->aux()->sourceinfo.slot);
  	set_chip_slot(data_sock, rawslot);
  }
  /* get mapping */
  int junk1[TOTALCHANS],junk2[TOTALCHANS],junk3[TOTALCHANS],junk4[TOTALCHANS];
  int elc[TOTALCHANS]; memset(elc,0,sizeof(elc));
  ch2el_mapping(data_sock,elc,junk1,junk2,junk3,junk4);
  for(int i=0;i<NCHANS;i++ )
	if( elc[i]==trigel )
	  return i;
  fprintf(stderr,"\tTrig electrode not found in configuration!\n");
  return -1;
}

void raw_trigch2trigel(){
  if(!data_sock){
  	/* connect to the ThreadedServer */
        //fprintf(stderr,"rawsrv.C trigch2trigel\n");
  	//data_sock = connect_server(SERVER_ADDR,SERVER_PORT);
  	data_sock = connect_server(data_ip,data_port);
        send_client_name(data_sock,"Ch to Elc mapping");
  	/* tell server which slot to read data from */
  	//set_chip_slot(data_sock, raw_sfsrv->aux()->sourceinfo.slot);
  	set_chip_slot(data_sock, rawslot);
  }
  /* get mapping */
  int junk1[TOTALCHANS],junk2[TOTALCHANS],junk3[TOTALCHANS],junk4[TOTALCHANS];
  int elc[TOTALCHANS]; memset(elc,0,sizeof(elc));
  ch2el_mapping(data_sock,elc,junk1,junk2,junk3,junk4);
  if( elc[trigch]==-1 )
	fprintf(stderr,"Trig channel %i is not connected to an electrode.\n",trigch);
  else
	fprintf(stderr,"Trig channel %i is connected to electrode %i.\n",trigch,elc[trigch]);
}

void raw_settrigch(int argc=0, char **args=0) {
  dotrigel = false;
  if (argc) {
    int ch = atoi(args[0]);
    //if (ch>=1 && ch<=2)
      //trigch = NCHANS-1 + ch;
    if (ch>=0 && ch<TOTALCHANS){
      trigch = ch; // db
      raw_trigch2trigel();
    }else
      throw Usage("trigchannel","[channel]");
  }
  raw_settrig();
}

void raw_settrigel(int argc=0, char **args=0) {// db
  if (argc) {
    epoch = -1; // initialize so that no triggers given until receive first configuration marker
    int el = atoi(args[0]);
    if (el>=0 && el<TOTALELCS){
	dotrigel=true;
        trigel = el; 
	if( (trigch=raw_trigel2trigch())<0 )  return;
    }else
      throw Usage("trigelectrode","[electrode]");
  }
//  fprintf(stderr,"Automatically setting threshold. \nUse 'autothresh [multiplier]' or \n'trigthreshold [digivalue]' to adjust.\n\t");
//  raw_autothresh(0,NULL);
//  raw_settrig();
}

void raw_settrigthresh(int argc=0, char **args=0) {
  if (argc)
    trigthresh = atoi(args[0]);
  raw_settrig();
}


#if NSSRV
void raw_slot(int argc=0, char **args=0) {
  bool legal=true;
  bool has=false;
  int val=-1;
  if (argc) {
    has = true;
    if (args[0][0]>='0' && args[0][0]<='4') 
      val = atoi(args[0]);
    else
      legal=false;
  }
  if (val < 0 || val >= 5)
    legal=false;
  if (legal) {
    if (has)
      rawslot = val;
  } else {
    fprintf(stderr,"Slot setting is illegal [%i]\n",val);
    fprintf(stderr,"Legal slot settings are 0 to 4.\n");
  }
  fprintf(stderr,"Slot will be set to %i.\n",rawslot);
}
#endif


void gain(int argc=0, char **args=0) {
//fprintf(stderr,"Gain no longer set here. Currently hardcoded in srvCMOS.C.\n");

  bool legal=true;
  bool has=false;
  int val=0;
  if (argc) {
    has = true;
    if (args[0][0]>='0' && args[0][0]<='9') 
      val = atoi(args[0]);
    else
      legal=false;
  }
  if (val < 0 || val >= RawSource::ngains())
    legal=false;
  if (legal) {
    if (has)
      raw_gain = val;
  } else {
    fprintf(stderr,"Gain setting is illegal\n");
    fprintf(stderr,"Legal gain settings are 0 to %i:\n",
	    RawSource::ngains()-1);
    fprintf(stderr,"  Setting  Range (mV)\n");
    for (int i=0; i<RawSource::ngains(); i++) 
      fprintf(stderr,"     %i     %6.3f\n",i,RawSource::range(i)/1000.0);
  }
  fprintf(stderr,"Gain will be set to %i (+/- %g mV full range)\n",
	  raw_gain,
	  RawSource::range(raw_gain)/1000);
// */
}

void raw_dostart(RawSource &src) {
  ///raw_sfsrv = new RawSFSrv(CommonPath(RS_Base::rawname,SFSUFFIX).c_str(), LOGRAWFIFOLENGTH); 

#if NSSRV
  src.setChannels(excludeChannels,doubleChannels);
#endif

  raw_sfsrv->aux()->sourceinfo = src.sourceInfo();
  raw_sfsrv->aux()->hwstat = SFAux::HWStat();
  raw_sfsrv->startrun(); 
  raw_waker->start();
  src.start();


}

void raw_dostop(RawSource &src) {
  //fprintf(stderr,"\traw_dostop entered\n");
  try {
    src.stop();
    raw_sfsrv->aux()->hwstat = src.status();
    
    if (raw_sfsrv->aux()->hwstat.errors) 
      fprintf(stderr,"Warning: Hardware errors were encountered (%i x)\n",
	      int(raw_sfsrv->aux()->hwstat.errors));
    if (raw_sfsrv->aux()->hwstat.overruns)
      fprintf(stderr,"Warning: Overruns were detected (%i x)\n",
	      int(raw_sfsrv->aux()->hwstat.overruns));
  } catch (Error const &e) {
    e.report();
  }
  raw_sfsrv->endrun(); raw_waker->stop();
  ///if (raw_sfsrv)
  ///  delete raw_sfsrv;
  //fprintf(stderr,"\traw_dostop exited\n");
}


#if CMDGUI
void MeaRaw::raw_run(int argc, char **args) {
  QEventLoop loop;
#else // to reduce amount of text printed to terminal when using cmdgui
void raw_run(int argc, char **args) {
  raw_settrig();
  raw_setblankout();
  raw_setblankout_config();
#endif

  //gain(); // db
  #if NSSRV
  setHostAddr();
  #endif  
//#if NSSRV
//  setStimChannels();
//#endif

  RawSource src(raw_gain,rawslot);
  raw_dostart(src);

//fprintf(stderr,"rawsrv.C  %lli  \n",raw_sfsrv->aux()->sourceinfo.cmos_start_sample);
if(!raw_sfsrv->latest())
	raw_sfsrv->donewriting( raw_sfsrv->aux()->sourceinfo.cmos_start_sample  ); //donewriting

//fprintf(stderr,"rawsrv.C  first %lli \n",raw_sfsrv->first());
//## works first time but second time does not! raw_sfsrv not updated.........

  raw_sfsrv->aux()->trig = SFAux::Trig(dotrig);

  if (blankout && !dotrig)
    fprintf(stderr,"Warning: Stimulation blankout will not work, because triggering is disabled.\n" );
  if (blankout_config && !dotrig)
    fprintf(stderr,"Warning: Configuration blankout will not work, because triggering is disabled.\n" );
  
  timeref_t t_first = raw_sfsrv->latest();
  timeref_t t_end;
  if (argc) {
    timeref_t dt = timeref_t(FREQKHZ*1000*atof(args[0]));
    t_end = t_first + dt;
    sdbx("dt=%lli t_stop=%lli",dt,t_end);
  } else {
    t_end = INFTY;
    sdbx("t_stop=%lli",t_end);
  }
  raw_sfsrv->aux()->t_end = t_end;

  timeref_t t_lastchecked      	= t_first;
  timeref_t t_lastthreshupdate 	= t_first;
  timeref_t t_lasttrig    	= t_first;  // db
  timeref_t t_epoch       	=     0;    // db
  bool 	    trig_update   	= false;    // db
  float     cnt_epoch	  	=     0;    // db
  float     ary_epoch[3];  		    // db
  int	    ary_c		=     0;    // db
  int epoch_offset=11;			    // db


  //  timeref_t t_trigend = t_first;
//win//	 timeref_t dt_pretrig = raw_sfsrv->aux()->trig.dt_pretrig;
//win//	 timeref_t dt_posttrig = raw_sfsrv->aux()->trig.dt_window - dt_pretrig;

//fprintf(stderr,"tfirst %lli  tend %lli\n",t_first,t_end);


  fprintf(stderr,"Raw stream running...\n");
  #if CMDGUI
  //emit mearawMessage(" ");
  emit mearawMessage("Raw stream running.");
  emit running();
  #endif

      int havemore=0;
      int totalread=0;
      int quantum=0;

  try {
    Sample blankout_value;
    timeref_t blankout_until = 0;
    //bool blankingout=false; //db -- need to blank a little before trig too (try 0.5ms for now) use this to do so
    while (raw_sfsrv->latest()<t_end) { 
       havemore=0;
       totalread=0;
       quantum = RawSource::quantum();
      bool hastrig = false; 

   	#if CMDGUI
	loop.processEvents(); 
    	if (!raw_started) { // set false when push stop button in gui
	  //fprintf(stderr,"Rawsrv.C Stop button pushed\n");
	  throw QString("Stop button pushed.");
    	}
	#else
	if (Sigint::isset()){   // for cntr-c to exit running
	  fprintf(stderr,"sigint\n");
	  throw Intr();
	}
        #endif

      do {

	timeref_t l = raw_sfsrv->latest();
	timeref_t e = l+quantum;
	havemore=src.read(raw_sfsrv->wheretowrite(),quantum);
	totalread+=quantum;
	/*:E The current implementation cannot find more than one trigger
	     per read period. */
	if (dotrig) {
	  if (l<blankout_until) {
	    // do some blanking
	    if (e>blankout_until)
	      e=blankout_until;
	    while (l<e) {
	      Sample &s=(*raw_sfsrv)[l++]; 
	      for (int c=0; c<NCHANS; c++)
		s[c] = blankout_value[c];
	    }
	  }

// db modifications to get triggers from spontaneous spikes ////////////////////
	  while (t_lastchecked < e){ 


	    //if( dotrigel ){ // ~~ decode epoch here to find trigch when change configurations (epoch must be set to -1 then ~=-1 to work -- this can be used to avoid triggers while amps settle after configuration change) ~~ 
		if( ((*raw_sfsrv)[t_lastchecked  ][EPOCH_CHANNEL]>=4050) && t_lastchecked > t_epoch+1*FREQKHZ  ){ // check for analog channel; avoid spikes within 1ms of each other (shouldnt happen with DACs...)
			t_epoch   = t_lastchecked;
			cnt_epoch = 2048; // epoch set to -1
			//fprintf(stderr,"trigger found, previous epoch was %i\n",epoch);
		}else if( (t_lastchecked > t_epoch+2) && (t_lastchecked < t_epoch+epoch_offset) ){

            float tmp = (*raw_sfsrv)[t_lastchecked][EPOCH_CHANNEL];
			if( tmp!=2048 && tmp<4080 ) cnt_epoch=tmp; // the width of the encoding pulse is varying, so use this instead of averaging... 2048->zero 4080->maximum
			//cnt_epoch+=(*raw_sfsrv)[t_lastchecked][EPOCH_CHANNEL];
		}else if( t_lastchecked==t_epoch+epoch_offset ){
			//cnt_epoch=cnt_epoch/(epoch_offset-3);
			//epoch = (int)(cnt_epoch/16-128);// low res DAC encoding
			epoch = (int)(cnt_epoch/4-512);// high res DAC encoding, 100302
			//epoch = (int)floor( (cnt_epoch/16-128) + 0.5 ); // round 'x' using 'floor( x + 0.5 )'); 
			// get occasional errors in encoding -- maybe better to use median? no - same result.
			//fprintf(stderr,"DEBUG   epoch %i   ",epoch);
			/*fprintf(stderr,"DEBUG   epoch %i  %i %i %i %i %i %i %i %i %i %i %i",epoch, \
							(*raw_sfsrv)[t_lastchecked-epoch_offset+0][EPOCH_CHANNEL],\
							(*raw_sfsrv)[t_lastchecked-epoch_offset+1][EPOCH_CHANNEL],\
							(*raw_sfsrv)[t_lastchecked-epoch_offset+2][EPOCH_CHANNEL],\
							(*raw_sfsrv)[t_lastchecked-epoch_offset+3][EPOCH_CHANNEL],\
							(*raw_sfsrv)[t_lastchecked-epoch_offset+4][EPOCH_CHANNEL],\
							(*raw_sfsrv)[t_lastchecked-epoch_offset+5][EPOCH_CHANNEL],\
							(*raw_sfsrv)[t_lastchecked-epoch_offset+6][EPOCH_CHANNEL],\
							(*raw_sfsrv)[t_lastchecked-epoch_offset+7][EPOCH_CHANNEL], \
							(*raw_sfsrv)[t_lastchecked-epoch_offset+8][EPOCH_CHANNEL], \
							(*raw_sfsrv)[t_lastchecked-epoch_offset+9][EPOCH_CHANNEL], \
							(*raw_sfsrv)[t_lastchecked-epoch_offset+10][EPOCH_CHANNEL], \
							(*raw_sfsrv)[t_lastchecked-epoch_offset+11][EPOCH_CHANNEL] \
				);// */
			// Changed condition from <0 to ==-1. Now can send epochs <-1 to DAC that do not initiate trig_update, but do set trig_update, and are deted as spike. This is useful when recording ntk-events in order to get noise data for later spike sorting, by having the stim code send a series of pulse with epochs <-1.
            if( epoch==-1 ){
		  	   trig_update=true;
			   fprintf(stderr,"Updating trigger: new configuration detected. Waiting to update...  [epoch %i]\n",epoch);
			}else{ // epoch~=-1 
			   if( trig_update ){
			     trig_update=false;
			     fprintf(stderr,"\tElectrode %i now on channel %i.  [epoch %i]\n",trigel,trigch,epoch);
			     if( dotrigel  &&  (trigch=raw_trigel2trigch()) >= 0 ){   // update trig channel from new configuration
				    // update threshold
				    trigthresh = 0;  // get artifact from signals settling, therefore set to rail, and update below
		    		    t_lastthreshupdate = t_lastchecked; // add this in order to wait a bit after configuration marker
/*				    float multi = 5;  // 
				    int sum=0;
				    for (int i=t_lastchecked; i>t_lastchecked-256; i--)    		sum+=(*raw_sfsrv)[i][trigch];
				    Variance<double> v(sum*1./256);
				    for (int k=0; k<50; k++) {
				      for (int i=t_lastchecked-k*256; i>t_lastchecked-k*256-256; i--) 	v.addexample((*raw_sfsrv)[i][trigch]);
				    }
				    fprintf(stderr,"\tMean value on %s is %i, RMS variance is %.1f, threshold set at %4.2f RMS.\n",hw2string(trigch).c_str(), int(v.mean()),sqrt(v.var()), multi);
				    trigthresh = raw_t(v.mean() - multi * sqrt(v.var()) - 1); // db
				   // trigthresh = raw_t(v.mean() - 150); // db
*/
			     }else{
				if( dotrigel )
				    fprintf(stderr,"\tInvalid channel for el %i.  [epoch %i]\n",trigel,epoch);	
			   	epoch = -1; // this causes first stim to be ignored.
		} } } }


		// UPDATE THRESH more often? use limada instead?
		if( dotrigel  &&  epoch>-1 && t_lastchecked>t_lastthreshupdate+20000){ // update once a second
		    // update threshold  more often
		    t_lastthreshupdate = t_lastchecked;
		    float multi = 5;  // !!!!!!!
		    int sum=0;
		    for (int i=t_lastchecked; i>t_lastchecked-256; i--)    		sum+=(*raw_sfsrv)[i][trigch];
		    Variance<double> v(sum*1./256);
		    for (int k=0; k<50; k++) {
		      for (int i=t_lastchecked-k*256; i>t_lastchecked-k*256-256; i--) 	v.addexample((*raw_sfsrv)[i][trigch]);
		    }
		    fprintf(stderr,"\tMean value on %s is %i, RMS variance is %.1f, threshold set at %4.2f RMS.\n",hw2string(trigch).c_str(), int(v.mean()),sqrt(v.var()), multi);
		    trigthresh = raw_t(v.mean() - multi * sqrt(v.var()) - 1); // db
		    //trigthresh = raw_t(v.mean() - 150); // db
		}//*/

		
		// USE blankout to blank during epoch changes?  will save a lot of diskspace when recording spike files...
		if( trig_update ){
              if( t_lastchecked == t_epoch+epoch_offset ){
			    blankout_value=(*raw_sfsrv)[t_lastchecked-5];
			    blankout_value+=(*raw_sfsrv)[t_lastchecked-25];
			    blankout_value+=(*raw_sfsrv)[t_lastchecked-55];
			    blankout_value+=(*raw_sfsrv)[t_lastchecked-90];
			    blankout_value*=.25;			
		      }
		      if( t_lastchecked < t_epoch + blankout_config ){
		      	Sample &s=(*raw_sfsrv)[t_lastchecked];
		      	for (int c=0; c<NCHANS; c++)
			   s[c] = blankout_value[c];
		     }
		}


	    //}
	    //////


	    t_lastchecked++;
        if (   ( ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch]>=trigthresh)  &&  trigch>=NCHANS && trigch<TOTALCHANS  &&  epoch>=0  ) || \
                   ( ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch] <trigthresh)  &&  trigch>=0      && trigch<NCHANS      &&  epoch>=0  ) ){ 
	      //if (   ( ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch]>=trigthresh)  &&  trigch>=NCHANS && trigch<TOTALCHANS) || \
              //     ( ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch] <trigthresh)  &&  trigch>=0      && trigch<NCHANS      && (epoch>=0 || !dotrigel) )    ){ //}
	      //if(t_lastchecked-(epoch_offset+1)>t_lasttrig+TRIG_MINIVAL  &&  t_lastchecked-(epoch_offset+1)>t_epoch+5*FREQKHZ ){ //}
 	      //if(t_lastchecked-(epoch_offset+1)>t_lasttrig+TRIG_MINIVAL){ //}
	      // Find (negative) peak before setting trig time by comparing to next 3 values (150us).


///////////// Must wait same duration as recording trace, including the pre trigger samples for some strange reason.
/////////////////////////////////////////////////////////////////////////////////////***////////////////////////////
/* 	      if( 	((                          trigch >= NCHANS                           ) &&
 	      		 (                  t_lastchecked-(epoch_offset+1) > t_lasttrig+TRIG_MINIVAL+200      ))   ||  (
 	      		 (                  t_lastchecked-(epoch_offset+1) > t_lasttrig+TRIG_MINIVAL+200      ) &&
			 ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch] < (*raw_sfsrv)[t_lastchecked-epoch_offset+0][trigch]) &&
			 ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch] < (*raw_sfsrv)[t_lastchecked-epoch_offset+1][trigch]) &&
			 ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch] < (*raw_sfsrv)[t_lastchecked-epoch_offset+2][trigch])     )){    */
          if( 	((                          trigch >= NCHANS                           ) &&
 	      		 (                  t_lastchecked-(epoch_offset+1) > t_lasttrig+trig_refract*FREQKHZ  ))   ||  (
 	      		 (                  t_lastchecked-(epoch_offset+1) > t_lasttrig+trig_refract*FREQKHZ  ) &&
			 ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch] < (*raw_sfsrv)[t_lastchecked-epoch_offset+0][trigch]) &&
			 ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch] < (*raw_sfsrv)[t_lastchecked-epoch_offset+1][trigch]) &&
			 ((*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][trigch] < (*raw_sfsrv)[t_lastchecked-epoch_offset+2][trigch])     )){

  	            fprintf(stderr,".");
		//fprintf(stderr,"lasttrig %lli.  newtrig %lli. diff %lli\n",t_lasttrig,t_lastchecked-epoch_offset,-t_lasttrig+t_lastchecked-epoch_offset );

                t_lasttrig = t_lastchecked-(epoch_offset+1);//-raw_sfsrv->first();
 	            raw_sfsrv->aux()->trig.t_latest = t_lasttrig;
	            raw_sfsrv->aux()->trig.n_latest++;
	            raw_sfsrv->aux()->trig.e_latest = epoch;
	            hastrig = true;
	            if (blankout && trigch >= NCHANS) {
		            l=t_lastchecked-(epoch_offset+1)-20; // db -- blank 1ms before trig too
		            blankout_until = l + blankout + 20;
		            blankout_value=(*raw_sfsrv)[l-5];
		            blankout_value+=(*raw_sfsrv)[l-25];
		            blankout_value+=(*raw_sfsrv)[l-55];
		            blankout_value+=(*raw_sfsrv)[l-90];
		            blankout_value*=.25;
		            if (e>blankout_until)
		                e=blankout_until;
		            while (l<e) {
		            Sample &s=(*raw_sfsrv)[l++];
		            for (int c=0; c<NCHANS; c++)
		                s[c] = blankout_value[c];
		            }
	            } 
	      }//t_lastchecked = t_lastchecked + TRIG_MINIVAL;
	    }

        // encode epoch on DAC for 'epoch_offset' samples after time of trigger (needed when finding epoch from triggered raw recordings)
 	    if( t_lastchecked-(epoch_offset+1) < t_lasttrig+epoch_offset  && trigch < NCHANS ){ 
	        (*raw_sfsrv)[t_lastchecked-(epoch_offset+1)][EPOCH_CHANNEL] = 2048+epoch*4;
	    }


	  }/// while(t_lastchecked < e){ 

	}
	raw_sfsrv->donewriting(quantum);
      } while (havemore > quantum);
      raw_waker->wakeup(totalread);
      /*:N Recall that we are functionally required to make data available
   	   to clients before sending the trigger poll. */
      if (hastrig) 
	raw_waker->send(Wakeup::Trig);
    }
  } catch (...) { // catches any exception
    //fprintf(stderr,"\tflag rawsrv.C raw_run exception caught\n");
    raw_dostop(src);
    throw;
  }
    //fprintf(stderr,"\tflag rawsrv.C raw_run ended\n");
  raw_dostop(src);
}

void raw_report(int argc, char **args) {
  if (raw_waker)
    raw_waker->report();
}

#if CMDGUI
#else
struct Cmdr::Cmap raw_cmds[] = {
  { Cmdr::quit, "quit",0,0,"", },
  { cd, "cd", 0, 1, "[directory name]", },
  { ls, "ls", 0, 100, "[ls args]", },
  { mkdir, "mkdir", 1, 100, "mkdir args", },
  { raw_run, "run", 0, 1, "[time-in-s]", },
  { raw_settrig, "usetrig", 0,2, "[0/1] [refractory-period-in-ms]", },
  { raw_settrigch, "trigchannel", 0,1, "[channel]", },
  { raw_settrigel, "trigelectrode", 0,1, "[electrode]", },
  { raw_settrigthresh, "trigthreshold", 0,1, "[digivalue]", },
  { raw_autothresh, "autothresh", 0,1, "[multiplier]", },
  { gain, "gain", 0,1, "[gain step]", },
  { raw_setblankout, "blankout", 0,1, "[period-in-ms or 0]", },
  { raw_setblankout_config, "configblankout", 0,1, "[period-in-ms or 0]", },
  { setdbx, "dbx", 0, 1, "[0/1]", },
  { raw_report, "clients", 0, 0, "", },
#if NSSRV
  { raw_slot, "slot", 0,1, "[0/1/2/3/4]", },
  //  { setStimChannels, "stimchannels", 0,64, "[CR ...|-]", },
  { setHostAddr, "ip", 0,1, "host-IP-address", },
#endif
  0,
};
#endif

void raw_deletem() {
  if (raw_waker)
    delete raw_waker;
  raw_waker=0;
  if (raw_sfsrv)
    delete raw_sfsrv;
}

#if CMDGUI
// instead the main_function() in the CmdGui software, mearaw.cpp, is used
#else
int main(int argc, char **argv) {

  MEAB::announce(PROGNAME);
  fprintf(stderr,"This version of " PROGNAME " was compiled for use with the hidens v2 mea.\n");

  raw_gain=2;
  if (raw_gain >= RawSource::ngains())
    raw_gain = RawSource::ngains() - 1;

#if NSSRV
  setSource(argc,argv);
#endif
  try {
    raw_sfsrv = new RawSFSrv(CommonPath(RS_Base::rawname,SFSUFFIX).c_str(), LOGRAWFIFOLENGTH); 
    raw_waker = new WakeupSrv(CommonPath(RS_Base::rawname,WAKESUFFIX).c_str());
    raw_waker->postinit();

    Sigint si(raw_deletem);


    if (!Cmdr::exec(argc,argv,raw_cmds)) {
      Linebuf lbuf(raw_waker->collect_fd());
      while (1) {
	try {
	  Cmdr::loop(PROGNAME,raw_cmds,&lbuf);
	  raw_deletem();
	  return 0;
	} catch (int) {
	  dbx("Caught int");
	  // Read stuff from the raw_waker collect fd, then execute the
	  // command read from there. I am envisaging that the
	  // commands from there are limited-length inside the
	  // WakeupstreamMsg thing. They will be a null-terminated
	  // string.
	}
      }
    }
    raw_deletem();
    return 0;
  } catch (Error const &e) {
    int retval = 1;
    try {
      Expectable const &ee = dynamic_cast<Expectable const &>(e);
      ee.report();
      retval = 0;
    } catch (...) {
      e.report();
    }
    raw_deletem();
    exit(retval);
  } catch (...) {
    fprintf(stderr,"Weird exception\n");
    exit(1);
  }
  return 2;
}
#endif
