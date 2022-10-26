#include <stdio.h>
#include <unistd.h>

int main() {
    int p1, p2;
    while ((p1 = fork()) == - 1);

    if (p1 == 0) {
        // subprocess 1
        putchar('b');
    } else {
        while ((p2 = fork()) == -1);
        if (p2 == 0) {
            // subprocess 2
            putchar('c');
        } else {
            // main process
            putchar('a');
        }
    }
    return 0;
}
