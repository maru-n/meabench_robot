#include "TCPDataServer.h"
#include <iostream>
#include <sstream>


void start_listening(DataServer* server)
{
    server->startListening();
}


int main()
{
    DataServer* server = new TCPDataServer();
    server->setup(12345);
    start_listening(server);

    unsigned char* receivedDataBuffer = (unsigned char *)malloc(TCP_MAX_MSG_SIZE);

    while(true) {
        if(server->isConnected()) {
            int receivedSize = server->receiveRawBytes((char *)receivedDataBuffer, TCP_MAX_MSG_SIZE);
            if (receivedSize == 0) {
                std::cout << "disconected" << std::endl;
                start_listening(server);
            }else{
                std::stringstream ss;
                ss << "test" << std::endl;
                server->send(ss.str());
            }
        }
    }
    std::cout << "end" << std::endl;
}
