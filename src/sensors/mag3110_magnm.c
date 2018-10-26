/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-16
*
* The MAG3110 magnetometer
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

#include "szilv_i2c.h"
#include "mag3110_magnm.h"


/***************************** Definitions *********************************/
#define MAG3110_I2C "/dev/i2c-1"


/************************** Variable Definitions *****************************/
//FileDescriptor of the IIC-1 device.
int FD_MagnMIIC;



/* ************************************************************************** */
/** configure, initialize and starts the MAG3110_I2C module for MAG3110
/* ************************************************************************** */
int init_mag3110(){

	/*
	 * Open the device.
	 */
	FD_MagnMIIC = open(MAG3110_I2C, O_RDWR);
	if(FD_MagnMIIC < 0)
	{
		printf("Cannot open the IIC device, errno: %d\n", errno);
		exit(1);
	}

	if (ioctl(FD_MagnMIIC, I2C_SLAVE, MagnmSlaveAddr) < 0) {
		printf("Cannot set IIC MAG3110's slave addr, errno: %d\n", errno);
		exit(1);
	}
    
    // init
    write_i2c_register(FD_MagnMIIC, CTRL_REG1,(char) 0b00000001 ); // Operating mode selection. Note: see section 4.3.5 for details. Default value: 0.
                                                                //    0: STANDBY mode.
                                                                //    1: ACTIVE mode.
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
pthread_t magnm_thread;
void mag3110_measure(){
    pthread_create( &magnm_thread, NULL, (void *) magnmThread, NULL);
}

//--------------------------------------------------------------------------
// 
//--------------------------------------------------------------------------
int magnmThread(void * ptr){
	for (long long i=0; i<8446744073709551615; i++){
		usleep(20000);
		magnm_x = read2_i2c_registerMSB(FD_MagnMIIC, OUT_X_MSB);
		magnm_y = read2_i2c_registerMSB(FD_MagnMIIC, OUT_Y_MSB);
		magnm_z = read2_i2c_registerMSB(FD_MagnMIIC, OUT_Z_MSB);

		// printf("%lld: Magnm x: %d ,   Magnm y: %d,    Magnm z: %d\n",i, magnm_x, magnm_y, magnm_z);
	}
}