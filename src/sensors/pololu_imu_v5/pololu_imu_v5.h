/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-26
*
******************************************************************************/


#ifndef _POLOLU_IMU_V5_H    /* Guard against multiple inclusion */
#define _POLOLU_IMU_V5_H

/***************************** Includes *********************************/
#include <semaphore.h>

/***************************** Definitions *********************************/
#define POLOLU_V5_I2C "/dev/i2c-0"


/************************** Variable Definitions *****************************/
//FileDescriptor of the IIC-0 device (Pololu IMU v5 connected to IIC-0)
extern int FD_ImuIIC;
extern sem_t sem_startPololuMeasure;
extern sem_t sem_PololuMeasureDone;


void open_iic_device(void);
void init_pololu_v5(void);
void initPololuSemaphores(void);
void startPololuMeasure(void);
int pololuThread(void * ptr);
void pololuMeasure(void);


#endif /* _POLOLU_IMU_V5_H */
