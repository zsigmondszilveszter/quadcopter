/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-17
*
* The LSM6DS33 IMU unit (gyroscope and accelerometer)
*
******************************************************************************/

/***************************** Include Files *********************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>

#include "szilv_i2c.h"
#include "lsm6ds33.h"


/***************************** Definitions *********************************/
#define LSM6DS33_I2C "/dev/i2c-1"


/************************** Variable Definitions *****************************/
//FileDescriptor of the IIC-1 device.
int FD_ImuIIC;



/* ************************************************************************** */
/** configure, initialize and starts the I2C-1 module for MAG3110
/* ************************************************************************** */
int init_lsm6ds33(){

	/*
	 * Open the device.
	 */
	FD_ImuIIC = open(LSM6DS33_I2C, O_RDWR);
	if(FD_ImuIIC < 0)
	{
		printf("Cannot open the IIC device, errno: %d\n", errno);
		exit(1);
	}

	if (ioctl(FD_ImuIIC, I2C_SLAVE, MagnmSlaveAddr) < 0) {
		printf("Cannot set IIC slave addr, errno: %d\n", errno);
		exit(1);
	}
    
    // init
    // write_i2c_register(FD_ImuIIC, CTRL_REG1,(char) 0b00000001 ); // Operating mode selection. Note: see section 4.3.5 for details. Default value: 0.
                                                                //    0: STANDBY mode.
                                                                //    1: ACTIVE mode.
}


/* ************************************************************************** */
/** 
/* ************************************************************************** */
void lsm6ds33_measure(){
    for (long long i=0; i<8446744073709551615; i++){
		usleep(5000);
		gyro_x = read2_i2c_registerLSB(FD_ImuIIC, OUTX_L_G);
		gyro_y = read2_i2c_registerLSB(FD_ImuIIC, OUTY_L_G);
		gyro_z = read2_i2c_registerLSB(FD_ImuIIC, OUTZ_L_G);

		printf("%lld: Gyro x: %d ,   Gyro y: %d,    Gyro z: %d\n",i, gyro_x, gyro_y, gyro_z);
	}
}