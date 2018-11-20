/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-13
*
******************************************************************************/

#include <linux/i2c-dev.h>

/**************************** Function Definitions ***************************/
__u8 read_i2c_register(int fd, char r_addr);
__s16 read2_i2c_registerLSB(int fd, char r_addr);
__s16 read2_i2c_registerMSB(int fd, char r_addr);
__u8 write_i2c_register(int fd, char r_addr, char data);
__s16 swapBytesIn2ByteInt(int value);