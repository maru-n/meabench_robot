#include "TCPDataServer.h"
#include <iostream>

int main()
{
    DataServer* server = new TCPDataServer();
    server->setup(12345);
    server->startListening();
    while(true) {
        if(server->isConnected()) {
            server->send("test");
        }
    }
}
