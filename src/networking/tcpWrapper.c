/*
    Szilveszter Zsigmond 17.09.2018
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>

#include "networking/tcpWrapper.h"
#include "pololu_imu_v5/lsm6ds33.h"
#include "pololu_imu_v5/lis3mdl.h"

/**
 * networking variables
 */
int tcp_socket;
struct sockaddr_in peer_addr;
pthread_t tcpWorkerThreads[TCP_WORKER_NR];
ThreadPackage packages[TCP_WORKER_NR];


//--------------------------------------------------------------------------
// Create socket and bind it to interface which is configured with 
// the above IP address and then return it
//--------------------------------------------------------------------------
int init_tcp(){
    struct sockaddr_in server_address;

    // create the socket
    int tcp_socket = socket(AF_INET, SOCK_STREAM, 0|IPPROTO_TCP);
    if(tcp_socket < 0){
        switch(errno){
            case EACCES: fprintf(stderr, "Permission to create a socket of the specified type and/or protocol is denied.\n"); break;
            default: fprintf(stderr, "Something went wrong with socket creation, the error code is %i\n", errno);break;
        }
        close(tcp_socket);
        return -1;
    }

    // configure the socket
    int enable = 1;
    if (setsockopt(tcp_socket, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int)) < 0)
        fprintf(stderr, "setsockopt(SO_REUSEADDR) failed");

    // bind the socket to an IP address - an IP which is belonging to this machine
    memset(&server_address, 0, sizeof(struct sockaddr_in));
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(SERVER_PORT);
    inet_aton(SERVER_IP, &server_address.sin_addr);

    if(bind(tcp_socket,(struct sockaddr *) &server_address, sizeof(struct sockaddr_in)) < 0){
        switch(errno){
            case EACCES: fprintf(stderr, "Permission to create a socket of the specified type and/or protocol is denied.\n"); break;
            case EADDRINUSE: fprintf(stderr, "The given address for binding is already in use.\n"); break;
            default: fprintf(stderr, "Something went wrong with socket binding, the error code is %i\n", errno);break;
        }
        close(tcp_socket);
        return -1;
    }

    // put the socket into listening state
    if( listen(tcp_socket, LISTEN_BACKLOG) < 0){
        switch(errno){
            case EADDRINUSE: fprintf(stderr, "Another socket is already listening on the same port.\n"); break;
            default: fprintf(stderr, "Something went wrong with socket listening, the error code is %i\n", errno);break;
        }
        close(tcp_socket);
        return -1;
    }

    return tcp_socket;
}

void printSocketErrno(){
    fprintf(stderr, "Something went wrong with socket connection, the error code is %i\n", errno);
}

//--------------------------------------------------------------------------
// 
//--------------------------------------------------------------------------
int startNetworkServer(){
    
    tcp_socket = init_tcp();
    if( tcp_socket < 0 ){
        return -1;
    }

    // create new threads
    for(char i=0; i<TCP_WORKER_NR; i++){
        packages[i].socket = tcp_socket;
        packages[i].serial = i;
        
        pthread_create( &tcpWorkerThreads[i], NULL, (void *) tcpWorker, &packages[i]);
    }
    return 0;
}

//--------------------------------------------------------------------------
// 
//--------------------------------------------------------------------------
int tcpWorker(void * ptr){
    ThreadPackage* pkg = (ThreadPackage*) ptr;

    socklen_t peer_addr_size = sizeof(struct sockaddr_in);

    int incoming_socket, len;
    char buffer[100] = {0};
    char bytes_to_transfer = 0;
    while( 1 ){ // accept new connections in loop if a previous one is closed 
        // waiting for connections
        printf(">> thread.%d is listening and accepting new incoming TCP socket connections.\n", pkg->serial);
        incoming_socket = accept(tcp_socket, (struct sockaddr *) &peer_addr, &peer_addr_size);
        if( incoming_socket < 0 ){
            printSocketErrno();
            return -1;
        }

        // 
        while( 1 ){
            usleep(100000);
            // memset(buffer, 0, sizeof buffer); // flush buffer in every cycle

            memcpy(buffer,      &accel, 6);
            memcpy(buffer+6,    &gyro, 6);
            memcpy(buffer+12,   &magnm, 6);

            bytes_to_transfer = 9 * 2;

            if (fcntl(incoming_socket, F_GETFD) < 0){
                break;
            }
            if( send(incoming_socket, buffer, bytes_to_transfer, 0) < 0){
                if ( errno == 104){
                    // Connection reset by peer
                    break;
                } else {
                    printSocketErrno();
                    return -1;
                }
            }
        }
    }
    return 0;
}
