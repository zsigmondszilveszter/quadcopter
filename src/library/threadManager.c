/*
    Szilveszter Zsigmond 18.09.2018
*/
#include "threadManager.h"
#include "tcpWrapper.h"



void cancellAllThread(){
    // // wait for threads to finish
    // for(int i=0; i<thread_counter; i++){
    //     pthread_join( thread[i], NULL);
    //     printf("Thread nr %i terminated.\n",i);
    // }
}

/*
* This function waits and blocks the execution of main thread(where it is called) until all the thread finish their work
*/
void waitForThreads(){
    for(char i=0; i<TCP_WORKER_NR; i++){
        pthread_join( tcpWorkerThreads[i], NULL);
    }
}