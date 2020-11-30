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
};
extern struct magnSensor3AxeData magnm;
extern int magn_temperature;

void init_lis3mdl(void);
void lis3mdl_measure(void);

#endif /* _LIS3MDL_MAGNM_H */
