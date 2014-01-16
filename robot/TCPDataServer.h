#pragma once

#include <string>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>


#include "DataServer.h"

#define BUFFER_SIZE 256
#define TCP_MAX_MSG_SIZE 512

class TCPDataServer: public DataServer
{
public:
    TCPDataServer();
    ~TCPDataServer();

    bool setup(int _port);
    //void setMessageDelimiter(string delim);
    bool startListening();
    bool disconnect();

    int getPort();
    int getClientPort();
    std::string getClientAddress();

    bool send(std::string message);
    bool sendRawMsg(const char* rawMsg, const int numBytes);
    bool sendRawBytes(const char *rawBytes, const int numBytes);

    int getNumReceivedBytes();

    std::string receive();
    int receiveRawMsg(char *receiveBytes,  int numBytes);
    int receiveRawBytes(char *receiveBytes,  int numBytes);

private:
    static void *listening_thread_code(void *);

    unsigned short port;
    int srcSocket;
    int dstSocket;
    struct sockaddr_in srcAddr;
    struct sockaddr_in dstAddr;

    pthread_t thread;
    pthread_attr_t attr;
    /*
    int numrcv;
    char buffer[BUFFER_SIZE];
    */
};
