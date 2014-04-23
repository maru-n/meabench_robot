// modified by Douglas Bakkum 2009
/* scope/QScope.C: part of meabench, an MEA recording and analysis tool
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

// QScope.C

#include <stdio.h>

#include "QScope.H"
#include <base/minmax.H>

#define FILLEDREGION 1

#include <qpointarray.h>
#include <qpainter.h>

#include <sys/socket.h>//db
#include <netinet/in.h>//db
#include <arpa/inet.h>//db


QScope::QScope(QWidget *parent, QGraph *ctrlr):
  QGraph(parent, ctrlr), qpa(0) {
  setCenter(0); setExtent(300);
  setGuideSpacing(125);
  nspikes = 0;
  //dbx("QScope constructor");
}

QScope::~QScope() {

  // delete point array
  if (qpa)
    delete qpa;
}

void QScope::mouseDoubleClickEvent(QMouseEvent *qme) {
  if (qme->state() & Qt::ControlButton)
    dumpme();
  else
    QGraph::mouseDoubleClickEvent(qme);
}

void QScope::setSource(QSSource const &qss0) {
  qss = qss0;
  forall(&QScope::setSource,qss0);
  //update();
}

void QScope::setLength(timeref_t length) {
  qss.length = length;
  forall(&QScope::setLength,length);
  update();
}

void QScope::setPreTrig(timeref_t pretrig) {
  qss.pretrig = pretrig;
  forall(&QScope::setPreTrig,pretrig);
  update();
}

void QScope::setCenter(raw_t centr) {
  center = centr;
  forall(&QScope::setCenter,centr);
  //update();
}

void QScope::setCenter() {
  if (qss.sf && qss.endtime>0) {
    double sum = 0;
    timeref_t starttime = (qss.endtime<qss.length) ?
      0 : (qss.endtime-qss.length);
    for (timeref_t t=starttime; t<qss.endtime; t++) 
      sum += (*qss.sf)[t][qss.channel];
    center = raw_t(sum/(qss.endtime-starttime));
  } else {
    center = 0;
  }
  centers[qss.channel]=center;
  forall(&QScope::setCenter,center);
  //update();
}


void QScope::setCenter_hw(int hw) {
  if (qss.sf && qss.endtime>0) {
    double sum = 0;
    timeref_t starttime = (qss.endtime<qss.length) ?
      0 : (qss.endtime-qss.length);
    for (timeref_t t=starttime; t<qss.endtime; t++) 
      sum += (*qss.sf)[t][hw];
    center = raw_t(sum/(qss.endtime-starttime));
  } else {
    center = 0;
  }
  centers[hw]=center; 
  //update();
}

void QScope::setOffset(){ // DC offsets via server program
    //fprintf(stderr,"DC Offset not yet implemented on ThreadedServer\n");
    //return;
    for(int hw=0;hw<TOTALCHANS;hw++)
    	QScope::setCenter_hw(hw);
    int slot = qss.sf?qss.sf->aux()->sourceinfo.slot:4;
    dc_offset(slot, centers);
}


void QScope::connectCMOSserver(){
  //fprintf(stderr,"NOT connecting to server\n");
  //return;
  /* connect to the ThreadedServer */
  //while( (data_sock=connect_server(SERVER_ADDR,SERVER_PORT)) <= 0 ){
  //    fprintf(stderr,"Waiting for server.\n");
  //    sleep(3);
  //};

//  printf("QScope::connectCMOSServer    ip %s   port %i\n", qss.sf->aux()->sourceinfo.data_ip, qss.sf->aux()->sourceinfo.data_port); /// accessing sourceinfo for dataip or dataport does not work, causes segfault........
 // const char * ip  = qss.sf?qss.sf->aux()->sourceinfo.data_ip:SERVER_ADDR;
 // int port   = qss.sf?qss.sf->aux()->sourceinfo.data_port:SERVER_PORT;
 // printf("QScope::connectCMOSServer    ip %s   port %i\n", ip, port);
 // data_sock=connect_server( ip, port );
  data_sock=connect_server(SERVER_ADDR,SERVER_PORT);
  send_client_name(data_sock,"scope");
  fprintf(stderr,"Openning server socket (%i).\n",data_sock);
}
void QScope::closeCMOSserver(){
  fprintf(stderr,"Closing server socket (%i).\n",data_sock);
  // close socket */
  close_server(data_sock);
}

void QScope::setArrange(){

  //fprintf(stderr,"arrange:: server sock = %i\n",data_sock);
  //fprintf(stderr,"NOT USING ARRANGE\n");
  //return;

//    closeCMOSserver();
//    connectCMOSserver();

    int slot = qss.sf?qss.sf->aux()->sourceinfo.slot:4;
    fprintf(stderr,"Arranging electrode locations for slot %i on socket %i\n",slot,data_sock);

//    fprintf(stderr,"QScope::connectCMOSServer    ip %s  \n", qss.sf?qss.sf->aux()->sourceinfo.data_ip:"junk");
//    fprintf(stderr,"QScope::connectCMOSServer    port %i\n", qss.sf?:qss.sf->aux()->sourceinfo.data_port:SERVER_PORT);
    
    int ret = set_chip_slot(data_sock, slot);
    if( ret == -2 ){
	fprintf(stderr,"Resetting connection.\n");
	closeCMOSserver();
	connectCMOSserver();
	fprintf(stderr,"Connection reset.\n");
	//setArrange(); // try again
    }

    int elcdbg[NCHANS];
    for( int i=0;i<NCHANS;i++ )
	elcdbg[i]=elc[i];
    int junkx[TOTALCHANS],junky[TOTALCHANS];
    ch2el_mapping(data_sock,elc,x0s,y0s,junkx,junky);
}

void QScope::setExtent(int ext) {
  //  fprintf(stderr,"QScope:setextent    ");
  //  sdbx("QScope(%p)::setExtent %i",this,ext);
  extent = raw_t(ext/uvpd());
  forall(&QScope::setExtent,ext);
  update();
  //  sdbx("(%p)-> extent=%i",this,extent);
}

void QScope::setSpeedy(int s) {
  speedy = (enum SpeedyMode)s;
  update();
}

void QScope::setGuideSpacing(int spc) {
  //  fprintf(stderr,"QScope:setfuidespacing   ");
  guide_spacing = raw_t(spc/uvpd());
  forall(&QScope::setGuideSpacing,spc);
  update();
}
  
void QScope::resizeEvent(QResizeEvent *qre) {
  QGraph::resizeEvent(qre);
  halfhei = hei/2;
  coffset = yoffset + halfhei;
  if (qpa)
    delete qpa;
  qpa = new QPointArray(wid*2); // can be just wid for avg plot only vsn
  //  int t = qss.sf ? qss.sf->latest() : -1;
  //  sdbx("QScope(%p) wid=%i hei=%i qpa=%p [qss.sf=%p, latest=%i]",this,wid,hei,qpa,qss.sf,t);
}

float QScope::uvpd() {
  if (qss.channel<NCHANS)
    return qss.sf?qss.sf->aux()->sourceinfo.uvperdigi:.1667;
  else
    return qss.sf?qss.sf->aux()->sourceinfo.aux_mvperdigi:(.1667*1.2);
}

void QScope::refresh(timeref_t t) {
  if (t) {
    qss.endtime = t;
    nspikes = 0;
  }
  QPainter qp(this);
  erase(contentsRect());
  drawContents(&qp);
  //drawContents_box(&qp);
  forall(&QScope::refresh,t); // for satellites i think
}

void QScope::refresh_all(timeref_t t) {// DB modification, extracted from refresh
  if (t) {
    qss.endtime = t;
    nspikes = 0;
  }
  QPainter qp(this);
  drawContents_all(&qp);
  //drawContents_together(&qp);
}

void QScope::refresh_together(timeref_t t) {// DB modification, extracted from refresh
  if (t) {
    qss.endtime = t;
    nspikes = 0;
  }
  QPainter qp(this);
  //drawContents_all(&qp);
  erase(contentsRect());
  drawContents_together(&qp);
  forall(&QScope::refresh_together,t); // for satellites i think
}

void QScope::erasetrace() {// DB modification, extracted from refresh
  erase(contentsRect());
  forall(&QScope::erasetrace);
}

void QScope::drawContents_together(QPainter *qp) {
  ////copied from  void QScope::drawContents(QPainter *qp) {
  QGraph::drawContents(qp);
 for( int hw=0; hw<TOTALCHANS; hw++){
 
  if (!qss.sf)
    return;
  
  if (qss.endtime>0) {
    // let's draw trace.
    /* I *assume* that there are more data points than pixels, but even if
       this is not so, I think this should be OK. */
    qp->setPen(trace_pen);
    qp->setBrush(trace_pen.color());
    timeref_t starttime = (qss.endtime>qss.length)?(qss.endtime-qss.length):0;
    int tlength = qss.endtime-starttime;
    //int twidth = wid * tlength/qss.length;
    int twidth = wid * tlength/qss.length;
    int lastend;
    timeref_t time;
 
   if (controller || speedy!=AvgOnly) {
      // I am a satellite or not speedy
      // -- collect max line --
      lastend = 0;
      time = starttime;
      int x_end = 2*twidth-1;
      raw_t maxv=(*qss.sf)[time][hw];
      for (int x=0; x<twidth; x++) {
	raw_t max=(*qss.sf)[time][hw];
	int nextend = (x+1)*tlength/twidth;
	//	int n=nextend-lastend;
	for (; lastend<nextend; lastend++)
	  maxIs(max, (*qss.sf)[time++][hw]);
	qpa->setPoint(x_end-x, x+xoffset, (4096-max+50)*hei/(4096+100));
	//qpa->setPoint(x, x+xoffset, (max+5)*hei/(256+10));
	maxIs(maxv,max);
      }
      // -- collect min line --
      lastend=0; time = starttime; 
      raw_t minv=(*qss.sf)[time][hw];
      for (int x=0; x<twidth; x++) {
	raw_t min=(*qss.sf)[time][hw];
	int nextend = (x+1)*tlength/twidth;
	//	int n=nextend-lastend;
	for (; lastend<nextend; lastend++)
	  minIs(min, (*qss.sf)[time++][hw]);
	qpa->setPoint(x, x+xoffset, (4096-min+50)*hei/(4096+100));
	//qpa->setPoint(x, x+xoffset, (min+5)*hei/(256+10));
	minIs(minv,min);
      }

//if(!hw) fprintf(stderr,"twidth:%i tlenth:%i qss.lenth:%i x_end:%i value:%i\n",twidth,tlength,qss.length,x_end,minv);  

      // -- draw it --    // db  need to send qp for allgraphs also, use graphptrs offsets and apply to draw functions
      //fprintf(stderr,"%i ",maxv-minv);
      if (x0s[hw]<100){}	// do not plot channels that are not connected
      else if (speedy==MinMax) 
	qp->drawPolyline(*qpa,0,x_end);
      else
	qp->drawPolygon(*qpa,true,0,x_end);
    } else {
      // I am a speedy small QMultiGraph member
      // -- draw average line --
      lastend=0; time=starttime;
      for (int x=0; x<twidth; x++) {
	float sum=0;
	int nextend = (x+1)*tlength/twidth;
	int n=nextend-lastend;
	for (; lastend<nextend; lastend++)
	  sum += (*qss.sf)[time++][hw];
	qpa->setPoint(x, x+xoffset, (4096-raw_t(sum/n)+50)*hei/(4096+100));
	//qpa->setPoint(x, x+xoffset, (raw_t(sum/n)+5)*hei/(256+10));
	//qpa->setPoint(x, x+xoffset+x0, 0);
      }
      qp->drawPolyline(*qpa,0,twidth);
    }
  }
}// end for hw ...
}


void QScope::drawContents_all(QPainter *qp) {
  ////copied from  void QScope::drawContents(QPainter *qp) {
  //QGraph::drawContents(qp);
  for( int hw=0; hw<TOTALCHANS; hw++){
  // update channel config using center button in scope

	// cmos
    int multipl = 150;
    int x0 = int(wid/2200.*x0s[hw]); // update for this trace
    int y0 = int(hei/2200.*y0s[hw]); // update for this trace -- yoffset is defined as r.top, so this may not be right depending on qt directions of x and y
    int x1 = int(wid*multipl/2200.);
    int y1 = int(hei*multipl/2200.);
 
    //if(!hw) fprintf(stderr,"x %i %i   y %i %i   wid:%i hei:%i halfhei:%i coffset:%i extent:%i center:%i xoffset:%i yoffset:%i\n",x0,x1,y0,y1,wid,hei,halfhei,coffset,extent,centers[hw],xoffset,yoffset);
    center=centers[hw]; // update for this trace



  if (!qss.sf)
    return;
  
  if (qss.endtime>0) {
    // let's draw trace.
    /* I *assume* that there are more data points than pixels, but even if
       this is not so, I think this should be OK. */
    qp->setPen(trace_pen);
    qp->setBrush(trace_pen.color());
    timeref_t starttime = (qss.endtime>qss.length)?(qss.endtime-qss.length):0;
    int tlength = qss.endtime-starttime;
    //int twidth = wid * tlength/qss.length;
    int twidth = x1 * tlength/qss.length;
    int lastend;
    timeref_t time;
 
   if (controller || speedy!=AvgOnly) {
      // I am a satellite or not speedy
      // -- collect max line --
      lastend = 0;
      time = starttime;
      int x_end = 2*twidth-1;
      raw_t maxv=(*qss.sf)[time][hw];
      for (int x=0; x<twidth; x++) {
	raw_t max=(*qss.sf)[time][hw];
	int nextend = (x+1)*tlength/twidth;
	//	int n=nextend-lastend;
	for (; lastend<nextend; lastend++)
	  maxIs(max, (*qss.sf)[time++][hw]);
	qpa->setPoint(x_end-x, x+xoffset+x0, value2y(max)/(hei/y1)+y0);
	maxIs(maxv,max);
      }
      // -- collect min line --
      lastend=0; time = starttime; 
      raw_t minv=(*qss.sf)[time][hw];
      for (int x=0; x<twidth; x++) {
	raw_t min=(*qss.sf)[time][hw];
	int nextend = (x+1)*tlength/twidth;
	//	int n=nextend-lastend;
	for (; lastend<nextend; lastend++)
	  minIs(min, (*qss.sf)[time++][hw]);
	qpa->setPoint(x, x+xoffset+x0, value2y(min)/(hei/y1)+y0);
	minIs(minv,min);
      }
//if(!hw) fprintf(stderr,"twidth:%i tlenth:%i qss.lenth:%i x_end:%i value:%i\n",twidth,tlength,qss.length,x_end,minv);  

      // -- draw it --    // db  need to send qp for allgraphs also, use graphptrs offsets and apply to draw functions
      //fprintf(stderr,"%i ",maxv-minv);
      if (x0s[hw]<100 && hw<NCHANS){}	// do not plot channels that are not connected
      else if (maxv-minv>4000)          // do not plot rail-to-rail noisy channels
	qp->drawLine(xoffset+x0, value2y(center)/(hei/y1)+y0, xoffset+x0+x1-1, value2y(center)/(hei/y1)+y0);
      else if (speedy==MinMax) 
	qp->drawPolyline(*qpa,0,x_end);
      else
	qp->drawPolygon(*qpa,true,0,x_end);
    } else {
      // I am a speedy small QMultiGraph member
      // -- draw average line --
      lastend=0; time=starttime;
      for (int x=0; x<twidth; x++) {
	float sum=0;
	int nextend = (x+1)*tlength/twidth;
	int n=nextend-lastend;
	for (; lastend<nextend; lastend++)
	  sum += (*qss.sf)[time++][hw];
	qpa->setPoint(x, x+xoffset+x0, value2y(raw_t(sum/n))/(hei/y1)+y0);
	//qpa->setPoint(x, x+xoffset+x0, 0);
      }
      qp->drawPolyline(*qpa,0,twidth);
    }
  }

  //QGraph::drawContents(qp);
  if(wid>200){
  	qp->setClipRect(contentsRect());
  	QFont f(qp->font());
  	f.setPointSize(8);
  	qp->setFont(f);
  	qp->setPen(black_pen);
	QString shortname;
	if( hw<NCHANS )
	  	shortname = Sprintf("%i",hw);
	else
	  	shortname = Sprintf("DAC%i",hw-NCHANS+1);
  	qp->drawText(x0-15,value2y(center)/(hei/y1)+y0,shortname);
  }
}// end for hw ...
/*  qp->setPen(aux_pen); qp->setBrush(aux_pen.color()); ///////////////////////////////////
  timeref_t t0 = qss.sf->first();
  for (unsigned int i=0; i<nspikes; i++) {
    Spikeinfo const &si = spikes[i];
    int x = time2x(si.time+t0);
    qp->drawEllipse(x-2, coffset+(si.height>0?-1:1)*halfhei*7/8-2,4,4);
  }*/
}

void QScope::drawContents(QPainter *qp) {
	drawContents_box(qp);
	//fprintf(stderr,"qss.length %i   ch %i\n",qss.length,qss.channel);
}
void QScope::drawContents_box(QPainter *qp) {
  QGraph::drawContents(qp);
  if (guide_spacing) {
    // Let's draw zero line and guide lines
    qp->setPen(zero_pen);
    int yy = value2y(center);
    qp->drawLine(xoffset, yy, xoffset+wid-1, yy); 
    qp->setPen(guide_pen);
    int gs = guide_spacing;
    for (raw_t y=gs; y<extent; y+=gs) {
      int yy = value2y(center + y);
      qp->drawLine(xoffset, yy, xoffset+wid-1, yy);
      yy = value2y(center-y);
      qp->drawLine(xoffset, yy, xoffset+wid-1, yy);
    }
  }

  if (!qss.sf)
    return;
  
  if (qss.endtime>0) {
    // let's draw trace.
    // I *assume* that there are more data points than pixels, but even if
    //   this is not so, I think this should be OK. 
    qp->setPen(trace_pen);
    qp->setBrush(trace_pen.color());
    timeref_t starttime = (qss.endtime>qss.length)?(qss.endtime-qss.length):0;
    int tlength = qss.endtime-starttime;
    int twidth = wid * tlength/qss.length;
    int lastend;
    timeref_t time;
 
    if (controller || speedy!=AvgOnly) {
      // I am a satellite or not speedy
      // -- collect max line --
      lastend = 0;
      time = starttime;
      int x_end = 2*twidth-1;
      raw_t maxv=(*qss.sf)[time][qss.channel];
      for (int x=0; x<twidth; x++) {
	raw_t max=(*qss.sf)[time][qss.channel];
	int nextend = (x+1)*tlength/twidth;
	//	int n=nextend-lastend;
	for (; lastend<nextend; lastend++)
	  maxIs(max, (*qss.sf)[time++][qss.channel]);
	qpa->setPoint(x_end-x, x+xoffset, value2y(max));
	//if(qss.channel<126) 	qpa->setPoint(x_end-x, x+xoffset, value2y(max));
	//else			qpa->setPoint(x_end-x, x+xoffset, yoffset+(4095-max)*hei/4096);
	maxIs(maxv,max);
      }
      // -- collect min line --
      lastend=0; time = starttime;
      raw_t minv=(*qss.sf)[time][qss.channel];
      for (int x=0; x<twidth; x++) {
	raw_t min=(*qss.sf)[time][qss.channel];
	int nextend = (x+1)*tlength/twidth;
	//	int n=nextend-lastend;
	for (; lastend<nextend; lastend++)
	  minIs(min, (*qss.sf)[time++][qss.channel]);
	qpa->setPoint(x, x+xoffset, value2y(min));
	//if(qss.channel<126)	qpa->setPoint(x, x+xoffset, value2y(min));
	//else			qpa->setPoint(x, x+xoffset, yoffset+(4095-min)*hei/4096);
	minIs(minv,min);
      }
      // -- draw it --    // db  need to send qp for allgraphs also, use graphptrs offsets and apply to draw functions
      /*if (maxv-minv>4000)  // do not plot rail-to-rail noisy channels
	qp->drawLine(xoffset, value2y(center), xoffset+wid, value2y(center));
      else*/ if (speedy==MinMax) 
	qp->drawPolyline(*qpa,0,x_end*2);
      else
	qp->drawPolygon(*qpa,true,0,x_end*2);
    } else {
      // I am a speedy small QMultiGraph member
      // -- draw average line --
      lastend=0; time=starttime;
      for (int x=0; x<twidth; x++) {
	float sum=0;
	int nextend = (x+1)*tlength/twidth;
	int n=nextend-lastend;
	for (; lastend<nextend; lastend++)
	  sum += (*qss.sf)[time++][qss.channel];
	qpa->setPoint(x, x+xoffset, value2y(raw_t(sum/n)));
	//if(qss.channel<126)	qpa->setPoint(x, x+xoffset, value2y(raw_t(sum/n)));
	//else			qpa->setPoint(x, x+xoffset, yoffset+(4095-raw_t(sum/n))*hei/4096);
      }
      qp->drawPolyline(*qpa,0,twidth);
    }
    if (controller) {
      // draw more guide lines
      QFont f(qp->font());
      f.setPointSize(14);
      qp->setFont(f);
      qp->setPen(guide_pen);
      int timelines[4] = { 2, 10, 50, 250 };
      bool drawtl[4];
      int tlmax=0;
      for (int n=0; n<4; n++) {
	drawtl[n] = twidth * timelines[n]*FREQKHZ / tlength > 10;
	if (timelines[n]*FREQKHZ < tlength)
	  tlmax=n;
      }
      bool subtext = tlmax>0 && (twidth * timelines[tlmax-1]*FREQKHZ / tlength)>60;
      bool hundreds = tlmax>2;
      bool tens = tlmax>1;
      
      int uvlines[2] = { 10, 50 };
      bool drawuv[2];
      int uvmax=0;
      float uvpdig = uvpd();
      for (int n=0; n<2; n++) {
	drawuv[n] = halfhei * (uvlines[n]/uvpdig) / extent > 10;
	if (uvlines[n]/uvpdig < extent)
	  uvmax=n;
      }

      timeref_t t0 = qss.sf?qss.sf->first():0;
      timeref_t t = starttime - t0;
      t = timeref_t(t/(FREQKHZ*timelines[0])+.99999) * FREQKHZ*timelines[0];
      timeref_t t1 = starttime-t0+tlength;
      while (t<t1) {
	//	sdbx("Time: %.5f / starttime=%.5f t0=%.5f x=%i",t/25000.0,starttime/25000.0,t0/25000.0,time2x(t+t0));
	for (int n=0; n<4; n++) {
	  if (t % (FREQKHZ*timelines[n]) == 0) {
	    if (drawtl[n]) {
	      int x = time2x(t+t0);
	      qp->drawLine(x,0,x,10*(n+1));
	      qp->drawLine(x,hei,x,hei-10*(n+1));
	      if (n==tlmax) {
		qp->setPen(black_pen);
		char buf[100]; sprintf(buf,"%.3f",t/(1000.0*FREQKHZ));
		qp->drawText(x-40,hei-70,80,35,
			     Qt::AlignHCenter|Qt::AlignBottom,buf);
		qp->setPen(guide_pen);
	      } else if (subtext && n==tlmax-1 && t % (FREQKHZ*timelines[n+1]) != 0) {
		char buf[100];
		if (hundreds)
		  sprintf(buf,"%03i",int(t/FREQKHZ)%1000);
		else if (tens)
		  sprintf(buf,"%02i",int(t/FREQKHZ)%100);
		else
  		  sprintf(buf,"%01i",int(t/FREQKHZ)%10);
		qp->drawText(x-40,hei-70,80,35,
			     Qt::AlignHCenter|Qt::AlignBottom,buf);
	      }
	    }
	  } else {
	    break;
	  }
	}
	t+=FREQKHZ*timelines[0];
      }
      for (int uv=0; uv<uvpdig*extent; uv+=uvlines[0]) {
	for (int n=0; n<2; n++) {
	  if (uv%uvlines[n] == 0 && drawuv[n]) {
	    int y=coffset - int(uv/uvpdig * halfhei/extent);
	    qp->drawLine(0,y,10*(n+1),y);
	    qp->drawLine(wid,y,wid-10*(n+1),y);
	    if (n==uvmax) {
	      char buf[100]; sprintf(buf,"%i",uv);
	      qp->setPen(black_pen);
	      qp->drawText(wid-110,y-50,80,100,
			   Qt::AlignVCenter|Qt::AlignRight,buf);
	      qp->setPen(guide_pen);
	    } 
	    if (uv) {
	      y=coffset + int(uv/uvpdig * halfhei/extent);
	      qp->drawLine(0,y,10*(n+1),y);
	      qp->drawLine(wid,y,wid-10*(n+1),y);
	      if (n==uvmax) {
		char buf[100]; sprintf(buf,"%i",-uv);
		qp->setPen(black_pen);
		qp->drawText(wid-110,y-50,80,100,
			     Qt::AlignVCenter|Qt::AlignRight,buf);
		qp->setPen(guide_pen);
	      }
	    }
	  }
	}
      }
    }
  }
  qp->setPen(aux_pen); qp->setBrush(aux_pen.color());
  timeref_t t0 = qss.sf->first();
  for (unsigned int i=0; i<nspikes; i++) {
    Spikeinfo const &si = spikes[i];
    int x = time2x(si.time+t0);
    qp->drawEllipse(x-2, coffset+(si.height>0?-1:1)*halfhei*7/8-2,4,4);
  }
}

QGraph *QScope::make_satellite(QGraph *controller) {
  QScope *s = new QScope(0,controller);
  init_satellite(s);
  return s;
}

void QScope::init_satellite(QGraph *sat) {
  QGraph::init_satellite(sat);
  QScope *s = dynamic_cast<QScope *>(sat);
  if (!s)
    throw Error("Scope::init_satellite","Argument must be a QScope pointer");
  s->spikes = spikes;
  s->nspikes = nspikes;
  s->setSource(qss);
  s->setExtent(int(extent*uvpd()));
  s->setCenter(center);
  s->setGuideSpacing(guide_spacing);
}

void QScope::addSpike(Spikeinfo const &si) {
//  int x = time2x(si.time+qss.sf->first());
  int x = time2x(si.time);
  QPainter qpai(this);
  qpai.setPen(aux_pen); qpai.setBrush(aux_pen.color());
  qpai.drawEllipse(x-2, coffset+(si.height>0?-1:1)*halfhei*7/8-2,4,4);
  if (nspikes>=spikes.size()) 
    spikes.push_back(si);
  else 
    spikes[nspikes] = si;
  nspikes++;
  forall(&QScope::addSpike,si);
}

void QScope::dumpme() {
  timeref_t t0=qss.endtime-qss.length;
  t0-=t0%FREQKHZ;
  timeref_t t1=qss.endtime;
  t1-=t1%FREQKHZ;
  printf("\n");
  for (timeref_t t=t0; t<t1; t+=FREQKHZ) {
    printf("%8.3f",t/(FREQKHZ*1000.0));
    for (int i=0; i<FREQKHZ; i++)
      printf("%5i",(*qss.sf)[t+i][qss.channel]);
    printf("\n");
  }
}
