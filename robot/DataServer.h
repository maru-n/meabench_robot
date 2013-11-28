#pragma once

#include <string>

class DataServer
{
public:
    virtual bool setup(int _port) = 0;
    virtual bool startListening() = 0;
    //void setMessageDelimiter(string delim);
    virtual bool disconnect() = 0;

    virtual bool isSetuped(){ return setuped; };
    virtual bool isConnected(){ return connected; }

    virtual int getPort() = 0;
    virtual int getClientPort() = 0;
    virtual std::string getClientAddress() = 0;

    virtual bool send(std::string message) = 0;
    virtual bool sendRawMsg(const char* rawMsg, const int numBytes) = 0;
    virtual bool sendRawBytes(const char *rawBytes, const int numBytes) = 0;

    virtual int getNumReceivedBytes() = 0;

    virtual std::string receive() = 0;
    virtual int receiveRawMsg(char *receiveBytes,  int numBytes) = 0;
    virtual int receiveRawBytes(char *receiveBytes,  int numBytes) = 0;

protected:
    bool connected;
    bool setuped;
};
