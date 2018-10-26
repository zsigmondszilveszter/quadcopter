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

#include "szilv_i2c.h"
#include "pololu_imu_v5.h"
#include "lsm6ds33.h"


/* ************************************************************************** */
/** 
/* ************************************************************************** */
void select_slave_lsm6ds33(){
	if (ioctl(FD_ImuIIC, I2C_SLAVE, lsm6ds33SlaveAddr) < 0) {
		printf("Cannot set IIC lsm6ds33's slave addr, errno: %d\n", errno);
		exit(1);
	}
}

/* ************************************************************************** */
/** configure, initialize the MAG3110 imu
/* ************************************************************************** */
void init_lsm6ds33(){
	//
	select_slave_lsm6ds33();
    
    // init
    write_i2c_register(FD_ImuIIC, CTRL1_XL,(char) 0b01100000 ); // Operating mode selection. Note: see CTRL1_XL (10h) register description for details
	write_i2c_register(FD_ImuIIC, CTRL2_G, (char) 0b01100000 ); // 
}


/* ************************************************************************** */
/** 
/* ************************************************************************** */
void lsm6ds33_measure(long long index){
	select_slave_lsm6ds33();
	
	// Accelorometer
	accel_x = read2_i2c_registerLSB(FD_ImuIIC, OUTX_L_XL);
	accel_y = read2_i2c_registerLSB(FD_ImuIIC, OUTY_L_XL);
	accel_z = read2_i2c_registerLSB(FD_ImuIIC, OUTZ_L_XL);
	// printf("%lld: Accel x: %d ,   Accel y: %d,    Accel z: %d\n", index, accel_x, accel_y, accel_z);

	// Gyroscope
	gyro_x = read2_i2c_registerLSB(FD_ImuIIC, OUTX_L_G);
	gyro_y = read2_i2c_registerLSB(FD_ImuIIC, OUTY_L_G);
	gyro_z = read2_i2c_registerLSB(FD_ImuIIC, OUTZ_L_G);
	// printf("%lld: Gyro x: %d ,   Gyro y: %d,    Gyro z: %d\n", index, gyro_x, gyro_y, gyro_z);

	int rawtemp = read2_i2c_registerLSB(FD_ImuIIC, OUT_TEMP_L);
	temperature = roundf( (float) rawtemp / 16 + 25 );
	// printf("Temperature: %.2f\n", temperature);

	printf("%lld: A_x: %d,   A_y: %d,   A_z: %d,   G_x: %d,   G_y: %d,   G_z: %d,   Temp: %.1f\n", index, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, temperature);
}