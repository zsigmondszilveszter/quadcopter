/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-16
*
******************************************************************************/

#ifndef _MAG3110_MAGNM_H    /* Guard against multiple inclusion */
#define _MAG3110_MAGNM_H

/************************** Definitions *****************************/
#define MagnmSlaveAddr 0x0E  // 0x0E - the Magnm initial default slave addr
#define DR_STATUS 		0x00    
#define OUT_X_MSB 		0x01
#define OUT_X_LSB 		0x02
#define OUT_Y_MSB 	    0x03
#define OUT_Y_LSB 	    0x04
#define OUT_Z_MSB 	    0x05
#define OUT_Z_LSB 	    0x06
#define WHO_AM_I 	    0x07
#define SYSMOD 	        0x08
#define OFF_X_MSB 		0x09
#define OFF_X_LSB 		0x0A
#define OFF_Y_MSB 		0x0B
#define OFF_Y_LSB 		0x0C
#define OFF_Z_MSB 	    0x0D
#define OFF_Z_LSB 		0x0E
#define DIE_TEMP 		0x0F
#define CTRL_REG1 		0x10
#define CTRL_REG2 		0x11

int magnm_x;
int magnm_y;
int magnm_z;

int init_mag3110(void);
void mag3110_measure(void);
int magnmThread(void * ptr);

#endif /* _MAG3110_MAGNM_H */