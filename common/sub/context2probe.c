// DB May 2006
//
// Use analog context to find the probe channel [HW].
//

#ifndef CONTEXT2PROBE_H
#define CONTEXT2PROBE_H

//#include "../Tools.H"
#include <stdio.h>
#include <math.h>

short context2probe(float *context, bool NI_DAQ, bool CMOS)
{
  if(  CMOS  ){ 


	return( (short)((2048-context[23])/16) ); // started using 110313

//	return( (short)(context[23]) );   // started using 100108

/*  	// get probe info
  	float cnt_p=0;
  	for( int p=20; p<23; p++ )
  	  cnt_p+=context[p];
  	cnt_p=cnt_p/3;

  	// convert to HW
  	return( (short)floor( (128-cnt_p/16) + 0.5 ) ); // round 'x' using 'floor( x + 0.5 )');
*/
  }


  if( NI_DAQ ){
  	// get probe info
  	float cnt_p=0;
  	for( int p=17; p<23; p++ )
  	  cnt_p+=context[p];
  	cnt_p=cnt_p/6;

  	// convert to HW
  	return( (short)floor( (32768-cnt_p)/478.3 + 0.5 ) ); // round 'x' using 'floor( x + 0.5 )');
  }


  // get column
  float cnt_col=0;
  for( int c=8; c<14; c++ )
    cnt_col+=context[c];
  cnt_col=cnt_col/6;

  // get row
  float cnt_row=0;
  for( int r=18; r<24; r++ )
    cnt_row+=context[r];
  cnt_row=cnt_row/6;

  // convert to HW
  char probeCR[128]={""};
  sprintf(probeCR,"%1.0f%1.0f",9-(cnt_col)/255.75,9-(cnt_row)/255.75);
  int CRp=0;
  sscanf( probeCR,"%i",&CRp );

  return( (short)cr2hw(CRp));

}

#endif
