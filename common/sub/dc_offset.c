// DB May 2009
//
// Use analog context to determine epoch.
//

#ifndef DCOFFSET_H
#define DCOFFSET_H

//#include "../Tools.H"
#include <math.h>


float dc_offset(float * context){
// do same DC offset as used in plotspikecontext.m  from Meabench
 float first=0, last=0;
 for( int i=0;i<15;i++ )
	first+=context[i];
 for( int i=60;i<74;i++ )
	last +=context[i];

 float mean1 = first/15;
 float mean2 =  last/14;

 float var1=0, var2=0; // variance
 for( int i=0;i<15;i++ )
	var1+=(context[i]-mean1)*(context[i]-mean1);
 for( int i=60;i<74;i++ )
	var2+=(context[i]-mean2)*(context[i]-mean2);

 var1 = var1/15;
 var2 = var2/14;

 return( (mean1*var2+mean2*var1)/(var1+var2+0.000000001) ); 
}


#endif
