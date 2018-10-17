/*
    Szilveszter Zsigmond 17.09.2018
*/

#include <stdio.h>
#include "threadManager.h"
#include "tcpWrapper.h"
#include "itg3200_gyro.h"
#include "mag3110_magnm.h"


int main(){
    printf("//-------------------------------------------\n");
    printf("//   FPGA quadcopter server is running...\n");
    printf("//-------------------------------------------\n");

    startNetworkServer();

    init_itg3200();
    itg3200_measure();

    init_mag3110();
    mag3110_measure();

    // waits and blocks the execution of program until all the threads finished their work//
    waitForThreads();
    return 0;
}