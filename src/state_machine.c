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
    printf("%lld: A_x: %d,   A_y: %d,   A_z: %d,   G_x: %d,   G_y: %d,   G_z: %d,   Temp: %.1f C,  Magnm x: %d ,   Magnm y: %d,    Magnm z: %d\n", index, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, temperature, magnm_x, magnm_y, magnm_z);
}