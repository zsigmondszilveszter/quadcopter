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
#include <unistd.h>

#include "pololu_imu_v5.h"
#include "lsm6ds33.h"
#include "lis3mdl.h"
#include "state_machine.h"

/* ************************************************************************** */
/** 
/* ************************************************************************** */
void startFiniteStateMachine(){
    printf("Hello From Finite State Machine\n");

    // Init sensors
    initSensors();
    // Read sensors measurements 
    measureState();
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
void measureState(){
    // measure
    for (long long i=0; i<8446744073709551615; i++){ // ~ 2^64 = practically infinite loop
        usleep(20000);
	    lsm6ds33_measure(i);
        lis3mdl_measure(i);
        printf("%lld: A_x: %d,   A_y: %d,   A_z: %d,   G_x: %d,   G_y: %d,   G_z: %d,   Temp: %.1f C\n", i, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, temperature);
        printf("%lld: Magnm x: %d ,   Magnm y: %d,    Magnm z: %d\n",i, magnm_x, magnm_y, magnm_z);
    }
}