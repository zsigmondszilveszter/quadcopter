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

#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>

#include "szilv_i2c.h"
#include "mag3110_magnm.h"


/***************************** Definitions *********************************/
#define MAG3110_I2C "/dev/i2c-1"
/************************** Definitions *****************************/
#define MagnmSlaveAddr 0x0E  // 0x0E - the Magnm initial default slave addr
#define DR_STATUS 		0x00    
#define OUT_X_MSB 		0x01
#define OUT_X_LSB 		0x02
#define OUT_Y_MSB 	    0x03
#define OUT_Y_LSB 	    0x04
#define OUT_Z_MSB 	    0x05
#define OUT_Z_LSB 	    0x06
#define WHO_AM_I 	    0x07
#define SYSMOD 	        0x08
#define OFF_X_MSB 		0x09
#define OFF_X_LSB 		0x0A
#define OFF_Y_MSB 		0x0B
#define OFF_Y_LSB 		0x0C
#define OFF_Z_MSB 	    0x0D
#define OFF_Z_LSB 		0x0E
#define DIE_TEMP 		0x0F
#define CTRL_REG1 		0x10
#define CTRL_REG2 		0x11


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

//--------------------------------------------------------------------------
// 
//--------------------------------------------------------------------------
void mag3110_measure(long long index){
	magnm_x = read2_i2c_registerMSB(FD_MagnMIIC, OUT_X_MSB);
	magnm_y = read2_i2c_registerMSB(FD_MagnMIIC, OUT_Y_MSB);
	magnm_z = read2_i2c_registerMSB(FD_MagnMIIC, OUT_Z_MSB);

	// printf("%lld: Magnm x: %d ,   Magnm y: %d,    Magnm z: %d\n",index, magnm_x, magnm_y, magnm_z);
}