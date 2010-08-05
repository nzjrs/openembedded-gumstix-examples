#include <stdio.h>
#include <linux/i2c-dev.h> 

#include "lib.h"

int main(int argc, char **argv)
{
    printf("Hello %s\n", get_world());
    return 0;
}
