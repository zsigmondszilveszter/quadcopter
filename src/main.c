
/*
    Szilveszter Zsigmond 29.12.2017
*/
#include "general_header.h"
#include "tcp_networking.h"
#include "thread_handler.h"


int main(){
    printf("//----------------------------\n//   Welcome to the Board\n//----------------------------\n");
    // init
    thread_counter = 0;
    networking();

    // waits and blocks the execution of program until all the threads finish their work//
    wait_threads_to_finish();
    return 0;
}
