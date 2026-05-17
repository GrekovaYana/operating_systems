/*
 * Автор: Грекова Яна Викторовна
 * Группа: 02271-ДБ
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <sys/ipc.h>
#include <semaphore.h>
#include <fcntl.h>
#include <errno.h>
#include "fact_calc.h"

#define SHM_SIZE sizeof(int)
#define SEM_NAME "/grekova_sem"

int main() {
    key_t key = ftok(".", 'G');
    if (key == -1) {
        perror("ftok");
        exit(1);
    }

    int shm_id = shmget(key, SHM_SIZE, IPC_CREAT | 0666);
    if (shm_id == -1) {
        perror("shmget");
        exit(1);
    }

    int* shared_data = (int*)shmat(shm_id, NULL, 0);
    if (shared_data == (int*)-1) {
        perror("shmat");
        exit(1);
    }

    sem_t* sem = sem_open(SEM_NAME, O_CREAT | O_EXCL, 0666, 1);
    if (sem == SEM_FAILED) {
        if (errno == EEXIST) {
            sem = sem_open(SEM_NAME, 0);
            if (sem == SEM_FAILED) {
                perror("sem_open existing");
                exit(1);
            }
        } else {
            perror("sem_open new");
            exit(1);
        }
    }

    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        exit(1);
    }

    if (pid == 0) {
        sem_wait(sem);
        printf("Child read: %d\n", *shared_data);
        sem_post(sem);

        if (shmdt(shared_data) == -1) {
            perror("child shmdt");
        }
        exit(0);
    } else {
        int result = fact_calc(7);

        sem_wait(sem);
        *shared_data = result;
        printf("Parent wrote: %d\n", result);
        sem_post(sem);

        wait(NULL);

        if (shmdt(shared_data) == -1) {
            perror("parent shmdt");
        }
    }

    return 0;
}