/**********************************************************************
 * DESCRIPTION:
 *   Serial Concurrent Wave Equation - C Version
 *   This program implements the concurrent wave equation
 *********************************************************************/
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAXPOINTS 1000000
#define MAXSTEPS 1000000
#define MINPOINTS 20
#define FAC 6.28318530f

void check_param(void);
void update(void);
void printfinal(void);

int nsteps,                  /* number of time steps */
    tpoints,                 /* total points along string */
    rcode;                   /* generic return code */
float values[MAXPOINTS + 2], /* values at time t */
    oldval[MAXPOINTS + 2],   /* values at time (t-dt) */
    newval[MAXPOINTS + 2];   /* values at time (t+dt) */

/**********************************************************************
 *	Checks input values from parameters
 *********************************************************************/
void check_param(void) {
    char tchar[20];

    /* check number of points, number of iterations */
    while ((tpoints < MINPOINTS) || (tpoints > MAXPOINTS)) {
        printf("Enter number of points along vibrating string [%d-%d]: ",
               MINPOINTS, MAXPOINTS);
        scanf("%s", tchar);
        tpoints = atoi(tchar);
        if ((tpoints < MINPOINTS) || (tpoints > MAXPOINTS))
            printf("Invalid. Please enter value between %d and %d\n", MINPOINTS,
                   MAXPOINTS);
    }
    while ((nsteps < 1) || (nsteps > MAXSTEPS)) {
        printf("Enter number of time steps [1-%d]: ", MAXSTEPS);
        scanf("%s", tchar);
        nsteps = atoi(tchar);
        if ((nsteps < 1) || (nsteps > MAXSTEPS))
            printf("Invalid. Please enter value between 1 and %d\n", MAXSTEPS);
    }

    printf("Using points = %d, steps = %d\n", tpoints, nsteps);
}

void work(int idx) {
    float oldvalt, newvalt, valt;
    oldvalt = valt = sin(FAC * ((float)(idx - 1) / (tpoints - 1)));
    for (int i = 1; i <= nsteps; i++) {
        /* global endpoints */
        if (idx == 1 || idx == tpoints) {
            newvalt = 0.0;
        } else {
            newvalt = (2.0 * valt) - oldvalt + ((double)-0.18f * valt);
        }
        oldvalt = valt;
        valt = newvalt;
    }
    values[idx] = valt;
}

/**********************************************************************
 *     Update all values along line a specified number of times
 *********************************************************************/
void update() {
    int i, j;
    /* Update points along line for this time step */
    for (j = 1; j <= tpoints; j++) {
        work(j);
    }
}

/**********************************************************************
 *     Print final results
 *********************************************************************/
void printfinal() {
    int i;
    for (i = 1; i <= tpoints; i++) {
        printf("%6.4f ", values[i]);
        if (i % 10 == 0) printf("\n");
    }
}

/**********************************************************************
 *	Main program
 *********************************************************************/
int main(int argc, char *argv[]) {
    sscanf(argv[1], "%d", &tpoints);
    sscanf(argv[2], "%d", &nsteps);
    check_param();
    printf("Initializing points on the line...\n");
    printf("Updating all points for all time steps...\n");
    update();
    printf("Printing final results...\n");
    printfinal();
    printf("\nDone.\n\n");

    return 0;
}
