/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-26
*
******************************************************************************/


#ifndef _POLOLU_IMU_V5_H    /* Guard against multiple inclusion */
#define _POLOLU_IMU_V5_H


/***************************** Definitions *********************************/
#define POLOLU_V5_I2C "/dev/i2c-0"


/************************** Variable Definitions *****************************/
//FileDescriptor of the IIC-0 device (Pololu IMU v5 connected to IIC-0)
int FD_ImuIIC;


int open_iic_device(void);
void init_pololu_v5();
void measure_pololu_imu_v5(void);
int pololuThread(void * ptr);


#endif /* _POLOLU_IMU_V5_H */