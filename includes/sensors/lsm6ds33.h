/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-17
*
******************************************************************************/

#ifndef _LSM6DS33_IMU_H    /* Guard against multiple inclusion */
#define _LSM6DS33_IMU_H

#include <stdint.h>

struct imuSensor3AxeData{
    int16_t x;
    int16_t y;
    int16_t z;
} gyro, accel;

float temperature;

void init_lsm6ds33(void);
void select_slave_lsm6ds33(void);
void lsm6ds33_measure(long long index);

#endif /* _LSM6DS33_IMU_H */