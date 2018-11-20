/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-13
*
* The ITG3200 gyroscope must to 
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
#include "itg3200_gyro.h"


/***************************** Definitions *********************************/
#define ITG3200_I2C "/dev/i2c-0"


/************************** Variable Definitions *****************************/
//FileDescriptor of the IIC-0 device.
int FD_GyroIIC;



/* ************************************************************************** */
/** configure, initialize and starts the I2C-0 module for ITG3200
/* ************************************************************************** */
int init_itg3200(){

	/*
	 * Open the device.
	 */
	FD_GyroIIC = open(ITG3200_I2C, O_RDWR);
	if(FD_GyroIIC < 0)
	{
		printf("Cannot open the IIC device, errno: %d\n", errno);
		exit(1);
	}

	if (ioctl(FD_GyroIIC, I2C_SLAVE, GyroSlaveAddr) < 0) {
		printf("Cannot set IIC slave addr, errno: %d\n", errno);
		exit(1);
	}
    
    write_i2c_register(FD_GyroIIC, PWR_MGM,(char) 0b10000000 ); // reset the i2c slave
    write_i2c_register(FD_GyroIIC, PWR_MGM,(char) 0b00000011 ); // set PLL with Z gyro reference
    write_i2c_register(FD_GyroIIC, SMPLRT_DIV, (char) 1);
    write_i2c_register(FD_GyroIIC, DLPF_FS,(char) 0b00011100 ); // DLPF_CFG - last 3 bit
                                                    // 0    - 256Hz    - 8kHz   000
                                                    // 1    - 188Hz    - 1kHz   001
                                                    // 2    - 98Hz     - 1kHz   010
                                                    // 3    - 42Hz     - 1kHz   011
                                                    // 4    - 20Hz     - 1kHz   100
                                                    // 5    - 10Hz     - 1kHz   101
                                                    // 6    - 5Hz      - 1kHz   110
}


/* ************************************************************************** */
/** 
/* ************************************************************************** */
pthread_t gyro_thread;
void itg3200_measure(){
	pthread_create( &gyro_thread, NULL, (void *) gyroThread, NULL);
}

//--------------------------------------------------------------------------
// 
//--------------------------------------------------------------------------
int gyroThread(void * ptr){
	for (long long i=0; i<8446744073709551615; i++){
		usleep(10000);
		gyro_x = read2_i2c_registerMSB(FD_GyroIIC, GYRO_XOUT_H);
		gyro_y = read2_i2c_registerMSB(FD_GyroIIC, GYRO_YOUT_H);
		gyro_z = read2_i2c_registerMSB(FD_GyroIIC, GYRO_ZOUT_H);

		printf("%lld: Gyro x: %d ,   Gyro y: %d,    Gyro z: %d\n",i, gyro_x, gyro_y, gyro_z);
	}
}