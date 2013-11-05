// DB May 2006

#ifndef CLEANLITE_H
#define CLEANLITE_H

//#include "../Tools.H"

int cleanlite(float *context)
{
  // returns 1 if clean spike, 0 if dirty spike
  int ctx;

  // Drop at Salpa's blank edge
  if( context[0]==0 && context[1]==0 && context[2]==0 && context[3]==0 && \
      context[4]==0 && context[5]==0 && context[6]==0 && context[7]==0  )
    return( 0 );

  // subtract dc
  float mfirst=0; for( ctx=0; ctx<15;ctx++ ) mfirst+=context[ctx];
  float mlast =0; for( ctx=60;ctx<74;ctx++ ) mlast +=context[ctx];
  float vfirst=0; for( ctx=0; ctx<15;ctx++ ) vfirst+=(context[ctx]*context[ctx]);
  float vlast =0; for( ctx=60;ctx<74;ctx++ ) vlast +=(context[ctx]*context[ctx]);
  vfirst-=mfirst*mfirst/15;
  vlast -=mlast*mlast/14;
  mfirst/=15;  mlast/=14;
  vfirst/=14;  vlast/=13;
  float dc=(mfirst*vlast+mlast*vfirst)/(vfirst+vlast+1e-10);
  for( ctx=0;ctx<74;ctx++ ) context[ctx]-=dc;
  
//  float peak =abs(context[24]);
//  float peak2=abs(context[25]);
//  if( peak2>peak ) peak = peak2;
//  for( ctx=5; ctx<22;ctx++ )
//    if( abs(context[ctx])>peak ) return( 0 );
//  for( ctx=28;ctx<45;ctx++ )
//    if( abs(context[ctx])>peak ) return( 0 );   
  float peak =context[24];
  float peak2=context[25];
  if( peak2*peak2>peak*peak ) peak = peak2; // if abs(peak2) > abs(peak)
  for( ctx=5; ctx<22;ctx++ )
    if( context[ctx]*context[ctx]>peak*peak ) return( 0 );
  for( ctx=28;ctx<45;ctx++ )
    if( context[ctx]*context[ctx]>peak*peak ) return( 0 );
  return( 1 );
}


#endif
