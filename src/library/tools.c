/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-13
*
******************************************************************************/

/***************************** Include Files *********************************/
#include <time.h>
#include <sys/time.h>
#include <stdio.h>
#include <errno.h>


/* ************************************************************************** */
/** CPU time
/* ************************************************************************** */
clock_t startTimeMeasure(){
    return clock();
}

/* ************************************************************************** */
/** return the elapsed time from startTime in milisec in CPU time
/* ************************************************************************** */
double measureTime(clock_t startTime){
    clock_t end = clock();
    return (double)(end - startTime) / CLOCKS_PER_SEC * 1000;
}

/* ************************************************************************** */
/** print to standard output the elapsed time from startTime in milisec in CPU time
/* ************************************************************************** */
void measureAndPrintTime(clock_t startTime){
    printf("Time elapsed: %0.6f\n", measureTime(startTime));
}

/* ************************************************************************** */
/** Wall time
/* ************************************************************************** */
double getRealClock(){
    struct timeval time;
    if (gettimeofday(&time,NULL)){
        //  Handle error
        return 0;
    }
    return (double)time.tv_sec * 1000000 + (double)time.tv_usec;
}

/* ************************************************************************** */
/** Wall time
/* ************************************************************************** */
double startRealTimeMeasure(){
    return getRealClock();
}

/* ************************************************************************** */
/** return the elapsed time from startTime in milisec in Real time
/* ************************************************************************** */
double measureRealTime(double startTime){
    double end = getRealClock();
    return (double)(end - startTime) / 1000;
}

/* ************************************************************************** */
/** print to standard output the elapsed time from startTime in milisec in Real time
/* ************************************************************************** */
void measureAndPrintRealTime(double startTime){
    printf("Time elapsed: %0.6f msec\n", measureRealTime(startTime));
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
void printErrno(){
    fprintf(stderr, "Something went wrong, the error code is %i\n", errno);
}