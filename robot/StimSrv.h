
#ifndef ____StimSrv__
#define ____StimSrv__

#include <iostream>
#include <unistd.h>
#include <stdio.h>
#include <pthread.h>
#include <deque>
#include <common/CMOSServerTools.H>
#include <common/CMOSTools.H>

#define STIM_INTERVAL 10000 //micro second

class StimSrv
{
public:
    StimSrv();
    ~StimSrv();
    void connectServer();
    void closeServer();
    void setup();
    void sendStim(int dac, int channel);
    void sendStim(int dac, int channel, int voltage);

private:
    static void *thread_func(void *);
    
    class StimData
	{
    private:
        // experiment variables
        int chipaddress;// "slot" where chip is plugged [0-4]
        int dacselection;// 0->DAC1  1->DAC2
        int channel;// channel ID to stim
        int volt;// [+/-mV; millivolt]   [current: 0 to 450 allowed -->> 0 to +/-4.12uA ONLY! for low current mode]
        int stim_mode;// [previous==0; voltage==1; current==2]
        int phase;// [us; microseconds]
        int delay;// [0->10,000; milliseconds] delay until stimulating sent to fpga (can change limits in test.c)
        int epoch;// [0->512] for high res DAC encoding          was [0->127] for low res
        
	public:
        uint16_t stimulation[9];
        
        StimData(){
            //default setup of experiment variables
            chipaddress         =    4;     // "slot" where chip is plugged [0-4]
            dacselection        =    0;     // 0->DAC1  1->DAC2
            channel             =  127;     // No stim by default
            volt                = 900;     // [+/-mV; millivolt]   [current: 0 to 450 allowed -->> 0 to +/-4.12uA ONLY! for low current mode]
            stim_mode           =    1;     // [previous==0; voltage==1; current==2]
            phase               =  100;    	// [us; microseconds]
            delay               =    0;     // [0->10,000; milliseconds] delay until stimulating sent to fpga (can change limits in test.c)
            epoch               =    0;     // [0->512] for high res DAC encoding          was [0->127] for low res
            
            stimulation[0] = htons(chipaddress);
            stimulation[1] = htons(dacselection);
            stimulation[2] = htons(channel);
            stimulation[3] = htons(ceil(volt/2.9));
            stimulation[4] = htons((ceil(phase/50)));
            stimulation[5] = htons(0);
            stimulation[6] = htons(0);
            stimulation[7] = htons(delay);
            stimulation[8] = htons(stim_mode);
        }
	};
    
    typedef struct {
        deque<StimData> *deq;
        pthread_mutex_t* mtx;
        int fpga_sock;
    }threadData_t;
    
    threadData_t threadData;
    pthread_t thread;
    pthread_attr_t attr;
    deque<StimData> deq;
    pthread_mutex_t mtx;
};


#endif /* defined(____StimSrv__) */
