/*
    Szilveszter Zsigmond 17.09.2018
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#include "tcpWrapper.h"


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
}

int tcpWorker(void * ptr){
    ThreadPackage* pkg = (ThreadPackage*) ptr;

    socklen_t peer_addr_size = sizeof(struct sockaddr_in);

    int incoming_socket, len;
    char buffer[500] = {0};
    while( 1 ){ // accept new connections in loop if a previous one is closed 
        //--------------------------------------------------------------------------
        // waiting for connections
        //--------------------------------------------------------------------------
        printf(">> thread.%d is listening and accepting new incoming TCP socket connections.\n", pkg->serial);
        incoming_socket = accept(tcp_socket, (struct sockaddr *) &peer_addr, &peer_addr_size);
        if( incoming_socket < 0 ){
            switch(errno){
                case EBADF: fprintf(stderr, "tcp_socket is not an open file descriptor\n");break;
                case ENOTSOCK: fprintf(stderr, "The file descriptor tcp_socket does not refer to a socket.\n");break;
                default: fprintf(stderr, "Something went wrong with socket accepting, the error code is %i\n", errno);break;
            }
            return -1;
        }

        while( 1 ){
            memset(buffer, 0, sizeof buffer); // flush buffer in every cycle
            // waiting for incoming packet, the read command blocks the thread until a packet arrive
            len = recv(incoming_socket, buffer, 500, 0);
            if(len < 0){
                // if buffer length is less than 0 something went wrong
                switch(errno){
                    case EAGAIN: fprintf(stderr, "The socket is marked nonblocking and the receive operation...\n");break;
                    case EBADF: fprintf(stderr, "The argument sockfd is an invalid file descriptor.\n");break;
                    case ECONNREFUSED: fprintf(stderr, "A remote host refused to allow the network connection (typically because it is not running the requested service).\n");break;
                    case EFAULT: fprintf(stderr, "The receive buffer pointer(s) point outside the process's address space.\n");break;
                    case EINTR: fprintf(stderr, "he receive was interrupted by delivery of a signal before any data were available;\n");break;
                    case EINVAL: fprintf(stderr, "Invalid argument passed.\n");break;
                    case ENOMEM: fprintf(stderr, "Could not allocate memory for recvmsg().\n");break;
                    case ENOTCONN: fprintf(stderr, "The socket is associated with a connection-oriented protocol and has not been connected\n");break;
                    case ENOTSOCK: fprintf(stderr, "The file descriptor sockfd does not refer to a socket.\n");break;
                    default: fprintf(stderr, "Something went wrong with receiving messages, the error code is %i\n", errno);break;
                }
                close(incoming_socket);
                return -1;
            } else if(len == 0){
                // an empty packet indicates that the client closed the connection
                close(incoming_socket);
                printf("<< Connection closed on thread %d\n", pkg->serial);
                break;
            } else {
                printf("------------------------\n");
                printf("Incoming message: %s\n", buffer);
            }
        }
    }
    return 0;
}