// DB 2006
// Collection of spike analysis tools.


#ifndef TOOLS_H
#define TOOLS_H



// Functions

int   hw2cr(int hw);
int   cr2hw(int cr);
int   cleanlite( float *context);
short context2probe(  float *context, bool NI_DAQ, bool CMOS);
short context2epoch(  float *context, bool NI_DAQ, bool CMOS);
short context2height( float *context, int factor);
//float median(float *context, int start, int end); // use from CMOSServerTools.H instead
float dc_offset(float * context);

#include "sub/context2height.c"
#include "sub/context2probe.c"
#include "sub/context2epoch.c"
#include "sub/cleanlite.c"
#include "sub/dc_offset.c"
#include "sub/cr2hw.c"
#include "sub/hw2cr.c"


// Data Structures

struct CATform { 
   unsigned long long time;           // CAT time [s]
   short              epoch;          // epoch
   short              probeHW;        // probe hardware channel
   short              catx[1000];     // CAT.X component
   short              caty[1000];     // CAT.Y component
   short              activity[1000]; // summed activity(mass): Center of Mass = ( m1*d1 + m2*d2 + ... ) / ( m1+m2+... )
 };
typedef struct CATform CATform;

struct FRHform { 
   unsigned long long time;          // CAT time [s]
   short              epoch;         // epoch
   short              probeHW;       // probe hardware channel
   short              frh[60][1000]; // CAT.X component
 };
 typedef struct FRHform FRHform;  

struct SPIKEform { 
    unsigned long long time;      // time  
    unsigned long long latency;   // latency 
    unsigned long long probetime; // probe time
    short              channel;   // channel
    short              height;    // height
    short              width;     // width
    short              threshold; // threshold
    short              epoch;     // epoch
    short              clid;      // clean spike id
    short              pts;       // precise timed spike
    short              probeHW;   // probe hardware channel
    unsigned long      probenum;  // probe number
  };
  typedef struct SPIKEform SPIKEform;


struct COMPACTform { 
    unsigned long long time;      // time  
    unsigned long long latency;   // latency 
    short              channel;   // channel
    short              probeHW;   // probe hardware channel
  };
  typedef struct COMPACTform COMPACTform;

// Classes

// /////////////////////////////////////////////
// try out class to store large matrices (3 dim)
// http://www.parashift.com/c++-faq-lite/freestore-mgmt.html#faq-16.17
 template<typename T> class Matrix3 {
 public:
   Matrix3(unsigned x0, unsigned x1, unsigned x2) : n0_ (x0), n1_ (x1), n2_ (x2) {
     if (x0 == 0 || x1 == 0 || x2 == 0)
       throw BadSize();
     data_ = new T[x0*x1*x2];
   }
   class BadSize { };        // Throws a BadSize object if a size is zero
  
   // Based on the Law Of The Big Three:
  ~Matrix3(){ delete[] data_; }
   Matrix3(const Matrix3<T>& m);
   Matrix3<T>& operator= (const Matrix3<T>& m);
 
   // Access methods to get the (i,j) element:
   T&       operator() (unsigned x0, unsigned x1, unsigned x2){
     if( x0>=n0_ || x1>=n1_ || x2>=n2_ ){// throw BoundsViolation();
        //fprintf(stderr,"Matrix3::%i %i %i   %i %i %i\n",(int)x0,(int)x1,(int)x2,(int)n0_,(int)n1_,(int)n2_); 
        throw BoundsViolation();
     }
     return data_[ (x0*n1_+x1)*n2_+x2 ];
   }  
   const T& operator() (unsigned x0, unsigned x1, unsigned x2) const {
     if( x0>=n0_ || x1>=n1_ || x2>=n2_ ){
        //fprintf(stderr,"Matrix3::%i %i %i   %i %i %i\n",(int)x0,(int)x1,(int)x2,(int)n0_,(int)n1_,(int)n2_); 
        throw BoundsViolation();
     }
     return data_[ (x0*n1_+x1)*n2_+x2 ];
   }
   class BoundsViolation { };// These throw a BoundsViolation object if i or j is too big
 
 private:
   unsigned n0_, n1_, n2_;
   T* data_;
 };
 
#endif
