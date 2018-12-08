/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-11-21
*
* BMP180 Digital pressure sensor (Bosch)
*
******************************************************************************/

/***************************** Include Files *********************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>

#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>

#include "tools.h"
#include "bmp180.h"


/***************************** Definitions *********************************/
#define BMP180_I2C "/dev/i2c-1"



/* ************************************************************************** */
/** open I2C-1 device 
/* ************************************************************************** */
int open_iic1_device(){

	// Open the device.
	FD_BMP180IIC = open(BMP180_I2C, O_RDWR);
	if(FD_BMP180IIC < 0)
	{
		printf("Cannot open the Barometer IIC device, errno: %d\n", errno);
		exit(1);
	}
    ioctl(FD_BMP180IIC, I2C_TIMEOUT , 30);
}

/* ************************************************************************** */
/** configure, initialize the Pololu v5 IMU
/* ************************************************************************** */
void init_bmp180(){
    open_iic1_device();
	initBmp180Semaphores();
	measure_bmp180_measures();
}

/* ************************************************************************** */
/** init semaphores
/* ************************************************************************** */
void initBmp180Semaphores(){
    // semaphore for let the bmp180 sensor starts to measure
    if( sem_init(&sem_startBmp180Measure, 0, 0) ){
        // error
        printf("Error with semaphore sem_startBmp180Measure\n");
        printErrno();
    }
    // semaphore for let the Bmp180 sensor signal its measurements are done
    if( sem_init(&sem_Bmp180MeasureDone, 0, 0) ){
        // error
        printf("Error with semaphore sem_Bmp180MeasureDone\n");
        printErrno();
    }
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
pthread_t bmp180_thread;
void measure_bmp180_measures(){
	pthread_create( &bmp180_thread, NULL, (void *) bmp180Thread, NULL);
}


/* ************************************************************************** */
/**
/* ************************************************************************** */
int bmp180Thread(void * ptr){
	while(1){
		// wait for the signal to start the measure
		sem_wait(&sem_startBmp180Measure);
		// measure
		measure_bmp180();
	}
}


/* ************************************************************************** */
/** measure
/* ************************************************************************** */
void measure_bmp180(){
	// TODO measure

	// signal the measurement termination
	sem_post(&sem_Bmp180MeasureDone);
}