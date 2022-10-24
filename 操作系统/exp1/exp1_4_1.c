#include <stdio.h>
#include <sys/types.h>
#include <sys/shm.h>
#include <sys/ipc.h>
#include <stdlib.h>
#include <sys/sem.h>

#define SHMKEY 75
#define SEM_KEY 70

int shmid, i;
int *addr;
int semid;


union semun {
	int val;
	struct semid_ds *buf;
	unsigned short *array;
	struct seminfo *__buf;
	void *__pad;
};



void P(int sem_id, int sem_num) {
    struct sembuf buf;
    buf.sem_flg = 0;
    buf.sem_op = -1;
    buf.sem_num = sem_num;

    int ret = semop(sem_id, &buf, 1);
    if (ret < 0) {
        printf("P failed on %d.%d\n", sem_id, sem_num);
        return;
    }
}

void V(int sem_id, int sem_num) {
    struct sembuf buf;
    buf.sem_flg = 0;
    buf.sem_op = 1;
    buf.sem_num = sem_num;

    int ret = semop(sem_id, &buf, 1);
    if (ret < 0) {
        printf("V failed on %d.%d\n", sem_id, sem_num);
        return;
    }
}

void CLIENT() {
    shmid = shmget(SHMKEY, 1024, 0777|IPC_CREAT);
    addr = shmat(shmid, 0, 0);
    semid = semget(SEM_KEY, 2, 0777|IPC_CREAT);
    for (int i = 9; i >= 0; i--) {
        P(semid, 0);
        printf("[Client]send: %d\n", i);
        fflush(stdout);
        *addr = i;
        V(semid, 1);
        sleep(1);
    }
    exit(0);
}

void SERVER() {
    shmid = shmget(SHMKEY, 1024, 0777|IPC_CREAT);
    addr = shmat(shmid, 0, 0);
    semid = semget(SEM_KEY, 2, 0777|IPC_CREAT);
    do {
        P(semid, 1);
        printf("[Server]received: %d\n", *addr);
        fflush(stdout);
        V(semid, 0);
        sleep(1);
    } while (*addr);
    shmctl(shmid, IPC_RMID, 0);
    exit(0);
}

void init_sem(int sem_id, int sem_num, int val) {
    union semun var;
    var.val = val;
    if (semctl(sem_id, sem_num, SETVAL, var) < 0) {
        printf("initialize failed\n");
        exit(-1);
    }
}

void rm_sem(int sem_id, int sem_num) {
    if (semctl(sem_id, sem_num, IPC_RMID) < 0) {
        printf("deleting failed\n");
    }
}

int main() {
   int p1, p2;
   while((p1 = fork()) == -1);
   if (p1 > 0) {
       while((p2 = fork()) == -1);
       if (p2 > 0) {
           // main process
           semid = semget(SEM_KEY, 2, 0666|IPC_CREAT);
           init_sem(semid, 0, 1);
           init_sem(semid, 1, 0);

           wait();
           wait();

       } else {
           // subprocess 2
           CLIENT();
       }
   } else {
       // subprocess 1
       SERVER();
   }
}
