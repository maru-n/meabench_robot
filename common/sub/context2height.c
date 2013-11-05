// DB June 2009
//
//  Method to reconstruct signals (i.e. spike waveform) at higher sampling
//  rates based on the Nyquist-Shannon sampling theorem and the
//  Whitaker-Shannon interpolation formula.
//     context = sampled signal
//     factor  = (reconstructed sample rate) / (original sample rate)
//

#ifndef CONTEXT2HEIGHT_H
#define CONTEXT2HEIGHT_H

//#include "../Tools.H"
#include <math.h>
#include <string.h>



short context2height(float *context, int factor){


//fprintf(stderr,"context2height:: H%3i DC%3i RET%3i\n",(int)context[25],(int)(dc_offset(context)),(short)(context[25]-(int)(dc_offset(context)))  );
return( (short)(context[25]-(int)(dc_offset(context))) );


	int len      = 74;
	int zero     = 25;
	float dc_off = dc_offset(context);
	int range    = 20; // number samples around context peak to focus on

	int start=(zero-range)*factor;
	int finsh=(zero+range)*factor;


	float upsampled[len * factor];
	memset(upsampled,0,sizeof(upsampled));

	// reconstruct at 'factor' times the sampling rate
	// ~~ very slow ~~  only reconstruct around peak? -> much faster
//	int cnt=0;
//	for( int u=0; u<len*factor; u++ ){
//	    for( int s=0;s<len;s++ ){

	for( int u=start; u<finsh; u++ ){
	    for( int s=zero-range;s<zero+range;s++ ){
	        int y=u/factor-s;
		if( y == 0 )
			upsampled[u]++;
		else
			upsampled[u]+= (context[s]-dc_off)*sin(3.1415*y)/y/3.1415; 
//			upsampled[u]+= (context[s]-context[zero-range])*sin(3.1415*y)/y/3.1415; 
//			upsampled[cnt]+= (context[s]-dc_off)*sin(3.1415*y)/y/3.1415;//
	    }
	 //   cnt++;
	}


	// find peak in reconstructed
	float peak=0;	
	for( int i=start;i<finsh; i++ ){
		//int v=upsampled[i]+context[zero-range]-dc_off;
		int v=(int)round(upsampled[i]);
		if( fabs(v)>fabs(peak) ) peak=v;
	}
//	for( int i=0;i<range*factor*2 + 1; i++ ){
//		int v=(upsampled[peak*len + i - range*factor]);
//		if( fabs(v)>fabs(peak) ) peak=v;
//	}

	return( (short)peak );
}

#endif
