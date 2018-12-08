/*****************************************************************************/
/**
* Szilveszter Zsigmond 
* 2018-11-13
*
* Finite-state machine header
*
******************************************************************************/

#ifndef _FINITE_STATE_MACHINE_H    /* Guard against multiple inclusion */
#define _FINITE_STATE_MACHINE_H

void initFiniteStateMachine(void);
void finiteStateMachineOneIteration(void);
void initTimer(void);
void initSensors(void);
void finiteState_measure(void);

#endif /* _FINITE_STATE_MACHINE_H */