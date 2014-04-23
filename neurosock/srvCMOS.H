// Modified from srvMCMeata.H to call and recieve data and configurations from the HiDens server application. 
// Douglas Bakkum

#ifndef SRVCMOS_H
#define SRVCMOS_H

#include "srvMeata.H"
#include "Error.H"
#include <common/Config.H>
#include <common/CMOSServerTools.H>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


const int CMOS_FREQHZ = FREQKHZ * 1000;
const int CMOS_BYTEPERSAMPLE = 131;
const int SERVER_FRAMENO_OFFSET = MCC_FILLBYTES / sizeof(raw_t) / TOTALCHANS + 1; // This number is subtracted from frameno in order to align frameno's in recorded meabench data files and recorded ntk files. No one analyzed the cause of the offset. 


class srvCMOS: public srvMeata {
public:
  srvCMOS() throw(Error);
  srvCMOS(const char * ip, int port) throw(Error);
  virtual ~srvCMOS();
  virtual void start();
  virtual void stop();
  virtual void init();
  virtual void reset();
//  virtual void setGain(); // not implemented for CMOS user input - hard coded currently
  virtual void setSlot(int n); // user input slot
  virtual void setGain(int n);
  //virtual void setCHN(int n); // MC64 or MC128
  virtual void fillInfo(NS_Info &);
  virtual raw_t *nextFramePlease(raw_t *dst=0);
  virtual void setChannelList(long long excludeChannels, long long doubleChannels);
  virtual int getCHN() const { return chn; }
  void getGain(); // read gain from server
private:
  int     fpga_sock; // CL testing
  int     data_sock;
  const char *  data_ip;   // so that can input via cmdgui
  int     data_port; // so that can input via cmdgui
  int     frameno1,frameno2; // CL testing
  int     mcc_fd;
  int     chn;
  int     slot; // slot where CMOS array is plugged
  long long int frameno;
  long long int frameno_last;
  bool isrunning;  // is streaming data from server
  bool isconnected;// connection to server for date
  int readSize;    // 
  int readSamples; // number of samples (# cmos 'frames') per meabench frame
  float readTime;  // (12.8ms) time in msec to fill readSize

  raw_t *buf;
  raw_t *temp;        // debug
  long int totaldata; // debug
  struct timeval t_start,t_end; // debug
  int num_frameno_errors;

  float adc_range;
  float adc_res;
  //float dac_range;
  //float dac_res;
  //float gain;

  int sms;

};

#endif


