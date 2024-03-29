/* spikesrv/SD_Butter_Detect.C: part of meabench, an MEA recording and analysis tool
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

// To be included by SD_Butter.C only. Not to be compiled stand alone

#ifndef SD_BUTTER_C
#error SD_Butter_Detect to be included by SD_Butter.C only.
#endif


#if SHOW
void SD_Butter::detectrowsshow(timeref_t start, timeref_t end,
				RawSFSrv *rawdest) {
#else
void SD_Butter::detectrows(timeref_t start, timeref_t end) {
#endif
  // The beauty of the highpass filtering is that it kills all DC components,
  // and some of the 60Hz noise.
  // Should I try a filter with nicer sidelobes? Later vsn perhaps...
////  bool fixedvar = start>=constant_variance_from;
  timeref_t t0 = 0;//src.first(); // db
#if SHOW
  timeref_t t_dest = rawdest->latest();
#endif
  for (timeref_t t=start; t<end; t++) {
    Sample const &s = src[t];
#if SHOW
    Sample &rdst = (*rawdest)[t_dest++];
#endif
    detect_analog(t,s);
    for (int c=0; c<NCHANS; c++) {
      float y = butter[c](lowpass[c](s[c]));
#if SHOW
      rdst[c] = raw_t(y);
#endif
      float y2 = y*y;
      if (inspike[c]) { // in a spike
	if (negvspike[c]) { // it's a downward spike
	  if (y<spikeheight[c]) {
	    spikeheight[c] = short(y);
	    spikepeak[c] = t;
	  } else if (y2 < thresh2s[c]*.7) {
	    // Dropping out of spike, push it onto fifo
	    Spikeinfo &si(dst[dst.latest()]);;
	    si.channel = c;
	    si.time = spikepeak[c] - t0;
	    si.width = t - spikestart[c];
	    si.height = spikeheight[c];
	    if (exclude.test(c))
	      dst.donewriting(1);
	    inspike[c] = false;
	  }
	} else { // it's an upward spike
	  if (y>spikeheight[c]) {
	    spikeheight[c] = short(y);
	    spikepeak[c] = t;
	  } else if (y2<thresh2s[c]*.7) {
	    // Dropping out of spike, push it onto fifo
	    Spikeinfo &si(dst[dst.latest()]);;
	    si.channel = c;
	    si.time = spikepeak[c] - t0;
	    si.width = t - spikestart[c];
	    si.height = spikeheight[c];
	    if (exclude.test(c))
	      dst.donewriting(1);
	    inspike[c] = false;
	  }
	}
      } else { // not in a spike
	if (y2>thresh2s[c]) { // new spike
	  inspike[c] = true;
	  spikestart[c] = t;
	  spikeheight[c] = short(y);
	  spikepeak[c] = t;
	  negvspike[c] = y<0;
	}
      }
    }
  }
#if SHOW
  rawdest->donewriting(end-start);
#endif
}
