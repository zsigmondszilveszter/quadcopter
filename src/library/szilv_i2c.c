/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-13
*
* This file depends on i2c-tools project. It has to be installed on the system.
* https://git.kernel.org/pub/scm/utils/i2c-tools/i2c-tools.git
*
*
******************************************************************************/


/***************************** Include Files *********************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>

#include "szilv_i2c.h"


/************************** Variable Definitions *****************************/
char buf[2] = {0};
__s32 res = 0;


/* ************************************************************************** */
/** write 1 byte value to register pointed by w_addr 
/* ************************************************************************** */
__u8 write_i2c_register(int fd, char w_addr, char data){
	buf[0] = w_addr;
	buf[1] = data;
	if (write(fd, buf, 2) != 2) {
		/* ERROR HANDLING: i2c transaction failed */
		fprintf(stderr, "Cannot write IIC slave register, errno: %d\n", errno);
		return -1;
	} else {
		return 0;
	}
}

/* ************************************************************************** */
/** read 1 byte value from register pointed by r_addr 
/* ************************************************************************** */
__u8 read_i2c_register(int fd, char r_addr){
	/* Using SMBus commands */
	res = i2c_smbus_read_byte_data(fd, r_addr);
	if (res < 0) {
		/* ERROR HANDLING: i2c transaction failed */
		fprintf(stderr, "Cannot read IIC slave REG, errno: %d\n", errno);
		return -1;
	} else {
		/* res contains the read byte */
		return (__u8) res;
	}
}

/* ************************************************************************** */
/** read 2 byte value from register pointed by r_addr 
 * and from its pair - incremented addr - 2 * 8bit register = 16 bit data (2 byte)
/* ************************************************************************** */
__s16 read2_i2c_registerLSB(int fd, char r_addr){
	res = 0;
	/* Using SMBus commands */
	res = i2c_smbus_read_word_data(fd, r_addr);
	if (res < 0) {
		/* ERROR HANDLING: i2c transaction failed */
		fprintf(stderr, "Cannot read IIC slave REG, errno: %d, res: %d\n", errno, res);
	} else {
		/* res contains the read word */
		return (__s16) res;
	}
}

/* ************************************************************************** */
/** read 2 byte value from register pointed by r_addr 
 * and from its pair - incremented addr - 2 * 8bit register = 16 bit data (2 byte)
/* ************************************************************************** */
__s16 read2_i2c_registerMSB(int fd, char r_addr){
	return swapBytesIn2ByteInt(read2_i2c_registerLSB(fd, r_addr));
}

/* ************************************************************************** */
/*
/* ************************************************************************** */
__s16 swapBytesIn2ByteInt(int value){
	value = value & 0x0000FFFF;
	return (value>>8) | (value<<8);
}