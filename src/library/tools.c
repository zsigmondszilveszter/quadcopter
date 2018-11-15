/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-13
*
******************************************************************************/

#include <time.h>

clock_t startTimer(){
    return clock();
}

double measureTime(clock_t startTime){
    clock_t end = clock();
    return (double)(end - startTime) / CLOCKS_PER_SEC;
}