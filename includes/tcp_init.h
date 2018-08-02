/*
    Szilveszter Zsigmond 2018.06.24
*/

#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#define LISTEN_BACKLOG 50

#define SERVER_IP "192.168.1.200"
#define SERVER_PORT 1988

int tcp_socket;
struct sockaddr_in peer_addr;

int init_tcp(void);
