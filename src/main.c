/*
    Szilveszter Zsigmond 17.09.2018
*/

#include <stdio.h>
#include "threadManager.h"
#include "tcpWrapper.h"
#include "state_machine.h"


int main(){
    printf("//-------------------------------------------\n");
    printf("//   FPGA quadcopter server is running...\n");
    printf("//-------------------------------------------\n");

    startNetworkServer();

    // finite state machine
    startFiniteStateMachine();

    // waits and blocks the execution of program until all the threads finished their work//
    waitForThreads();
    return 0;
}