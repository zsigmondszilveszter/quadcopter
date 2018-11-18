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

#include "tools.h"
#include "intervalTimer.h"
#include "pololu_imu_v5.h"
#include "lsm6ds33.h"
#include "lis3mdl.h"
#include "state_machine.h"


/************************** Global Variables *****************************/
double begin_time;



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
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
void finiteStateMachineOneStep(long long index){
    finiteState_measure(index);
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
void finiteState_measure(long long index){
    // calculate and print elapsed time from previous measure
    // measureAndPrintRealTime(begin_time);
    // begin_time = startRealTimeMeasure();

    // measure
    lsm6ds33_measure(index);
    lis3mdl_measure(index);
    // printf("%lld: A_x: %6d,   A_y: %6d,   A_z: %6d,   G_x: %6d,   G_y: %6d,   G_z: %6d,   Magnm x: %6d,   Magnm y: %6d,   Magnm z: %6d,   Temp: %.1f C\n", index, accel.x, accel.y, accel.z, gyro.x, gyro.y, gyro.z, magnm.x, magnm.y, magnm.z, temperature);
}