#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>

int p1, p2;

int main() {
    int fd[2];
    char outpipe[100], inpipe[100];
    // create a pipe, fd[0] for reading, fd[1] for writing
    pipe(fd);

    while((p1=fork()) == -1);
    if (p1 == 0) {
        // subprocess 1
        printf("p1\n");
        lockf(fd[1], 1, 0);
        sprintf(outpipe, "child 1 process is sending a message!");
        write(fd[1], outpipe, 50);
        // sleep(1);
        lockf(fd[1], 0, 0);
        exit(0);
    } else {
        while((p2=fork()) == -1);
        if(p2 == 0) {
            // subprocess 2
            printf("p2\n");
            lockf(fd[1], 1, 0);
            sprintf(outpipe, "child 2 process is sending a message!");
            write(fd[1], outpipe, 50);
            // sleep(1);
            lockf(fd[1], 0, 0);
            exit(0);
        } else {
            // main process
            printf("parent\n");
            wait(0);
            read(fd[0], inpipe, 50);
            printf("[readpipe] %s\n", inpipe);
            wait(0);
            read(fd[0], inpipe, 50);
            printf("[readpipe] %s\n", inpipe);
            exit(0);
        }
    }
}

