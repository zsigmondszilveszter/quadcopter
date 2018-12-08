/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-11-13
*
* Finite-state machine
*
******************************************************************************/

/***************************** Include Files *********************************/
#include <stdio.h>
#include <stdlib.h>
#include <semaphore.h>

#include "tools.h"
#include "intervalTimer.h"
#include "pololu_imu_v5/pololu_imu_v5.h"
#include "pololu_imu_v5/lsm6ds33.h"
#include "pololu_imu_v5/lis3mdl.h"
#include "bmp180/bmp180.h"
#include "state_machine.h"


/************************** Global Variables *****************************/
double begin_time;
long long i = 0;


/* ************************************************************************** */
/** 
/* ************************************************************************** */
void initFiniteStateMachine(){
    printf("Finite State Machine Started.\n");

    // Init sensors
    initSensors();

    // Init interval timer
    initTimer();

    // Start the interval timer
    begin_time = startRealTimeMeasure();
    startTimer();
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
void initSensors(){
    // inits
    init_pololu_v5();
    init_bmp180();
}

/* ************************************************************************** */
/** timer fired event handler
/* ************************************************************************** */
void finiteStateMachineOneIteration(){
    // start measuring
    finiteState_measure();
    // wait for the results
    sem_wait(&sem_PololuMeasureDone);
    sem_wait(&sem_Bmp180MeasureDone);
    // new measurements are ready
    // printf("%lld: A_x: %6d,   A_y: %6d,   A_z: %6d,   G_x: %6d,   G_y: %6d,   G_z: %6d,   Magnm x: %6d,   Magnm y: %6d,   Magnm z: %6d,   Temp: %.1f C\n", i, accel.x, accel.y, accel.z, gyro.x, gyro.y, gyro.z, magnm.x, magnm.y, magnm.z, temperature);
    i++;
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
void finiteState_measure(){
    // calculate and print elapsed time from previous measure
    // measureAndPrintRealTime(begin_time);
    // begin_time = startRealTimeMeasure();

    // let the pololu start to measure
    sem_post(&sem_startPololuMeasure);

    // let the bmp180 start to measure
    sem_post(&sem_startBmp180Measure);
}