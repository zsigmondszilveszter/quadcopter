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

#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>

#include "pololu_imu_v5.h"
#include "lsm6ds33.h"


/* ************************************************************************** */
/** open I2C-0 device 
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
/** configure, initialize the Pololu v5 IMU
/* ************************************************************************** */
void init_pololu_v5(){
    open_iic_device();
	init_lsm6ds33();
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
pthread_t pololu_thread;
void measure_pololu_imu_v5(){
	pthread_create( &pololu_thread, NULL, (void *) pololuThread, NULL);
}

/* ************************************************************************** */
/** measure
/* ************************************************************************** */
int pololuThread(void * ptr){
    for (long long i=0; i<8446744073709551615; i++){
		usleep(20000);
	    lsm6ds33_measure(i);
    }
}