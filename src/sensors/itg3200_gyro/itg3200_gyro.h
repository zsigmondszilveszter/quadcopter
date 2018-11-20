/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-13
*
******************************************************************************/

#ifndef _ITG3200_GYRO_H    /* Guard against multiple inclusion */
#define _ITG3200_GYRO_H

/************************** Definitions *****************************/
#define GyroSlaveAddr 0b1101000  // 0b110100 - the Gyro initial default slave addr to the transmit register
// gyro register addresses
#define WHO_I_AM 		0x00
#define TEMP_OUT_H 		0x1B
#define TEMP_OUT_L 		0x1C
#define GYRO_XOUT_H 	0x1D
#define GYRO_XOUT_L 	0x1E
#define GYRO_YOUT_H 	0x1F
#define GYRO_YOUT_L 	0x20
#define GYRO_ZOUT_H 	0x21
#define GYRO_ZOUT_L 	0x22
#define DLPF_FS 		0x16
#define PWR_MGM 		0x3E
#define INT_CFG 		0x17
#define SMPLRT_DIV 		0x15

int gyro_x;
int gyro_y;
int gyro_z;

int init_itg3200(void);
void itg3200_measure(void);
int gyroThread(void * ptr);

#endif /* _ITG3200_GYRO_H */