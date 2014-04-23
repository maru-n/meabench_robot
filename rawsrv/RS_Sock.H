// modified by Douglas Bakkum 2009
/* rawsrv/RS_Sock.H: part of meabench, an MEA recording and analysis tool
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

// RS_SOCK.H

#ifndef RS_SOCK_H

#define RS_SOCK_H

#include <rawsrv/RawSource.H>
//#include <neurosockCMOS/Defs.H> ///// DB
#include <neurosock/Defs.H> ///// DB

class RS_Sock: public RS_Base {
private:
  //static const int RSS_QUANTUM = 256; /////// DB
  static const int RSS_QUANTUM = 64; /////// DB

//  static const int RSS_FREQKHZ = 25;
  static const int RSS_FREQKHZ = 20;  ////////// DB
public:
  RS_Sock(int gainsetting, int slotsetting) throw(Error);
  ~RS_Sock();
  virtual unsigned int read(Sample *dst, unsigned int amount) throw(Error);
  virtual SFAux::HWStat status() throw(Error);
  virtual void start() throw(Error);
  virtual void stop();
  void reportInfo(bool live=false) throw(Error);
  void refreshInfo() throw(Error);
  void connect();
  virtual void setChannels(long long excludeChannels,
			   long long doubleChannels) throw(Error);
  //virtual void setCMOSSlot(int slot); // db
  virtual SFAux::SourceInfo sourceInfo() const;
public:
  inline static int quantum() { return RSS_QUANTUM; }
  static int ngains() { return RANGES; }
  static real_t range(int gain) { return (gain>=0 && gain<RANGES) ? RANGE[gain] : 0; }
  static char const *identify();
  // Ryan made the following static, which they shouldn't be, really
  static void setHostAddress(string const &ipadr);
  static void setPort(int const &aport);
  static string const &hostAddress() { return hostaddress; }
  static int hostPort()  { return port; }
  NS_Info info;
private:
  void readHeader() throw(Error);
  void sendCommand(NS_Command::NS_Cmd cmd, long long arg=0) throw(Error);
  NS_Info::NS_Reason readUntilInfo() throw(Error);
  inline void readFrame(Sample *dst) throw(Error);
  static string hostaddress;
  static int port;
private:
  int fd;
  int running;
  bool connected;
private:
  static const int RANGES=4;
  static const real_t RANGE[RANGES];
};

typedef RS_Sock RawSource;

#endif
