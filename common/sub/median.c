// DB April 2009

#ifndef MEDIAN_H
#define MEDIAN_H

//#include "../Tools.H"
#include <iostream>
#include <algorithm>
#include <vector>
#include <stdio.h>
using namespace std;


float median(float *context, int start, int end)
{  

  int size=end-start;
  if(size<1){
	fprintf(stderr,"median.c: Bad indices to array\n");
	return( 0 );
  }
  
  float myarray[size];
  for( int i=start;i<end;i++ ){
  	myarray[i-start]=context[i];
  }

  vector<float> myvector (myarray,myarray+size);   
  sort(myvector.begin(), myvector.end());

  vector<float>::iterator it;
  it=myvector.begin()+(int)(size/2);
  float ret= *it;
  //fprintf(stderr,"%i \n",ret);
  return( ret );
}

#endif
