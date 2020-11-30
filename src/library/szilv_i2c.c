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
#include <sys/ioctl.h>

#include "library/szilv_i2c.h"

/*
 * Data for SMBus Messages
 */
#define I2C_SMBUS_BLOCK_MAX	32	/* As specified in SMBus standard */
#define I2C_SMBUS_I2C_BLOCK_MAX	32	/* Not specified but we use same structure */
union i2c_smbus_data {
	__u8 byte;
	__u16 word;
	__u8 block[I2C_SMBUS_BLOCK_MAX + 2]; /* block[0] is used for length */
                                            /* and one more for PEC */
};

/* smbus_access read or write markers */
#define I2C_SMBUS_READ	1
#define I2C_SMBUS_WRITE	0

/* SMBus transaction types (size parameter in the above functions)
 *    Note: these no longer correspond to the (arbitrary) PIIX4 internal codes! */
#define I2C_SMBUS_QUICK		    0
#define I2C_SMBUS_BYTE		    1
#define I2C_SMBUS_BYTE_DATA	    2
#define I2C_SMBUS_WORD_DATA	    3
#define I2C_SMBUS_PROC_CALL	    4
#define I2C_SMBUS_BLOCK_DATA	    5
#define I2C_SMBUS_I2C_BLOCK_BROKEN  6
#define I2C_SMBUS_BLOCK_PROC_CALL   7		/* SMBus 2.0 */
#define I2C_SMBUS_I2C_BLOCK_DATA    8


/************************** Variable Definitions *****************************/
char buf[2] = {0};
__s32 res = 0;


/**
 * 
 * */
static inline __s32 i2c_smbus_access(int file, char read_write, __u8 command, int size, union i2c_smbus_data *data){
	struct i2c_smbus_ioctl_data args;

	args.read_write = read_write;
	args.command = command;
	args.size = size;
	args.data = data;
	return ioctl(file,I2C_SMBUS,&args);
}

/**
 *
 */
static inline __s32 i2c_smbus_read_byte_data(int file, __u8 command){
	union i2c_smbus_data data;
	if (i2c_smbus_access(file,I2C_SMBUS_READ,command, I2C_SMBUS_BYTE_DATA,&data))
		return -1;
	else
		return 0x0FF & data.byte;
}

/**
 *
 */
static inline __s32 i2c_smbus_read_word_data(int file, __u8 command){
	union i2c_smbus_data data;
	if (i2c_smbus_access(file,I2C_SMBUS_READ,command, I2C_SMBUS_WORD_DATA,&data))
		return -1;
	else
		return 0x0FFFF & data.word;
}

/* ************************************************************************** */
// write 1 byte value to register pointed by w_addr 
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
// read 1 byte value from register pointed by r_addr 
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

/* ************************************************************************** *
 * read 2 byte value from register pointed by r_addr 
 * and from its pair - incremented addr - 2 * 8bit register = 16 bit data (2 byte)
 * ************************************************************************** */
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

/* ************************************************************************** *
 * read 2 byte value from register pointed by r_addr 
 * and from its pair - incremented addr - 2 * 8bit register = 16 bit data (2 byte)
 * ************************************************************************** */
__s16 read2_i2c_registerMSB(int fd, char r_addr){
	return swapBytesIn2ByteInt(read2_i2c_registerLSB(fd, r_addr));
}

/* ************************************************************************** */
//
/* ************************************************************************** */
__s16 swapBytesIn2ByteInt(int value){
	value = value & 0x0000FFFF;
	return (value>>8) | (value<<8);
}
