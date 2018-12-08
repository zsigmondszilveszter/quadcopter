/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-11-21
*
* BMP180 Digital pressure sensor (Bosch)
*
******************************************************************************/

#ifndef _BMP180_H    /* Guard against multiple inclusion */
#define _BMP180_H

/***************************** Includes *********************************/
#include <semaphore.h>

/************************** Variable Definitions *****************************/
//FileDescriptor of the IIC-1 device (BMP180)
int FD_BMP180IIC;
sem_t sem_startBmp180Measure;
sem_t sem_Bmp180MeasureDone;


int open_iic1_device(void);
void init_bmp180();
void initBmp180Semaphores(void);
void measure_bmp180_measures(void);
int bmp180Thread(void * ptr);
void measure_bmp180(void);


#endif /* _BMP180_H */