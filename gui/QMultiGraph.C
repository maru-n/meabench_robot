// modified by Douglas Bakkum 2009
// DB: modified to take 128 channels

/* gui/QMultiGraph.C: part of meabench, an MEA recording and analysis tool
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

// QMultiGraph.C

#include <stdio.h>
#include <base/dbx.H>
#include <base/Sprintf.H>
#include <qpixmap.h>

#include "QMultiGraph.H"
//#include "HexMEA.H"


QMultiGraph::QMultiGraph(QWidget *parent, char const *name, WFlags f):
  QFrame(parent, name, f),
  graphptrs(TOTALCHANS,(QGraph*)0),
  allgraphs((QGraph*)0) {
  isbox = true;
  setSizePolicy(QSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding));
  dumping = framedump = false;
}

void QMultiGraph::postConstruct() {
  dbx("Post construct");
  for (int hw=0; hw<TOTALCHANS; hw++) {
    string longname, shortname;
    if( hw<NCHANS ){
    	longname = Sprintf("Hardware channel %i",hw);
    	shortname = Sprintf("%i",hw);
    }else{
    	longname = Sprintf("DAC channel %i",hw-NCHANS+1);
    	shortname = Sprintf("DAC%i",hw-NCHANS+1);
    }
    graphptrs[hw] = constructGraph(hw);
    if (graphptrs[hw])
      graphptrs[hw]->setNameAndId(longname.c_str(), shortname.c_str());
  }
  allgraphs = constructGraph(0); // db hack 
  allgraphs->setNameAndId("All","All");
}

QMultiGraph::~QMultiGraph() {
}

void QMultiGraph::setGuidePen(QPen const &pen) {
  forall(&QGraph::setGuidePen,pen);
}

void QMultiGraph::setTracePen(QPen const &pen) {
  forall(&QGraph::setTracePen,pen);
}

void QMultiGraph::setAuxPen(QPen const &pen) {
  forall(&QGraph::setAuxPen,pen);
}

void QMultiGraph::setZeroPen(QPen const &pen) {
  forall(&QGraph::setZeroPen,pen);
}

//void QMultiGraph::setHex(bool hex) {
void QMultiGraph::setBox(bool box) {
  isbox = box;
////  setCmosLayout(box);
  resize_children(width(),height());
//  recolor_children(box);
}

void QMultiGraph::resizeEvent(QResizeEvent *qre) {
  resize_children(qre->size().width(),qre->size().height());
}

void QMultiGraph::recolor_children(bool box) {
    const QColor wht(255,255,255);
    forall(&QGraph::setBackgroundColor,wht);
}

void QMultiGraph::resize_children(int wid, int hei) {
  if(isbox){
	float dx = wid/12.; // cmos 12x11
  	float dy = hei/11.;
  	int multipl = 1;
  	for (int ch=0; ch<TOTALCHANS; ch++) {
		int iy=ch%11;//db
		int ix=floor(ch/11.);//db
		int x0 = int(dx*ix);
  	  	int y0 = int(dy*iy);
  	  	int x1 = int(dx*(ix+multipl));
  	  	int y1 = int(dy*(iy+multipl));
  	  	if (graphptrs[ch])
  	    		graphptrs[ch]->setGeometry(x0,y0,x1-x0,y1-y0);
  	}
	allgraphs->setGeometry(wid*11/12,hei*7.5/11,wid/12,hei*3.5/12);
  }else
	allgraphs->setGeometry(0,0,wid,hei);
}

void QMultiGraph::setDump(char const *fn, bool frame) {
  dumpfn = fn ? fn : "";
  dumping = fn ? true : false;
  framedump = frame;
  dumpset = 0;
  dumpframe = 0;
}

void QMultiGraph::dumpme() {
  if (dumping) {
    QPixmap p = QPixmap::grabWidget(dumpframe?parentWidget():this);
    string fn = Sprintf("%s-%02i-%04i.png",dumpfn.c_str(),dumpset,dumpframe++);
    p.save(fn.c_str(),"PNG");
  }
}

void QMultiGraph::dumpNext() {
  dumpset++;
  dumpframe=0;
}
