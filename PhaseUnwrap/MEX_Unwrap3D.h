/********************************************************************
 * Include file for MEX_Unwrap3D.c
 * AUTHOR : Mike Tyszka, Ph.D.
 * PLACE  : Caltech BIC
 * DATES  : 11/11/02 JMT Update phase extrapolation algorithm to robust
 *                       consensus of nearest neighbors.
 ********************************************************************/

#include <stdio.h>
#include <math.h>
#include <mex.h>

#define DEBUG 0
#define VERBOSE 1
#define LINEAR 0

#define PSI_UW_MAT   plhs[0]
#define MASK_MAT     plhs[1]

#define PSI_W_MAT    prhs[0]
#define TRUST_MAT    prhs[1]

#define TWO_PI (2.0 * M_PI)

#define LOC3D(x,y) ((x) + nx * (y + ny * (z)))
#define xloop for(x=0;x<nx;x++)
#define yloop for(y=0;y<ny;y++)
#define yloop for(z=0;z<nz;z++)
#define iloop for(i=0;i<volsize;i++)

/* Function declarations */
static void add_neighbours(int,
			   int *,
			   char *,
			   double *,
			   int *,
			   int,
			   int,
			   int);

static void add_pixel(int, int, int,
		      int *,
		      char *,
		      double *,
		      int *,
		      int,
		      int,
		      int);

int inbounds(int, int, int, int, int, int);

static void dump_stack(int, int *);

double predict_phase(int,
		     double *,
		     char *,
		     double *,
		     int, int, int);

static void extrap_phase(double *,
			 double *,
			 double *,
			 char *,
			 double *,
			 int, int, int,
			 int, int, int,
			 int, int, int);

static void downstack(int *, int *);

static void find_seed(int *,
		      double *,
		      char *,
		      double *,
		      int *,
		      int *,
		      int *,
		      int, int, int);