#include "mbed.h"

DigitalOut led1(LED1);

int main()
{
    while(1)
    {
        led1 = 0;
        wait(0.5);
        led1 = 1;
        wait(2);
    }
}
