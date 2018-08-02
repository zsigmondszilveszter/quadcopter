#include "general_header.h"
#include "thread_handler.h"

/*
* This function waits and blocks the execution of program until all the thread finish their work
* - thread_counter - is a global variable for counting the started threads
* - thread[] - is an array holding the started threads's pointer (or handler?)
*/
void wait_threads_to_finish(){
    // wait for the threads to finish
    for(int i=0; i<thread_counter; i++){
        pthread_join( thread[i], NULL);
        printf("Thread nr %i terminated.\n",i);
    }
}
