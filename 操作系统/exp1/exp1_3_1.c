#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <stdlib.h>
#include <unistd.h>

#define MSGKEY 70

typedef struct msgform {
    long mtype;
    char mtrex[1024];
} msgform;

msgform msg;

int msgqid, p1, p2;

/*
void init_msgs() {
    for (int i = 1; i <= 10; i++) {
        msg[i-1].mtype = i;
        sprintf(msg[i-1].mtrex, "This is message %d", i);
    }
}
*/
void CLIENT() {
    msgqid = msgget(MSGKEY, 0777|IPC_CREAT);
    for (int i = 1; i <= 10; i++) {
        msg.mtype = i;
        sprintf(msg.mtrex, "This is message %d", i);
        msgsnd(msgqid, &msg, 1024, 0);
        printf("[client] message %d sent!\n", i);
    }
    exit(0);
}

void SERVER() {
    msgform tmp;
    msgqid = msgget(MSGKEY, 0777|IPC_CREAT);
    do {
        msgrcv(msgqid, &tmp, 1024, 0, 0);
        printf("[server] msg %d received: \"%s\"\n", tmp.mtype, tmp.mtrex);
    } while(tmp.mtype != 10);
    msgctl(msgqid, IPC_RMID, 0);
    exit(0);
}

void main() {
    // init_msgs();
    while((p1=fork()) == -1);
    
    if (!p1){
    // subprocess p1 as server, which will send msg out
        SERVER();
    } else {
        while((p2=fork()) == -1);
        if (!p2) {
        // subprocess p2 as client, which will recv msg 
            CLIENT();
        } else {
        // main process, just wait for p1 and p2 to exit
            wait();
            wait();
        }
    }
}

