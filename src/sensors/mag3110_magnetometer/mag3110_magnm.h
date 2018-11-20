/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-16
*
******************************************************************************/

#ifndef _MAG3110_MAGNM_H    /* Guard against multiple inclusion */
#define _MAG3110_MAGNM_H

int magnm_x;
int magnm_y;
int magnm_z;

int init_mag3110(void);
void mag3110_measure(long long index);

#endif /* _MAG3110_MAGNM_H */