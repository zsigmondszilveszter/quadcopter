/*
    Szilveszter Zsigmond 2018.06.24
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>


pthread_t thread[10];
int iret[10];
int thread_counter;
