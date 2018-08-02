/*
    Szilveszter Zsigmond 31.12.2017
*/
#include "general_header.h"
#include "tcp_init.h"
#include "tcp_networking.h"

int networking(){
    //--------------------------------------------------------------------------
    // init TCP socket
    //--------------------------------------------------------------------------
    tcp_socket = init_tcp();
    if( tcp_socket < 0 ){
        return -1;
    }
    //--------------------------------------------------------------------------
    // create new threads
    //--------------------------------------------------------------------------
    iret[thread_counter] = pthread_create( &thread[thread_counter], NULL, (void *) listening_for_new_connection, "1");
    thread_counter++;

    iret[thread_counter] = pthread_create( &thread[thread_counter], NULL, (void *) listening_for_new_connection, "2");
    thread_counter++;
}

int listening_for_new_connection(void * ptr){
    char *message;
    message = (char *) ptr;

    socklen_t peer_addr_size = sizeof(struct sockaddr_in);

    //--------------------------------------------------------------------------
    // waiting for connections
    //--------------------------------------------------------------------------
    printf("Thread.%s is listening and accepting incoming TCP socket connections.\n", message);
    int incoming_socket = accept(tcp_socket, (struct sockaddr *) &peer_addr, &peer_addr_size);
    if( incoming_socket < 0 ){
        switch(errno){
            case EBADF: fprintf(stderr, "tcp_socket is not an open file descriptor\n");break;
            case ENOTSOCK: fprintf(stderr, "The file descriptor tcp_socket does not refer to a socket.\n");break;
            default: fprintf(stderr, "Something went wrong with socket accepting, the error code is %i\n", errno);break;
        }
        return -1;
    }

    char buffer[500] = {0};
    while( 1 ){
        memset(buffer, 0, sizeof buffer);
        int len = recv(incoming_socket, buffer, 500, 0);
        if(len < 0){
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
            printf("The connection was closed %s\n",message);
            break;
        }
        printf("------------------------\n");
        printf("Incoming message: %s\n", buffer);
    }
    return 0;
}
