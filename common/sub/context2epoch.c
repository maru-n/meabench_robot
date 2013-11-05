// DB May 2006
//
// Use analog context to determine epoch.
//

#ifndef CONTEXT2EPOCH_H
#define CONTEXT2EPOCH_H

//#include "../Tools.H"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

short context2epoch(float *context, bool NI_DAQ, bool CMOS)
{
  float cnt_epoch=0;

  if(  CMOS  ){ 
// 	for( int e=29; e<32; e++ )
//  	  cnt_epoch+=context[e];
//  	cnt_epoch=cnt_epoch/3;

//      return( (short)floor( (median(context,27,30)/16-128) + 0.5 ) ); // stopped using 091124
//  	return( (short)floor( (cnt_epoch/16-128) + 0.5 ) ); // round 'x' using 'floor( x + 0.5 )');

	int cnt=0;
	float cnt_epoch = 2048; // epoch set to 0
/*	for( int k=27; k<36; k++ ){          // started using 091124
 	  float tmp = context[k];
	  if( tmp!=2048 && tmp!=4080 ) cnt_epoch=tmp; // the width of the encoding pulse is varying, so use this instead of averaging... 2048->zero 4080->maximum
	}//*///
	for( int k=27; k<47; k++ ){          // started using 100108 -- looks at 1 ms total
 	  float tmp = context[k];
	  if( tmp!=2048 && tmp<4080 )  cnt++;  // started using 110313; was   " if( tmp!=2048 && tmp!=4080 )  cnt++; "
	  if( cnt==2 )			cnt_epoch=tmp;  // The width of the encoding pulse is varying, so use this instead of averaging... 2048->zero 4080->maximum
	}						// The use of cnt avoids samples during switches in DAQ values (the transient is sometimes caught)

/*int ttmp=(short)(cnt_epoch/16-128);
if(ttmp==63){
	for( int k=27; k<48; k++ ){    
 	  float tmp = context[k];
	  if( tmp!=2048 && tmp!=4080 ) cnt_epoch=tmp; 
	  printf("\t%i::%f\n",k,tmp);
	}
	  printf("\n");
//exit(0);
}//*///



	return( (short)(cnt_epoch/4-512) );      // high res DAC encoding, 100302
	//return( (short)(cnt_epoch/16-128) );   // low res DAC encoding

  }
  if( NI_DAQ ){
	for( int e=29; e<35; e++ )
    	  cnt_epoch+=context[e];
  	cnt_epoch=cnt_epoch/6;
	return( (short)floor( (cnt_epoch-32768)/480 + 0.5 ) );
  }

	for( int e=38; e<44; e++ )
	  cnt_epoch+=context[e];
	cnt_epoch=cnt_epoch/6;
	return( (short)floor( (cnt_epoch-2017)/61 + 0.5 ) ); // round 'x' using 'floor( x + 0.5 )');
}

#endif
