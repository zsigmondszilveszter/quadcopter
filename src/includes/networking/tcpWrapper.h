/*
    Szilveszter Zsigmond 18.09.2018
*/
#ifndef _TCP_WRAPPER_H    /* Guard against multiple inclusion */
#define _TCP_WRAPPER_H

#define _DEFAULT_SOURCE
#include <pthread.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>


#define LISTEN_BACKLOG  50
#define SERVER_IP   "192.168.1.200"
#define SERVER_PORT     1988

#define TCP_WORKER_NR 1

extern int tcp_socket;
extern struct sockaddr_in peer_addr;

typedef struct ThreadPackages {
    int socket;
    char serial;
    char msg[50];
} ThreadPackage;

extern pthread_t tcpWorkerThreads[TCP_WORKER_NR];
extern ThreadPackage packages[TCP_WORKER_NR];

int startNetworkServer();
int tcpWorker(void * ptr);
void printSocketErrno();

#endif // _TCP_WRAPPER_H
