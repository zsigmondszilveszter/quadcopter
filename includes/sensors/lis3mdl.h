/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-11-15
*
******************************************************************************/

#ifndef _LIS3MDL_MAGNM_H    /* Guard against multiple inclusion */
#define _LIS3MDL_MAGNM_H

#include <stdint.h>

struct magnSensor3AxeData{
    int16_t x;
    int16_t y;
    int16_t z;
} magnm;
int magn_temperature;

void init_lis3mdl(void);
void lis3mdl_measure(long long index);

#endif /* _LIS3MDL_MAGNM_H */