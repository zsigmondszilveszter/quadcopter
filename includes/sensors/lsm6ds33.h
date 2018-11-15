/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-17
*
******************************************************************************/

#ifndef _LSM6DS33_IMU_H    /* Guard against multiple inclusion */
#define _LSM6DS33_IMU_H

int gyro_x;
int gyro_y;
int gyro_z;

int accel_x;
int accel_y;
int accel_z;

float temperature;

void init_lsm6ds33(void);
void select_slave_lsm6ds33(void);
void lsm6ds33_measure(long long index);

#endif /* _LSM6DS33_IMU_H */