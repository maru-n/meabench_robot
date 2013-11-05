// modified by Douglas Bakkum 2009
/* common/Types.H: part of meabench, an MEA recording and analysis tool
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

// Types.H

#ifndef TYPES_H

#define TYPES_H

#include <base/Timeref.H>


//const int NCHANS = 60; //:n NCHANS
const int NCHANS = 126; // DB ........................
/*:D Number of electrode channels. */

//const int TOTALCHANS = 64; //:n TOTALCHANS
const int TOTALCHANS = 128; // DB ....................................
const int TOTALELCS  = 11016;
/*:D Total channels, incl. the four analog channels. */

////const int DIGIPERUV = 2048/341; //:n DIGIPERUV
/////*:D Conversion factor between microvolts and digital values:
////	 digital = DIGIPERUV * voltage_in_microvolts. */

typedef short raw_t; //:t raw_t
/*:D Type of raw data, i.e. single channel samples. */

typedef float real_t; //:t real_t
/*:D Representation for real numbers used throughout this software. */

typedef unsigned char byte;

class Sample { //:C Sample
  /*:D Sample is the representation of single samples from the hardware.
       It contains 60 electrode raw values, and 4 analog channel raw values.
  */
public:
  raw_t const &operator[](int i) const { return data[i]; } //:f operator[]
  raw_t &operator[](int i) { return data[i]; } //:f operator[]
  /*:D Read from the sample.
   *:A i: hardware channel number
   *:R value of specified channel.
   *:N Both const and non-const versions of this function exist.
   *:E Out of range arguments may cause segfault or garbage return.
   */
  Sample &operator+=(Sample const &o) { for (int c=0; c<TOTALCHANS; c++) data[c]+=o.data[c]; return *this; }
  Sample &operator*=(float o) { for (int c=0; c<TOTALCHANS; c++) data[c]=raw_t(data[c]*o); return *this; }
  void settoint(raw_t n) { for (int c=0; c<TOTALCHANS; c++) data[c]=n; }
  void setelctoint(raw_t n) { for (int c=0; c<NCHANS; c++) data[c]=n; }
private:
  raw_t data[TOTALCHANS];
};

const int PRECTXT = 25; //:n PRECTXT
//:D PRECTXT is the number of samples in Spikeinfo's context before the peak
const int POSTCTXT = 49; //:n POSTCTXT
//:D PRECTXT is the number of samples in Spikeinfo's context after the peak

struct Spikeinfo { //:C Spikeinfo
  /*:D A Spikeinfo is a description of a single spike event. It contains
       the time at which the spike occurred (in terms of the "sloppyfifo time"
       of the raw data stream), the channel number, height and width, and
       (optionally) context (i.e. a chunk of raw data from the channel
       collected around the spike).
     . Context is not stored in the Spikeinfo by the low level spike
       detectors. Rather, it is added by generic code a (very short)
       while later through SpkDet::addcontext. Users should be aware that
       context may not be valid when this call hasn't yet been made.
  */
  timeref_t time; //:d time
  short channel; //:d channel
  raw_t height; //:d height
  short width; //:d width
  raw_t context[PRECTXT+POSTCTXT]; //:d context
  /*:D Raw data collect PRECTXT samples before through POSTCTXT after
       the peak of the spike, from the spiking channel only. */
  raw_t threshold; //:d threshold
  /*:D Spike detectors that use variable thresholds can store the current
       threshold here. As of 7/13/01, only AdaFlt exploits this. */
};

inline bool operator<(Spikeinfo const &a, Spikeinfo const &b) {
  if (a.time<b.time)
    return true;
  else if (a.time>b.time)
    return false;
  return a.channel<b.channel;
}

#endif
