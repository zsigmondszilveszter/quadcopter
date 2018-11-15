/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-11-15
*
* The LIS3MDL magnetometer unit
*
******************************************************************************/

/***************************** Include Files *********************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <math.h>

#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>

#include "szilv_i2c.h"
#include "pololu_imu_v5.h"
#include "lis3mdl.h"


/************************** Definitions *****************************/
#define lis3mdlSlaveAddr 0b0011110  // 0b0011110 - the magnetometer initial default slave addr, SA0 default state
enum LIS3MDLRegAddr
{
    LIS3MDL_WHO_AM_I    = 0x0F,

    LIS3MDL_CTRL_REG1   = 0x20,
    LIS3MDL_CTRL_REG2   = 0x21,
    LIS3MDL_CTRL_REG3   = 0x22,
    LIS3MDL_CTRL_REG4   = 0x23,
    LIS3MDL_CTRL_REG5   = 0x24,

    LIS3MDL_STATUS_REG  = 0x27,
    LIS3MDL_OUT_X_L     = 0x28,
    LIS3MDL_OUT_X_H     = 0x29,
    LIS3MDL_OUT_Y_L     = 0x2A,
    LIS3MDL_OUT_Y_H     = 0x2B,
    LIS3MDL_OUT_Z_L     = 0x2C,
    LIS3MDL_OUT_Z_H     = 0x2D,
    LIS3MDL_TEMP_OUT_L  = 0x2E,
    LIS3MDL_TEMP_OUT_H  = 0x2F,
    LIS3MDL_INT_CFG     = 0x30,
    LIS3MDL_INT_SRC     = 0x31,
    LIS3MDL_INT_THS_L   = 0x32,
    LIS3MDL_INT_THS_H   = 0x33,
};


/* ************************************************************************** */
/** 
/* ************************************************************************** */
void select_slave_lis3mdl(){
	if (ioctl(FD_ImuIIC, I2C_SLAVE, lis3mdlSlaveAddr) < 0) {
		printf("Cannot set IIC lis3mdl's slave addr, errno: %d\n", errno);
		exit(1);
	}
}

/* ************************************************************************** */
/** configure, initialize the MAG3110 imu
/* ************************************************************************** */
void init_lis3mdl(){
	//
	select_slave_lis3mdl();
    
    // init
	write_i2c_register(FD_ImuIIC, LIS3MDL_CTRL_REG1, 0b11100010); // TEMP_EN=1, OM0/OM1=11, ultra high performance, ODR=1
    write_i2c_register(FD_ImuIIC, LIS3MDL_CTRL_REG3, 0b00000000); // MD[1:0] = 00 - Continuous-conversion mode
    write_i2c_register(FD_ImuIIC, LIS3MDL_CTRL_REG4, 0b00001100); // OMZ = 11, ultra-high performance 
}


/* ************************************************************************** */
/** 
/* ************************************************************************** */
void lis3mdl_measure(long long index){
	select_slave_lis3mdl();
	
    magnm_x = read2_i2c_registerLSB(FD_ImuIIC, LIS3MDL_OUT_X_L);
	magnm_y = read2_i2c_registerLSB(FD_ImuIIC, LIS3MDL_OUT_Y_L);
	magnm_z = read2_i2c_registerLSB(FD_ImuIIC, LIS3MDL_OUT_Z_L);

	// int rawtemp = read2_i2c_registerLSB(FD_ImuIIC, LIS3MDL_TEMP_OUT_L);
	// magn_temperature = roundf( (float) rawtemp / 16 + 25 );
}