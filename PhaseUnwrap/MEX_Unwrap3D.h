/********************************************************************
 * Include file for MEX_Unwrap3D.c
 * AUTHOR : Mike Tyszka, Ph.D.
 * PLACE  : Caltech BIC
 * DATES  : 11/11/02 JMT Update phase extrapolation algorithm to robust
 *                       consensus of nearest neighbors.
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2016 Mike Tyszka
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 *   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
 *   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 *   permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 *   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
 *   Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 *   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 *   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
