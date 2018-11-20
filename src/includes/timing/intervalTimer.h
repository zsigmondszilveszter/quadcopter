/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-11-17
*
* Interval Timer Header
* This timer provide the interval for system cyclic functioning
*
******************************************************************************/

#ifndef _INTERVAL_TIMER_H    /* Guard against multiple inclusion */
#define _INTERVAL_TIMER_H

#include <signal.h>
#include <time.h>

void initTimer(void);
void timerExpiredHandler(int sig, siginfo_t *si, void *uc);
void startTimer(void);
void stopTimer(void);
void deleteTimer(void);

#endif /* _INTERVAL_TIMER_H */