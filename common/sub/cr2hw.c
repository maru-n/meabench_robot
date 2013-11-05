// DB May 2006

#ifndef CR2HW_H
#define CR2HW_H

//#include "../Tools.H"
#include <math.h>

int cr2hw(int cr)
{
        int r=cr%10;
	double c=floor( (double)(cr/10) );
	int conversion[8][8] = {
	  { 60, 23, 25, 28,  31, 34, 36, 61 },
	  { 20, 21, 24, 29,  30, 35, 38, 39 },
	  { 18, 19, 22, 27,  32, 37, 40, 41 },
	  { 15, 16, 17, 26,  33, 42, 43, 44 },
	  
	  { 14, 13, 12,  3,  56, 47, 46, 45 },
	  { 11, 10,  7,  2,  57, 52, 49, 48 },
	  {  9,  8,  5,  0,  59, 54, 51, 50 },
	  { 62,  6,  4,  1,  58, 55, 53, 63 }
	};
	return( conversion[r-1][(int)c-1] );
}

#endif
