/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-11-17
*
* Interval Timer Source File
* This timer provide the interval for system cyclic functioning
*
******************************************************************************/


/***************************** Include Files *********************************/
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <time.h>
#include <errno.h>

#include "library/tools.h"
#include "timing/intervalTimer.h"
#include "state_machine.h"

/************************** Definitions *****************************/
// #define TIMER_INTERVAL 100000000 // nanosec => 100ms
// #define TIMER_INTERVAL 50000000  // nanosec => 50ms
#define TIMER_INTERVAL 20000000  // nanosec => 20ms
// #define TIMER_INTERVAL 10000000  // nanosec => 10ms
// #define TIMER_INTERVAL 5000000   // nanosec => 5ms
// #define TIMER_INTERVAL 3000000   // nanosec => 3ms
#define CLOCKID CLOCK_REALTIME
#define SIG SIGRTMIN        // linux realtime signal MIN,  see the "Real-time signals" section of signal(7) man page 


/************************** Global Variables *****************************/
timer_t intervalTimerID;
struct sigaction sa;
struct sigevent se;
struct itimerspec its;


/* ************************************************************************** */
// 
/* ************************************************************************** */
void initTimer(){
    /* Establish handler for timer signal */
    sa.sa_flags = SA_SIGINFO;
    sa.sa_sigaction = timerExpiredHandler;
    sigemptyset(&sa.sa_mask);
    if (sigaction(SIG, &sa, NULL) == -1){
        // return value is not 0, print the error and exit
        printf("sigaction error\n");
        printErrno();
        exit(errno);
    }

    /* Create the timer */
    se.sigev_notify = SIGEV_SIGNAL;
    se.sigev_signo = SIG;
    se.sigev_value.sival_ptr = &intervalTimerID;
    if ( timer_create(CLOCKID, &se, &intervalTimerID) ){
        // return value is not 0, print the error and exit
        printf("timer_create error\n");
        printErrno();
        exit(errno);
    }
    printf(">> Interval Timer created, timerid: %d\n", (int)intervalTimerID);
}

/* ************************************************************************** */
// Handle the signal sent by system at Timer expiration 
/* ************************************************************************** */
void timerExpiredHandler(int sig, siginfo_t *si, void *uc){
    timer_t *tidp;
    tidp = si->si_value.sival_ptr;
    if ( *tidp == intervalTimerID){
        // timer fired signal event
        // one tick for finite state machine
        finiteStateMachineOneIteration();
    }
}


/* ************************************************************************** */
// Start the timer
/* ************************************************************************** */
void startTimer(){
    its.it_value.tv_sec = 0;
    its.it_value.tv_nsec = TIMER_INTERVAL;
    its.it_interval.tv_sec = its.it_value.tv_sec;
    its.it_interval.tv_nsec = its.it_value.tv_nsec;
    if (timer_settime(intervalTimerID, 0, &its, NULL) == -1){
        // return value is not 0, print the error and exit
        printf("timer_settime error\n");
        printErrno();
        exit(errno);
    }
}


/* ************************************************************************** */
// 
/* ************************************************************************** */
void stopTimer(){
    its.it_value.tv_sec = 0;
    its.it_value.tv_nsec = 0;
    its.it_interval.tv_sec = 0;
    its.it_interval.tv_nsec = 0;
    if (timer_settime(intervalTimerID, 0, &its, NULL) == -1){
        // return value is not 0, print the error and exit
        printf("timer_settime error\n");
        printErrno();
        exit(errno);
    }
}


/* ************************************************************************** */
// 
/* ************************************************************************** */
void deleteTimer(){
    timer_delete(intervalTimerID);
}
