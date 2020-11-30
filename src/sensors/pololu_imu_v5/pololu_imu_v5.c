/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-17
*
* Pololu IMU v.5 ( LSM6DS33 and LIS3MDL)
*
******************************************************************************/

/***************************** Include Files *********************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>
#include <semaphore.h>

#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>

#include "library/tools.h"
#include "pololu_imu_v5.h"
#include "lsm6ds33.h"
#include "lis3mdl.h"


/* ************************************************************************** */
// open I2C-0 device 
/* ************************************************************************** */
int open_iic_device(){

	// Open the device.
	FD_ImuIIC = open(POLOLU_V5_I2C, O_RDWR);
	if(FD_ImuIIC < 0)
	{
		printf("Cannot open the IIC device, errno: %d\n", errno);
		exit(1);
	}
}

/* ************************************************************************** */
/** configure, initialize the Pololu v5 IMU */
/* ************************************************************************** */
void init_pololu_v5(){
    open_iic_device();
	init_lsm6ds33();
	init_lis3mdl();
	initPololuSemaphores();
	startPololuMeasure();
}

/* ************************************************************************** */
/** init semaphores */
/* ************************************************************************** */
void initPololuSemaphores(){
	// semaphore to let the pololu sensor starts to measure
    if( sem_init(&sem_startPololuMeasure, 0, 0) ){
        // error
        printf("Error with semaphore sem_startPololuMeasure\n");
        printErrno();
    }
    // semaphore to let the Pololu sensor signal its measurements are done
    if( sem_init(&sem_PololuMeasureDone, 0, 0) ){
        // error
        printf("Error with semaphore sem_PololuMeasureDone\n");
        printErrno();
    }
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
pthread_t pololu_thread;
void startPololuMeasure(){
	pthread_create( &pololu_thread, NULL, (void *) pololuThread, NULL);
}


/* ************************************************************************** */
/**
/* ************************************************************************** */
int pololuThread(void * ptr){
	while(1){
		// wait for the signal to start the measure
		sem_wait(&sem_startPololuMeasure);
		// measure
		pololuMeasure();
	}
}


/* ************************************************************************** */
/** measure */
/* ************************************************************************** */
void pololuMeasure(){
	lsm6ds33_measure();
    lis3mdl_measure();
	// signal the measurement termination
	sem_post(&sem_PololuMeasureDone);
}
