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
extern int FD_BMP180IIC;
extern sem_t sem_startBmp180Measure;
extern sem_t sem_Bmp180MeasureDone;

typedef struct {
    short ac1,ac2,ac3;
    unsigned short ac4,ac5,ac6;
    short b1,b2,mb,mc,md;
} barometerParams;

extern barometerParams barom_params;


void open_iic1_device(void);
void init_bmp180(void);
void init_bmp180_chip(void);
void select_slave_bmp180(void);
void initBmp180Semaphores(void);
void measure_bmp180_measures(void);
int bmp180Thread(void * ptr);
void measure_bmp180(void);
float barometer_read(void);


#endif /* _BMP180_H */
