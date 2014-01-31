
#include "StimSrv.h"

StimSrv::StimSrv()
{
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr,PTHREAD_CREATE_DETACHED);
    pthread_mutex_init(&mtx, NULL);
    threadData.deq = &deq;
    threadData.mtx = &mtx;
}

StimSrv::~StimSrv(){
    //closeServer();
    //deq.clear();
//    pthread_cancel(thread);
//    pthread_mutex_destroy(&mtx);
}

void *StimSrv::thread_func(void *arg){

    threadData_t *threadData = (threadData_t*)arg;
    deque<StimData> *pDeque = threadData->deq;
    char stmsg[128];

    while(true){
        if(pDeque->size()>0){
            pthread_mutex_lock(threadData->mtx);
            StimData *stimData = &pDeque->front();
            send(threadData->fpga_sock, &stimData->stimulation, sizeof(stimData->stimulation), 0);
            memset(&stmsg, 0, sizeof(stmsg));
            recv(threadData->fpga_sock, stmsg, sizeof(stmsg), 0);
            fprintf(stderr,"Stimulation reply :: %i\n",(stmsg[0]<<8) + stmsg[1]);
            //cout << stimData->stimulation[2] << "\n";
            pDeque->pop_front();
            pthread_mutex_unlock(threadData->mtx);
            //usleep(STIM_INTERVAL);
        }
   }
}

void StimSrv::connectServer(){
    threadData.fpga_sock = connect_server(STIM_TCP_ADDR, STIM_TCP_PORT);
}

void StimSrv::closeServer(){
    close_server(threadData.fpga_sock);
    pthread_cancel(thread);
}

void StimSrv::setup(){
    connectServer();
    pthread_create(&thread, &attr, thread_func, (void *)&threadData);
    //pthread_join( thread, NULL );
}

void StimSrv::sendStim(int dac, int channel){
    StimData sData;
    sData.stimulation[1] = htons(dac);
    sData.stimulation[2] = htons(channel);
    send(threadData->fpga_sock, &stimData->stimulation, sizeof(stimData->stimulation), 0);

//    StimData sData;
//    sData.stimulation[1] = htons(dac);
//    sData.stimulation[2] = htons(channel);
//
//    pthread_mutex_lock(threadData.mtx);
//    threadData.deq->push_back(sData);
//    pthread_mutex_unlock(threadData.mtx);
}
