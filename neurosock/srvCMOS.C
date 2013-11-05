// Modified from srvMCMeata.C to call and recieve data and configurations from the HiDens server application. 
// Douglas Bakkum

#include "srvCMOS.H"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/time.h>

#include <sys/socket.h>//db

static float AUX_RANGE_MV[] = { 4092, 1446, 819.6, 409.2 };

srvCMOS::srvCMOS() throw(Error) {
  data_ip       = SERVER_ADDR;
  data_port	= SERVER_PORT;
  init();
}

srvCMOS::srvCMOS(const char * ip, int port) throw(Error) { // for input from cmdgui
  data_ip       = ip;
  data_port	= port;
  //fprintf(stderr,"srvCMOS.C: server set to ip %s  port %i.\n",data_ip,data_port);
  init();
}

srvCMOS::~srvCMOS() {
  stop();
  delete [] buf;		  
}

void srvCMOS::init() {
  frame_size_rawt = MCC_FILLBYTES/sizeof(raw_t);
  buf = new raw_t[frame_size_rawt];
  
  sms=0; // counter used to send an sms message only once

  //setCHN(use128 ? MC128 : MC64);
  //setGain(0);
  chn  = 0;
  slot = 4; // default slot where CMOS array is plugged -- also to be set by nssrv
  stop();
  isrunning   = false;
  isconnected = false;
  i_run_start = i_now = 0;
  i_firstsoftoverrun=i_lastsoftoverrun=0;
  n_softoverruns=0;

  readSize 	=    frame_size_rawt / TOTALCHANS * CMOS_BYTEPERSAMPLE + 8;//chn==MC128 ? 2*MCC_FILLBYTES : MCC_FILLBYTES;
  readSamples 	=    frame_size_rawt / TOTALCHANS; // number of samples (# cmos 'frames') per meabench frame
  readTime  	= (float)readSamples / FREQKHZ; // (12.8ms) time in msec to fill readSize

  gettimeofday(&t_start, NULL);

//fprintf(stderr,"OFFSET %i\n",SERVER_FRAMENO_OFFSET);
// fprintf(stderr,"srvCMOS::readTime = %f\n",readTime);
/*/// debug
totaldata=0;
start();
while(1){
nextFramePlease(temp);
//usleep(1000);
}//*/

}

void srvCMOS::start() {
   //fprintf(stderr,"[dbg] srvCMOS::start\n");
   if( isrunning )
	return;

   //fprintf(stderr,"[dbg] Trying to connect to slot %i\n",slot);

   char cmd[64];
   char msg[64];
   
   /* connect to the ThreadedServer */
   //fprintf(stderr,"srvCMOS::start()  server set to ip %s  port %i.\n",data_ip,data_port);
   //data_sock = connect_server(SERVER_ADDR,SERVER_PORT);
   data_sock = connect_server(data_ip,data_port);
   isconnected = true;
   send_client_name(data_sock,"neurosock");


/* // closed-loop delay testing variables
   fpga_sock=connect_server(FPGA_ADDR, FPGA_PORT);  // CL testing
   fprintf(stderr,"fpga connected to sock %i\n",fpga_sock); // CL testing
   frameno1=0; // CL testing
   frameno2=0; // CL testing
   ////*///


   /* tell server which slot to read data from */
   int chipid = set_chip_slot(data_sock, slot);
   if( chipid<0 || chipid==65535 ){
	fprintf(stderr,"Invalid chip ID (%i) on slot %i.\nNot running.\n",chipid,slot);
	stop();
        throw SysErr("srvCMOS",""); 
   }
   //fprintf(stderr,"[dbg] Chip %i on slot %i.\n",chipid,slot);
   
   

   /* set DAC encoding */
   usleep(100);
   memset(&cmd,0,sizeof(cmd));
   memset(&msg,0,sizeof(msg)); 
   sprintf (cmd, "setbytes %i\n",CMOS_BYTEPERSAMPLE);
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );
 /*  ret = send(data_sock,cmd,n,0);
   if(ret<0) {
      perror("cannot set DAC encoding ");
      stop();
      throw SysErr("srvCMOS",""); 
   }
   usleep(100);
   memset(&msg,0,sizeof(msg)); 
   ret = recv(data_sock, msg, sizeof(msg), 0); 
   if(ret<0 || atoi(msg)<0) {
      perror("cannot set DAC encoding [2] ");
      stop();
      throw SysErr("srvCMOS","");
   }//*///

   /* direct to return framenumber with each requested packet */
   usleep(100); 
   memset(&cmd,0,sizeof(cmd));
   memset(&msg,0,sizeof(msg)); 
   sprintf (cmd, "header_frameno on\n");
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );
/*   ret = send(data_sock,cmd,n,0);
   if(ret<0) {
      perror("cannot set header_frameno ");
      stop();
      throw SysErr("srvCMOS","");
   }
   usleep(100);
   memset(&msg,0,sizeof(msg)); 
   ret = recv(data_sock, msg, sizeof(msg), 0); 
   if(ret<0 || atoi(msg)<0) {
      perror("cannot set header_frameno [2] ");
      stop();
      throw SysErr("srvCMOS","");
   }// *///

  frameno=0;
  //fprintf(stderr,"frame_size_rawt %i   %i\n",frame_size_rawt,frameno-frame_size_rawt); 
   /* read a few samples to initialize frameno */  
   usleep(100); 
   unsigned char b0[readSize]; 
   long long int frameno_reduced;
   do{
     memset(&cmd,0,sizeof(cmd));
     memset(&b0,0,sizeof(b0));
     sprintf (cmd, "stream %3.2f\n",1.0/FREQKHZ);
     send_command( data_sock, cmd );
     recv_answer( data_sock, b0, sizeof(b0) );
     /*ret = send(data_sock,cmd,n,0); 
     if(ret<0) {
      	perror("error streaming data ");
        stop();
      	throw SysErr("srvCMOS","");
     } 
     memset(&b0,0,sizeof(b0));
     if( recv(data_sock, b0, sizeof(b0), 0) <= 0){
        stop();
	throw SysErr("srvCMOS","Read failed");
     } */
     frameno=(int)b0[0]+ \
	(int)b0[1]*256+ \
	(int)b0[2]*256*256+ \
	(int)b0[3]*256*256*256+ \
	(int)b0[4]*256*256*256*256+ \
	(int)b0[5]*256*256*256*256*256+ \
	(int)b0[6]*256*256*256*256*256*256+ \
	(int)b0[7]*256*256*256*256*256*256*256;
     frameno -= SERVER_FRAMENO_OFFSET;
     frameno_reduced=0;
     //while( frameno-frameno_reduced > 3276800000 2^(8*sizeof(int)) ) frameno_reduced+=2^(8*sizeof(int)); // do this such that math works in exit while condition
     while( frameno-frameno_reduced > 32768000000 ) frameno_reduced+=32768000000; // do this such that mathematics work in exit while condition
     frameno_reduced=frameno-frameno_reduced;
   }while( (frameno_reduced+1)%frame_size_rawt != 0 ); // needs to be multiple of 32768 for meabench to offset correctly in rawsrv.C
//   }while( (frameno%frame_size_rawt)-1 != 0 ); // needs to be multiple of 32768 for meabench to offset correctly in rawsrv.C
   frameno+=1; 	// add one since read one sample
  //fprintf(stderr,"frame_size_rawt %i   frameno %lli  reduced:%lli  mod:%i\n",frame_size_rawt,frameno,frameno_reduced,(frameno_reduced%(frame_size_rawt))); 
  //fprintf(stderr,"sizeofint %i\n",sizeof(int));
   //*///



   num_frameno_errors=0; // reset
   isrunning = true;
   i_run_start = i_now;
   //fprintf(stderr,"[dbg] Running...\n");
   //fprintf(stderr,"[dbg] First frameno: %lli\n",frameno);
}

void srvCMOS::stop() {  
  //fprintf(stderr,"[dbg] Disconnecting from server.\n"); 
  if( isconnected )
	close_server(data_sock);
  if( !isrunning )
	return;
  isrunning = false;
  //fprintf(stderr,"[dbg] Stopped.\n");
}


void srvCMOS::reset() {  // added by db in order to initialize i.cmos_start_sample correctly (via Neurosock.C)
  //fprintf(stderr,"[dbg] Resetting.\n");
  i_run_start = i_now = 0;
  i_firstsoftoverrun=i_lastsoftoverrun=0;
  n_softoverruns=0;
  stop();
  start();
  frameno_last=frameno-readSamples; // reset -- correct?
}

//void srvCMOS::setGain(int n) { // for now just get gains from server 
void srvCMOS::setGain(int n) {  // int n is not necessary, but will be if have user input in nssrv setGain(int A1, int A1, int A3) + adc range and res too? -- maybe better to leave this input from fpga and just read values...
	//fprintf(stderr,"Setting gain.\n");
	/*float A1gain = 30.03; // better to read values from emulator via telnet/tcpip
	float A2gain = 31.92;
	float A3gain = 1;
	gain=A1gain*A2gain*A3gain;*/
//	float A1gain = 30.03; // /
//	float A2gain = 1;
//	float A3gain = 10;
//	adc_range = 0.496; // ADC set to 31 in AVR shell

	adc_res   = pow(2,ask_for_adc_res(data_sock));//256; // 2^8
	adc_range = ask_for_adc_range(data_sock);//2.992;
	gain = ask_for_gain(data_sock);//958.558
	//gain = 958.558;
    //fprintf(stderr,"NOT reading server for gain! Using STATIC GAIN of 958.558");
	//fprintf(stderr,"Reading server: gain=%f   ADC=%idigi, %fV range\n",gain,(int)adc_res,adc_range);

        //dac_res   = pow(2,ask_for_dac_res(data_sock));//256; // 2^8
	//dac_range = ask_for_dac_range(data_sock);//2.992;

}

void srvCMOS::setSlot(int n){
	//fprintf(stderr,"Setting slot to slot %i\n",n);
	slot=n;
}

/*void srvCMOS::setCHN(int n) {
  chn = n;
}*/

void srvCMOS::fillInfo(NS_Info &i) {
  //fprintf(stderr,"[dbg] srvCMOS::fillInfo\n");
  fprintf(stderr,"[dbg] srvCMOS::fillInfo   frameno=%f\n",(float)frameno);
//  struct MCCard_stats stats;
//  fprintf(stderr,"[dbg] Read card stats OK\n");

  i.slot = slot;
  i.data_ip = data_ip;
  i.data_port = data_port;
  i.cmos_start_sample = frameno; // DB 12/2011 -- commented
  //i.cmos_start_sample = frameno-readSamples-1; // This didnt work. Caused RS_Sock errors in rawsrv and SFCli errors between scope and spikedet.... 
				// DB 12/2011
				// -- Hack to align spikes and trig times to times in ntk file.
				//    Seems to always be off by:  readSamples + 1 sample.

   //fprintf(stderr,"fillinfo frameno: %lli\n",i.cmos_start_sample);
  i.bytes_per_sample = sizeof(raw_t);
  i.samples_per_scan = TOTALCHANS;
  i.bytes_per_frame = MCC_FILLBYTES;
  i.scans_per_frame = i.bytes_per_frame / (i.bytes_per_sample * i.samples_per_scan);
  i.scans_per_second = CMOS_FREQHZ; // comes from FREQKHZ in common/Config.H
  i.gain_setting = (int)(gain);
  //fprintf(stderr,"[dbg] srvCMOS::fillInfo gain %i\n",i.gain_setting);
  //i.uV_per_digi_elc = 4.2371/16;/// ADC  65 digi -> 1.04V range //0.496*(1000000/300.3/256/16);//adc_range*(1000000/gain/adc_res/16);
  //i.uV_per_digi_elc = 6.26/16;/// ADC 100 digi -> 1.60V range
  //i.uV_per_digi_elc = 11.7/16 * 1000/958.558;//i.mV_per_digi_aux / 1.2; /// ADC default 187 -> 2.99V range
  i.uV_per_digi_elc = (adc_range*1000/adc_res)/16 * 1000 / gain;// i.mV_per_digi_aux / 1.2; /// ADC default 187 -> 2.99V range
								// meabench uses 12-bit (mcs convention) -- 16=2^12 / 2^8;
  i.mV_per_digi_aux = 11.7/16;  				// currently using low-resolution DAC encoding until update new fpga software when released...
								// ! now using high res, need to change this?? read DAC values to get the 11.7 ?? maybe not too important....

//fprintf(stderr,"mV/digi %f\tuV/digi %f\n",i.mV_per_digi_aux,i.uV_per_digi_elc);       
//fprintf(stderr,"mV/digi %f\tuV/digi %f\n",adc_range*1000/adc_res/16,adc_range*1000000/gain/adc_res/16);
//fprintf(stderr,"gain %f   adc %f  %f\n",gain,adc_range,adc_res);
  i.num_electrodes = 126;
  i.num_aux = 2;
  i.digital_half_range = 2048; // sourceinfo.nominalrange
  i.digital_zero = 2048;
  i.frames_transmitted = i_now - i_run_start;
  i.run_start_frame = i_run_start;
  i.is_running = isrunning;
  i.neurosock_overruns = n_softoverruns;
  i.meata_overruns = 0;//stats.overruns;
  i.other_errors = num_frameno_errors;//stats.Hardware_errors;
  i.total_errors = i.neurosock_overruns + i.meata_overruns + i.other_errors;
  i.last_error_frame = i_lastsoftoverrun;
  i.card_setting = chn;
  //fprintf(stderr,"gain: %i. nframes: %i. isrunning: %c\n",
  //	  gain,
  //	  i.frames_transmitted,
  //	  i.is_running ? 'y': 'n');
  //fprintf(stderr,"softover: %i. hardover: %i. HW error: %i. [last: %i]\n",
  //	  i.neurosock_overruns,
  //	  i.meata_overruns,
  //	  i.other_errors,
  //	  i.last_error_frame);
}

raw_t *srvCMOS::nextFramePlease(raw_t *dst) {
  //fprintf(stderr,"[dbg] srvCMOS::nextframeplease\n");
  if (dst==0)
    dst=buf;

  // closed-loop delay testing variables
  short DAC1=512;  // CL testing
  short DAC2=512;  // CL testing


  try{
     unsigned char b0[readSize];

     //while(true){ // CL testing *********************************************************************

     memset(&b0,0,sizeof(b0));

     int len=0; int sum=0; int dst_index=0;

     //fprintf(stderr," readSize %i\n",(readSize));

      // Ask for a frame of data and then read it from TCP/IP server here.
 
      /* start receiving data using ThreadedServer (CMOS) */
      char cmd[64]; memset(&cmd,0,sizeof(cmd));
      int  n = sprintf (cmd, "stream %3.1f\n",readTime);
      send_command( data_sock, cmd );
      /*ret = send(data_sock,cmd,n,0);
      if(ret<0) {
      	perror("error streaming data ");
      	throw SysErr("srvCMOS","");
      } */





      // get data using old server or ThreadedServer
      while(sum<readSize){
   	//len = recv(data_sock, b0, sizeof(b0)-sum, 0); // 1 byte per sample in CMOS (MCCard gives 2 bytes per sample)
   	len = recv_answer(data_sock, b0, sizeof(b0)-sum); // 1 byte per sample in CMOS (MCCard gives 2 bytes per sample)
  	if (len<0) 
  	  throw SysErr("srvCMOS","Read failed");
  	else if (len == 0){
	  throw SysErr("srvCMOS","Read failed"); // add a throw statement to exit cleanly?
   	}

	int start=sum;
	int end  =sum+len;
	if( sum==0 ){
		start+=8;
		end   =len;
		frameno=(int)b0[0]+ \
			(int)b0[1]*256+ \
			(int)b0[2]*256*256+ \
			(int)b0[3]*256*256*256+ \
			(int)b0[4]*256*256*256*256+ \
			(int)b0[5]*256*256*256*256*256+ \
			(int)b0[6]*256*256*256*256*256*256+ \
			(int)b0[7]*256*256*256*256*256*256*256;
        frameno -= SERVER_FRAMENO_OFFSET;
		if( frameno-frameno_last > readSamples){ 
			num_frameno_errors++;		
			fprintf(stderr,"srvCMOS:: Frameno:%lli (%0.3fsec)\tMissed %lli samples (%imsec)! (Not sent by server.)  Num errors so far: %i.\n", frameno, (float)(frameno/1./CMOS_FREQHZ),frameno-frameno_last,(int)((frameno-frameno_last)/FREQKHZ),num_frameno_errors); 
		}
		else if ( frameno-frameno_last < readSamples){
			num_frameno_errors++;
			fprintf(stderr,"srvCMOS:: Frameno:%lli (%0.3fsec)  \tLower frameno than expected, difference is %lli samples! Num errors so far: %i.\n", frameno, (float)(frameno/1./CMOS_FREQHZ),frameno-frameno_last,num_frameno_errors); 
			if(sms++==5){
				//fprintf(stderr,"srvCMOS:: sending sms  %i.\n", sms); 
 				//system("echo \"Recording stopped...\" | /usr/sbin/sendmail 0787238678@sms.ethz.ch"); // send me an sms error message!
			}
		}
		frameno_last = frameno;
		//fprintf(stderr,"frameno  %lli\n",frameno);
	}

        // fill dst  -- use low res DAC settings (8bit)
/*   	for(int j=start; j<end; j++ ){ 
		int recv_index = j-sum; 
		if(      (j-8)%CMOS_BYTEPERSAMPLE==128 )
		  dst[dst_index-2] = (short)(b0[recv_index])*16; // DAC1 encoding (overwrite/assign to channel 126)
		else if( (j-8)%CMOS_BYTEPERSAMPLE==129 )
		  dst[dst_index-1] = (short)(b0[recv_index])*16; // DAC2 encoding (overwrite/assign to channel 127)
		else if( (j-8)%CMOS_BYTEPERSAMPLE==130 ) {}// DAC 1 & 2 high res encoding (9th & 10th bits for each) (not used yet - see bug tracker)
		else{
 		  dst[dst_index] = (short)(b0[recv_index])*16;// convert to 12 bit for consistency with default Meabench settings
		  dst_index++;
		}
	} ///*/////
        // fill dst  -- use high res DAC settings (10bit)
   	for(int j=start; j<end; j++ ){ 
		int recv_index = j-sum; 
		if(      (j-8)%CMOS_BYTEPERSAMPLE==128 ){
		  dst[dst_index-2] = (short)(b0[recv_index])*4; // DAC1 encoding (overwrite/assign to channel 126) (MSB? in 10bit data)
                  DAC1=(short)(b0[recv_index])*4; // CL testing
		}else if( (j-8)%CMOS_BYTEPERSAMPLE==129 ){
		  dst[dst_index-1] = (short)(b0[recv_index])*4; // DAC2 encoding (overwrite/assign to channel 127)
                  DAC2=(short)(b0[recv_index])*4; // CL testing
		}else if( (j-8)%CMOS_BYTEPERSAMPLE==130 ) {// DAC 1 & 2 high res encoding (9th & 10th bits for each) (not used yet - see bug tracker)
		  DAC1 += (short)((b0[recv_index] & 0x3)*256*4);       // CL testing  // DAC1 LSB
		  DAC2 += (short)(((b0[recv_index] & 0xC)>>2)*256*4);  // CL testing  // DAC2 LSB
                  dst[dst_index-2] += (short)((b0[recv_index] & 0x3)*256*4);       // DAC1 LSB
		  dst[dst_index-1] += (short)(((b0[recv_index] & 0xC)>>2)*256*4);  // DAC2 LSB
		  //fprintf(stderr,"1::%x:%i\t2::%x:%i\n",b0[recv_index] & 0x3,(b0[recv_index] & 0x3)*256,   (b0[recv_index] & 0xC)>>2,   (b0[recv_index] & 0xC)>>2);

                 /* if(DAC1>600*4){ // CL testing
                      frameno1=frameno;
                      //fprintf(stderr,"DAC1 %i   time %f\n",DAC1,frameno1); // CL testing

		      //% input 0)chipaddress, 1)dacselection, 2)channel, 3)volt/curr(digi), 4)pulsephase(samples), 5)epoch, 6)epoch sign (1 -> negative) 7)delay[msec] 8)stim mode[previous==0; volt==1; curr==2]
		      //uint16_t stimulation[] = {htons(chipaddress),htons(dacselection),htons(channel),htons(voltdigi),htons((ceil(phase/50))),htons(epoch),htons(0),htons(delay),htons(stim_mode)};
                      uint16_t stimulation[] = {htons(4),            htons(0),           htons(108),     htons(0),    htons(2),                 htons(5),  htons(0), htons(0),    htons(1)};
                      int ret = send(fpga_sock,&stimulation,sizeof(stimulation),0);
                      //perror("stim");
                      //fprintf(stderr,"sent stim. fpgasock %i  ret %i\n",fpga_sock,ret); // CL testing
                  }
                  if(DAC2>600*4){ // CL testing
                      frameno2=frameno;
                      if(frameno1!=0 && frameno2-frameno1>0){
                          fprintf(stderr,"%i\n",(frameno2-frameno1)/20); // CL testing
                          frameno1=0;
                      }
                  } ///*////

                  

		}else{
 		  dst[dst_index] = (short)(b0[recv_index])*16;// convert to 12 bit for consistency with default Meabench settings
		  dst_index++;
		}
	}
   	sum+=len;
   	//fprintf(stderr,"sum %i  b %s\n",sum,b0);
  	//if(i_now%100==0 ) fprintf(stderr,"  %i  b[0]%hi  dst[0]%hi   j %i\n",i_now,(short)b0[38],dst[38],sum);
     }//*///
     totaldata+=sum;
     //fprintf(stderr,"  %i  sum:%i  dst_index:%i totaldata:%li   \n",i_now,sum,dst_index,totaldata);


     if(i_now%500==0) {
    	gettimeofday(&t_end,NULL);
    	t_end.tv_sec -= t_start.tv_sec;
    	if(t_end.tv_usec < t_start.tv_usec){
 	   t_end.tv_sec--;
	   t_end.tv_usec += 1000000;
    	}
    	t_end.tv_usec -= t_start.tv_usec;

   	//fprintf(stderr," %i   sum %i  totaldata %li ",i_now,sum,totaldata);
   	//fprintf(stderr,"  Frameno:%lli  Time: %ld.%06ld",frameno, t_end.tv_sec, t_end.tv_usec);
     	//fprintf(stderr,"\n");
     	//fflush(stderr);
     	//fprintf(stderr,"  %i  dst[0]%i   \n",i_now,(int)dst[38]);
     }
     i_now ++;

     //}// end while(true)    CL testing **************************************************************

  }catch ( ... ) { fprintf(stderr,"[dbg] ThreadedServer read error\n");  }

  return buf;
}

void srvCMOS::setChannelList(long long excludeChannels, long long doubleChannels) {
  if (excludeChannels!=0 || doubleChannels!=0)
    fprintf(stderr,"srvCMOS: Warning: channel list ignored\n");
}
