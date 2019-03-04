/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-11-21
*
* BMP180 Digital pressure sensor (Bosch)
*
******************************************************************************/

/***************************** Include Files *********************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>

#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <math.h>

#include "tools.h"
#include "bmp180.h"


/***************************** Definitions *********************************/
#define BMP180_I2C "/dev/i2c-1"
#define BAROMETER_IIC_ADR 0x77  //

#define AC1_ADDR 0xAA



/* ************************************************************************** */
/** open I2C-1 device 
/* ************************************************************************** */
int open_iic1_device(){

	// Open the device.
	FD_BMP180IIC = open(BMP180_I2C, O_RDWR);
	if(FD_BMP180IIC < 0)
	{
		printf("Cannot open the Barometer IIC device, errno: %d\n", errno);
		exit(1);
	}
    ioctl(FD_BMP180IIC, I2C_TIMEOUT , 30);
}

/* ************************************************************************** */
/** configure, initialize the BMP 180 Barometer
/* ************************************************************************** */
void init_bmp180(){
    open_iic1_device();
	select_slave_bmp180();
	init_bmp180_chip();
	initBmp180Semaphores();
	measure_bmp180_measures();
}

/* ************************************************************************** */
/** configure, initialize the BMP 180 Barometer Chip
/* ************************************************************************** */
void init_bmp180_chip(){
	char adr = AC1_ADDR;
	write(FD_BMP180IIC, &adr, 1);

	unsigned char bufbe[22];

	read(FD_BMP180IIC, &bufbe[0], 22);

	barom_params.ac1=(bufbe[0] << 8) + bufbe[1];
	barom_params.ac2=(bufbe[2] << 8) + bufbe[3];
	barom_params.ac3=(bufbe[4] << 8) + bufbe[5];
	barom_params.ac4=(bufbe[6] << 8) + bufbe[7];
	barom_params.ac5=(bufbe[8] << 8) + bufbe[9];
	barom_params.ac6=(bufbe[10] << 8) + bufbe[11];
	barom_params.b1=(bufbe[12] << 8) + bufbe[13];
	barom_params.b2=(bufbe[14] << 8) + bufbe[15];
	barom_params.mb=(bufbe[16] << 8) + bufbe[17];
	barom_params.mc=(bufbe[18] << 8) + bufbe[19];
	barom_params.md=(bufbe[20] << 8) + bufbe[21];
}

/* ************************************************************************** */
/** 
/* ************************************************************************** */
void select_slave_bmp180(){
	if (ioctl(FD_BMP180IIC, I2C_SLAVE, BAROMETER_IIC_ADR) < 0) {
		printf("Cannot set IIC bpm180's slave addr, errno: %d\n", errno);
		exit(1);
	}
}

/* ************************************************************************** */
/** init semaphores
/* ************************************************************************** */
void initBmp180Semaphores(){
    // semaphore to let the bmp180 sensor starts to measure
    if( sem_init(&sem_startBmp180Measure, 0, 0) ){
        // error
        printf("Error with semaphore sem_startBmp180Measure\n");
        printErrno();
    }
    // semaphore to let the Bmp180 sensor signal its measurements are done
    if( sem_init(&sem_Bmp180MeasureDone, 0, 0) ){
        // error
        printf("Error with semaphore sem_Bmp180MeasureDone\n");
        printErrno();
    }
}


/* ************************************************************************** */
/** 
/* ************************************************************************** */
pthread_t bmp180_thread;
void measure_bmp180_measures(){
	pthread_create( &bmp180_thread, NULL, (void *) bmp180Thread, NULL);
}


/* ************************************************************************** */
/**
/* ************************************************************************** */
int bmp180Thread(void * ptr){
	while(1){
		// wait for the signal to start the measure
		sem_wait(&sem_startBmp180Measure);
		// measure
		measure_bmp180();
	}
}


/* ************************************************************************** */
/** measure
/* ************************************************************************** */
void measure_bmp180(){
	// TODO measure
	barometer_read();

	// signal the measurement termination
	sem_post(&sem_Bmp180MeasureDone);
}


/* ************************************************************************** */
/** This is not my implementation, I just took it from my colleagues 
/* ************************************************************************** */
float barometer_read(){
 	unsigned char BytesRead, BytesWrite;

	unsigned char bufbe[22];
	unsigned char bufki[2];
	long ut,up;
	float b3,b5,b6,x1,x2,x3,p,t;
	float b4,b7;
	float alt;

	bufki[0]=0xf4;
	bufki[1]=0x2e;
	BytesWrite = write(FD_BMP180IIC, &bufki[0], 2);
	usleep(4500);

	bufki[0]=0xf6;
	BytesWrite = write(FD_BMP180IIC, &bufki[0], 1);
	BytesRead = read(FD_BMP180IIC, &bufbe[0], 2);

	ut=(bufbe[0]<<8)+bufbe[1];

	bufki[0]=0xf4;
	bufki[1]=0x34;
	BytesWrite = write(FD_BMP180IIC, &bufki[0], 2);
	usleep(4500);

	bufki[0]=0xf6;
	BytesWrite = write(FD_BMP180IIC, &bufki[0], 1);
	BytesRead = read(FD_BMP180IIC, &bufbe[0], 3);
	up=((bufbe[0]<<16)+(bufbe[1]<<8)+bufbe[3])>>8;


	// temperature calculation
	x1=(ut-barom_params.ac6)*barom_params.ac5/32768.0;
	x2=barom_params.mc*2048.0/(x1+barom_params.md);
	b5=x1+x2;
	t=(float)(b5+8)/16 * 0.1;

	// pressure calculation
	b6=b5-4000;
	x1=(barom_params.b2*(b6*b6/4096.0))/2048.0;
	x2=barom_params.ac2*b6/2048.0;
	x3=x1+x2;
	b3=((barom_params.ac1*4+x3)+2)/4.0;
	x1=barom_params.ac3*b6/8192.0;
	x2=(barom_params.b1*(b6*b6/4096.0))/65536.0;
	x3=((x1+x2)+2)/4.0;
	b4=barom_params.ac4*(unsigned long)(x3+32768.0)/32768.0;
	b4=barom_params.ac4*(float)(x3+32768)/32768.0;
	b7=((unsigned long)up-b3)*50000;
	if(b7 < 0x80000000){
		p=(b7*2)/b4;
	} else {
		p=(b7/b4)*2;
	}
	x1=(p/256.0)*(p/256.0);
	x1=(x1*3038)/65536.0;
	x2=(-7357*p)/65536.0;
	p=p+(x1+x2+3791)/16.0;

	// altitude calculation
	alt=44330*(1-pow((p/101325.0),0.190263236508484));

	printf("%f\t%f\t%f\n",t,p,alt);
	return alt;
}
