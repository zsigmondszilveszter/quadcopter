/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-10-13
*
******************************************************************************/


#ifndef _TOOLS_H    /* Guard against multiple inclusion */
#define _TOOLS_H

#include <time.h>

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0')


clock_t startTimeMeasure();
double measureTime(clock_t startTime);
void measureAndPrintTime(clock_t startTime);

double getRealClock();
double startRealTimeMeasure();
double measureRealTime(double startTime);
void measureAndPrintRealTime(double startTime);

void printErrno();

#endif /* _TOOLS_H */