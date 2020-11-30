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
#include <math.h>

#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>

#include "library/szilv_i2c.h"
#include "pololu_imu_v5.h"
#include "lsm6ds33.h"

/************************** Definitions *****************************/
#define lsm6ds33SlaveAddr 0b1101011  // 0b1101011 - the IMU initial default slave addr, SA0 default state
#define FUNC_CFG_ACCESS       0x01
#define FIFO_CTRL1            0x06
#define FIFO_CTRL2            0x07
#define FIFO_CTRL3            0x08
#define FIFO_CTRL4            0x09
#define FIFO_CTRL5            0x0A
#define ORIENT_CFG_G          0x0B
#define INT1_CTRL             0x0D
#define INT2_CTRL             0x0E
#define WHO_AM_I              0X0F
#define CTRL1_XL              0x10
#define CTRL2_G               0x11
#define CTRL3_C               0x12
#define CTRL4_C               0x13
#define CTRL5_C               0x14
#define CTRL6_C               0x15
#define CTRL7_G               0x16
#define CTRL8_XL              0x17
#define CTRL9_XL              0x18
#define CTRL10_C              0x19
#define WAKE_UP_SRC           0x1B
#define TAP_SRC               0x1C
#define D6D_SRC               0x1D
#define STATUS_REG            0x1E
#define OUT_TEMP_L            0x20
#define OUT_TEMP_H            0x21
#define OUTX_L_G              0x22
#define OUTX_H_G              0x23
#define OUTY_L_G              0x24
#define OUTY_H_G              0x25
#define OUTZ_L_G              0x26
#define OUTZ_H_G              0x27
#define OUTX_L_XL             0x28
#define OUTX_H_XL             0x29
#define OUTY_L_XL             0x2A
#define OUTY_H_XL             0x2B
#define OUTZ_L_XL             0x2C
#define OUTZ_H_XL             0x2D
#define FIFO_STATUS1          0x3A
#define FIFO_STATUS2          0x3B
#define FIFO_STATUS3          0x3C
#define FIFO_STATUS4          0x3D
#define FIFO_DATA_OUT_L       0x3E
#define FIFO_DATA_OUT_H       0x3F
#define TIMESTAMP0_REG        0x40
#define TIMESTAMP1_REG        0x41
#define TIMESTAMP2_REG        0x42
#define STEP_TIMESTAMP_L      0x49
#define STEP_TIMESTAMP_H      0x4A
#define STEP_COUNTER_L        0x4B
#define STEP_COUNTER_H        0x4C
#define FUNC_SR               0x53
#define TAP_CFG               0x58
#define TAP_THS_6D            0x59
#define INT_DUR2              0x5A
#define WAKE_UP_THS           0x5B
#define WAKE_UP_DUR           0x5C
#define FREE_FALL             0x5D
#define MD1_CFG               0x5E
#define MD2_CFG               0x5F


/* ************************************************************************** */
// 
/* ************************************************************************** */
void select_slave_lsm6ds33(){
	if (ioctl(FD_ImuIIC, I2C_SLAVE, lsm6ds33SlaveAddr) < 0) {
		printf("Cannot set IIC lsm6ds33's slave addr, errno: %d\n", errno);
		exit(1);
	}
}

/* ************************************************************************** */
// configure, initialize the MAG3110 imu
/* ************************************************************************** */
void init_lsm6ds33(){
	// select the lsm6ds33 slave
	select_slave_lsm6ds33();
    
    // init
	// Accelerometer operating mode selection. Note: see CTRL1_XL (10h) register description for details
    // write_i2c_register(FD_ImuIIC, CTRL1_XL,(char) 0b01100000 ); // 416 Hz (High Performance)
	write_i2c_register(FD_ImuIIC, CTRL1_XL,(char) 0b01010000 ); // 208 Hz
	// Gyroscope operating mode selection. Note: see CTRL2_G (10h) register description for details
	// write_i2c_register(FD_ImuIIC, CTRL2_G, (char) 0b01100000 ); // 416 Hz (High Performance)
	write_i2c_register(FD_ImuIIC, CTRL2_G, (char) 0b01010000 ); // 208 Hz

	// write_i2c_register(FD_ImuIIC, CTRL7_G, (char) 0b10000000); // Gyroscope: disable high performance mode, enable normal mode
	// write_i2c_register(FD_ImuIIC, CTRL6_C, (char) 0b00010000); // Accelerometer: disable high performance mode, enable normal mode
}


/* ************************************************************************** */
// 
/* ************************************************************************** */
void lsm6ds33_measure(){
	// select the lsm6ds33 slave
	select_slave_lsm6ds33();
	
	// Accelorometer
	accel.x = read2_i2c_registerLSB(FD_ImuIIC, OUTX_L_XL);
	accel.y = read2_i2c_registerLSB(FD_ImuIIC, OUTY_L_XL);
	accel.z = read2_i2c_registerLSB(FD_ImuIIC, OUTZ_L_XL);

	// Gyroscope
	gyro.x = read2_i2c_registerLSB(FD_ImuIIC, OUTX_L_G);
	gyro.y = read2_i2c_registerLSB(FD_ImuIIC, OUTY_L_G);
	gyro.z = read2_i2c_registerLSB(FD_ImuIIC, OUTZ_L_G);

	// Chip temperature
	int rawtemp = read2_i2c_registerLSB(FD_ImuIIC, OUT_TEMP_L);
	temperature = roundf( (float) rawtemp / 16 + 25 );
}
