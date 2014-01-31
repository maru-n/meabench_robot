#include <iostream>
#include <unistd.h>
#include <cstring>


#include "TCPDataServer.h"

TCPDataServer::TCPDataServer()
{
    setuped = false;
    connected = false;
}

TCPDataServer::~TCPDataServer() {
    disconnect();
    close(srcSocket);
}

bool TCPDataServer::setup(int _port)
{
    port = _port;
    memset(&srcAddr, 0, sizeof(srcAddr));
    srcAddr.sin_port = htons(port);
    srcAddr.sin_family = AF_INET;
    srcAddr.sin_addr.s_addr = htonl(INADDR_ANY);

    srcSocket = socket(AF_INET, SOCK_STREAM, 0);

    int ret;
    ret = bind(srcSocket, (struct sockaddr *) &srcAddr, sizeof(srcAddr));
    if ( ret != 0 )
    {
        std::cerr << "TCPDataServer::setup() :faild of bind()." << std::endl;
        return false;
    }
    ret = listen(srcSocket, 1);
    if ( ret != 0 )
    {
        std::cerr << "TCPDataServer::setup() :faild of listen()." << std::endl;
        return false;
    }
    setuped = true;
    return true;
}

bool TCPDataServer::startListening()
{
    if ( !isSetuped() )
    {
        std::cerr << "TCPDataServer::startListening() :This Server is not setuped. please call setup() before startListening()." << std::endl;
        return false;
    }
    if (pthread_attr_init(&attr))
    {
        std::cerr << "TCPDataServer::setup() :Cannot create thread attributes." << std::endl;
        return false;
    }
    if (pthread_create(&thread, &attr, &TCPDataServer::listening_thread_code, (void *)this))
    {
        std::cerr << "TCPDataServer::setup() :Cannot create thread." << std::endl;
        return false;
    }
    return true;
}

bool TCPDataServer::disconnect()
{
    if ( !isConnected() )
    {
        return true;
    }
    int ret;
    ret = close(dstSocket);
    if ( ret != 0 )
    {
        std::cerr << "TCPDataServer::disconnect() :faild to close the socket." << std::endl;
        return false;
    }
    connected = false;
    std::cout << "TCPDataSever::disconnect(): socket is disconnected." << std::endl;
    return true;
}

int TCPDataServer::getPort()
{
    return port;
}

int TCPDataServer::getClientPort()
{
    return ntohs(dstAddr.sin_port);
}
std::string TCPDataServer::getClientAddress()
{
    return inet_ntoa(dstAddr.sin_addr);
}

bool TCPDataServer::send(std::string message)
{
    if( !isConnected() ) {
        std::cerr << "TCPDataServer::startListening() :This Server is not connected." << std::endl;
        return false;
    }
    write(dstSocket, message.c_str(), message.size());
    return true;
}

bool TCPDataServer::sendRawMsg(const char *rawMsg, const int numBytes)
{
    return sendRawBytes(rawMsg, numBytes);
}

bool TCPDataServer::sendRawBytes(const char *rawBytes, const int numBytes)
{
    if( !isConnected() ) {
        std::cerr << "TCPDataServer::startListening() :This Server is not connected." << std::endl;
        return false;
    }
    write(dstSocket, rawBytes, numBytes);
    return true;
}

int TCPDataServer::getNumReceivedBytes()
{
    std::cerr << "TCPDataServer::receive() :this method is not implemented." << std::endl;
    return -1;
}

std::string TCPDataServer::receive()
{
    char tmpBuff[TCP_MAX_MSG_SIZE+1];
    int messageSize = receiveRawBytes(tmpBuff, TCP_MAX_MSG_SIZE);
    std::string ret;
    if(messageSize==0){
        ret = "";
    }else if(messageSize<TCP_MAX_MSG_SIZE) {
        // null terminate!!
        tmpBuff[messageSize] = 0;
        ret = tmpBuff;
    }

    return ret;
}

int TCPDataServer::receiveRawMsg(char *receiveBytes,  int numBytes)
{
    std::cerr << "TCPDataServer::receiveRawMsg() :this method is not implemented." << std::endl;
    return -1;
}

int TCPDataServer::receiveRawBytes(char *receiveBytes,  int numBytes)
{
    if( !isConnected() ) {
        std::cerr << "TCPDataServer::receiveRawBytes() :This Server is not connected." << std::endl;
        return -1;
    }
    if (dstSocket == -1 ) {
        std::cerr << "TCPDataServer::receiveRawBytes() :invalid socket error." << std::endl;
        return(-1);
    }
    int ret = recv(dstSocket, receiveBytes, numBytes, 0);

    /*
    if(ret==-1) {
        std::cerr << "TCPDataServer::receiveRawBytes() :receive data error." << std::endl;
        return -1;
    }
    */
    return ret;
}

void *TCPDataServer::listening_thread_code(void *arg)
{
    TCPDataServer *me = (TCPDataServer *)arg;

    std::cout << "Waiting for connection ..." << std::endl;
    int dstAddrSize = sizeof(me->dstAddr);
    me->dstSocket = accept(me->srcSocket, (struct sockaddr *) &me->dstAddr, (socklen_t *)&dstAddrSize);
    me->connected = true;

    //set non-blocking socket
    int val = 1;
    ioctl(me->dstSocket, FIONBIO, &val);

    std::cout << "Connected from " << me->getClientAddress() << ":" << me->getPort() << std::endl;
    pthread_exit(0);
    //std::cout << "Connected from " << me->getClientAddress() << ":" << me->getPort() << std::endl;
    return 0;
}
