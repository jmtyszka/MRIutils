/************************************************************
 * Unwrap 2D phase image by region growing with nearest
 * neighbour or linear prediction of unwrapped phase.
 *
 * SYNTAX: PSI_UW = MEX_Unwrap2D(PSI_W, MAG, MAG_THRESH)
 *
 * AUTHOR : Mike Tyszka, Ph.D.
 * PLACE  : Caltech BIC
 * DATES  : 05/12/00 Strip DownDyadHi.c in WaveLab as an example
 *          06/16/00 Port unwrap2D.C code from jmt@gg.caltech.edu
 *          07/05/00 Implement new region growing algorithm
 *                   using a pixel stack and linear/nn prediction
 *          03/14/01 Port to Windows2000 Matlab R12
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
 ************************************************************/

#include <stdio.h>
#include <math.h>
#include <mex.h>

#define DEBUG 0
#define LINEAR 0

#define PSI_UW_MAT   plhs[0]
#define MASK_MAT     plhs[1]

#define PSI_W_MAT    prhs[0]
#define MAG_MAT      prhs[1]
#define MAGTH_MAT    prhs[2]

#define TWO_PI (2.0 * M_PI)

#define LOC2D(x,y) ((x) + nx * (y))
#define xloop for(x=0;x<nx;x++)
#define yloop for(y=0;y<ny;y++)
#define iloop for(i=0;i<imsize;i++)

/* Function declarations */
static void add_neighbours(int,
			   int *,
			   int *,
			   int *,
			   int *,
			   int, int);

static void add_pixel(int, int,
		      int *,
		      int *,
		      int *,
		      int *,
		      int, int);

int inbounds(int, int, int, int);

static void dump_stack(int, int *);

double predict_phase(int, double *, int *, int *, int, int);

static void extrap_phase(double *,
			 double *,
			 double *,
			 int *,
			 int *,
			 int, int,
			 int, int,
			 int, int);

static void downstack(int *, int *);

static void find_seed(int *,
		      double *,
		      int *,
		      int *,
		      int *,
		      int *,
		      int *,
		      int, int);

int seed_ambiguity(int,
		   double *,
		   int *,
		   int, int);

/************************************************************
 * MAIN ENTRY POINT TO MEX_Unwrap2D()
 ************************************************************/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int this_loc, i;
  int nx_psi, ny_psi;
  int nx_mag, ny_mag;
  int nx, ny;
  double *psi_uw;
  double *psi_w;
  double *mag;
  double *magth;
  double *mask;
  double psi_p;
  int *visited, *trusted;
  int *stack;
  int imsize;
  int seed_loc;
  int nstack;
  int nmask;
  int nunwrapped;
  int m;
  double dp;

  /* Check for correct number of arguments */
  mxAssert(nrhs == 3,
	   "MEX_Unwrap2D: [psi_uw, mask] = MEX_unwrap2d(psi_w, mag, magthresh)");
  mxAssert(nlhs == 2,
	   "MEX_Unwrap2D: [psi_uw, mask] = MEX_unwrap2d(psi_w, mag, magthresh)");

  /* Get matrix dimensions */
  nx_psi = mxGetM(PSI_W_MAT);
  ny_psi = mxGetN(PSI_W_MAT);
  nx_mag = mxGetM(MAG_MAT);
  ny_mag = mxGetN(MAG_MAT);

  mxAssert((nx_psi == nx_mag) && (ny_psi == ny_mag),
    "MEX_Unwrap2D: psi and mag images are different sizes");

  nx = nx_psi;
  ny = ny_psi;
  imsize = nx * ny;

  /* Create a real matrix for the return arguments */
  PSI_UW_MAT = mxCreateDoubleMatrix(nx, ny, mxREAL);
  MASK_MAT   = mxCreateDoubleMatrix(nx, ny, mxREAL);

  /* Make space for internal matrices and stacks */
  trusted   = (int *)mxCalloc(imsize, sizeof(int));
  visited   = (int *)mxCalloc(imsize, sizeof(int));
  stack     = (int *)mxCalloc(imsize, sizeof(int));

  /* Get the data pointers */
  psi_w   = mxGetPr(PSI_W_MAT);
  psi_uw  = mxGetPr(PSI_UW_MAT);
  mag     = mxGetPr(MAG_MAT);
  magth   = mxGetPr(MAGTH_MAT);
  mask    = mxGetPr(MASK_MAT);

  /************************************************************
   * Initialize unwrapped phase matrix, visited map
   ************************************************************/

  nmask = 0;

  iloop {
    psi_uw[i] = psi_w[i];
    trusted[i] = (mag[i] >= *magth);
    visited[i] = 0; /* Unvisited*/

    mask[i] = trusted[i];

    if (mask[i] == 1) nmask++;
  }

  /************************************************************
   * Find the initial seed location
   ************************************************************/

  find_seed(&seed_loc,
	    mag,
	    visited,
	    trusted,
	    stack,
	    &nstack,
	    &nunwrapped,
	    nx, ny);

  /************************************************************
   * MAIN REGION GROWING LOOP
   ************************************************************/

  nunwrapped = 0;

  while (nunwrapped < nmask) {

    while (nstack > 0 && nstack < imsize) {

      /* Get location at top of stack */
      this_loc = stack[0];

      /* Remove this location from the stack */
      downstack(&nstack, stack);

      psi_p = predict_phase(this_loc,
			    psi_uw,
			    visited,
			    trusted,
			    nx, ny);

      /* Estimate the ambiguity factor for the wrapped phase */
      dp = psi_p - psi_w[this_loc];
      m = (int)(fabs(dp) / TWO_PI + 0.5);
      m = (dp < 0.0) ? -m : m;

      /* Unwrap the phase using the ambiguity estimate */
      psi_uw[this_loc] = psi_w[this_loc] + m * TWO_PI;
      
      /* Mark this location as unwrapped */
      visited[this_loc] = 2;
      nunwrapped++;

      /* Add this locations neighbours to the end of the stack */
      add_neighbours(this_loc,
		     stack,
		     visited,
		     trusted,
		     &nstack,
		     nx, ny);

    } /* While stack is not empty */

    find_seed(&seed_loc,
	      mag,
	      visited,
	      trusted,
	      stack,
	      &nstack,
	      &nunwrapped,
	      nx, ny);

    /************************************************************
     * Estimate the phase ambiguity at this seed based on
     * previously unwrapped regions
     ************************************************************/
    m = seed_ambiguity(seed_loc,
		       psi_uw,
		       visited,
		       nx, ny);

    /* Correct the ambiguity before continuing with the new region growth */
    psi_uw[seed_loc] = psi_w[seed_loc] + m * TWO_PI;

  } /* While unwrapped pixels still exist in trusted regions */

  if (nstack >= imsize)
    mexPrintf("Stack grew too large - aborting\n");
  
  /* Clean up */
  mxFree(visited);
  mxFree(trusted);
  mxFree(stack);

}

/************************************************************
 * Add the 8 compass neighbors to the stack with conditions.
 ************************************************************/
static void add_neighbours(int loc,
			   int *stack,
			   int *visited,
			   int *trusted,
			   int *nstack,
			   int nx, int ny)
{
  int x = loc % nx;
  int y = loc / nx;

  add_pixel(x,  y+1,stack,visited,trusted,nstack,nx,ny);
  add_pixel(x+1,y+1,stack,visited,trusted,nstack,nx,ny);
  add_pixel(x+1,y  ,stack,visited,trusted,nstack,nx,ny);
  add_pixel(x+1,y-1,stack,visited,trusted,nstack,nx,ny);
  add_pixel(x  ,y-1,stack,visited,trusted,nstack,nx,ny);
  add_pixel(x-1,y-1,stack,visited,trusted,nstack,nx,ny);
  add_pixel(x-1,y  ,stack,visited,trusted,nstack,nx,ny);
  add_pixel(x-1,y+1,stack,visited,trusted,nstack,nx,ny);
}

/************************************************************
 * Add a given voxel location to the stack if it is:
 * (a) in bounds AND
 * (b) not previously visited
 * (c) in a trusted region
 ************************************************************/
static void add_pixel(int x, int y,
		      int *stack,
		      int *visited,
		      int *trusted,
		      int *nstack,
		      int nx, int ny)
{
  int loc = LOC2D(x,y);

  if (inbounds(x,y,nx,ny) && visited[loc] == 0 && trusted[loc] == 1) {

    /* Add location to the stack */
    stack[*nstack] = loc;
    
    /* Mark as a neighbour */
    visited[loc] = 1;

    /* Increment the stack length */
    (*nstack)++;
  }
}

/************************************************************
 * Check where point (x,y) is within bounds [0..nx-1, 0..ny-1]
 ************************************************************/
int inbounds(int x, int y, int nx, int ny)
{
  return (x >= 0 && x < nx && y >= 0 && y < ny);
}

/************************************************************
 * DEBUG
 * Print out the whole location stack
 ************************************************************/
static void dump_stack(int n, int *stack)
{
  int i;
  for (i = 0; i < n; i++) {
    mexPrintf("%d: %d\n", i, stack[i]);
  }
}

/************************************************************
 * Use nearest-neighbour prediction of phase
 * at a given voxel. Final phase prediction is based on the
 * weighted mean of the phase predictions in all 8 compass
 * directions. The weights are the number of points (0 or 1)
 * used to back extrapolate the phase in each direction.
 ************************************************************/
double predict_phase(int loc0,
		     double *psi_uw,
		     int *visited,
		     int *trusted,
		     int nx, int ny)
{
  int i;
  int x0 = loc0 % nx;
  int y0 = loc0 / nx;
  double p[8];
  double w[8];
  double sum_pw, sum_w;

  /* Back extrapolate the phase in the compass directions */
  extrap_phase(p+0, w+0, psi_uw, visited, trusted, x0, y0,  0,  1, nx, ny);
  extrap_phase(p+1, w+1, psi_uw, visited, trusted, x0, y0,  1,  1, nx, ny);
  extrap_phase(p+2, w+2, psi_uw, visited, trusted, x0, y0,  1,  0, nx, ny);
  extrap_phase(p+3, w+3, psi_uw, visited, trusted, x0, y0,  1, -1, nx, ny);
  extrap_phase(p+4, w+4, psi_uw, visited, trusted, x0, y0,  0, -1, nx, ny);
  extrap_phase(p+5, w+5, psi_uw, visited, trusted, x0, y0, -1, -1, nx, ny);
  extrap_phase(p+6, w+6, psi_uw, visited, trusted, x0, y0, -1,  0, nx, ny);
  extrap_phase(p+7, w+7, psi_uw, visited, trusted, x0, y0, -1,  1, nx, ny);

  /* Calculate weighted mean predicted phase */
  sum_pw = 0.0;
  sum_w = 0.0;
  for (i = 0; i < 8; i++) {
    sum_pw += p[i] * w[i];
    sum_w += w[i];
  }

  return(sum_pw / sum_w);

}

/************************************************************
 * Extrapolate the phase at (x,y) from 1 voxel in
 * the direction specified by (dx,dy).
 * Voxels along (dx,dy) are only used if they have been
 * visited and are within bounds.
 * The extrapolated phase is returned in *p.
 * The total number of voxels used in the extrapolation is
 * returned in *w.
 ************************************************************/
static void extrap_phase(double *p,
			 double *w,
			 double *psi_uw,
			 int *visited,
			 int *trusted,
			 int x0, int y0,
			 int dx, int dy,
			 int nx, int ny)
{
  int x1, y1, loc1;
  int x2, y2, loc2;
  double dp;

  /* Set defaults for the extrapolated phase and weight */
  *p = 0.0;
  *w = 0;

  /* Determine location of first point along vector */
  x1 = x0 + dx;
  y1 = y0 + dy;
  loc1 = LOC2D(x1,y1);

  /* If this point is in bounds and has been unwrapped ... */
  if (inbounds(x1, y1, nx, ny)) {
    if (visited[loc1] == 2) {

      /* Nearest neighbour prediction of phase */
      *p = psi_uw[loc1];
      *w = 1.0;

      /* Linear prediction */
      if (LINEAR) {

	x2 = x1 + dx;
	y2 = y1 + dy;
	loc2 = LOC2D(x2,y2);

	if (inbounds(x2, y2, nx, ny)) {
	  if (visited[loc2] == 2) {

	    /* Nearest neighbour prediction of phase */
	    dp = psi_uw[loc2] - psi_uw[loc1];

	    *p = psi_uw[loc1] - dp;
	    *w = 2.0;
	  }
	}
      } /* If LINEAR */

    }
  }
      
}

/************************************************************
 * Eliminate the first member of the stack and decrement the
 * stack length. The function forces the stack length to 0
 * if it was previously < 1.
 ************************************************************/
static void downstack(int *nstack, int *stack)
{
  int i;

  if (*nstack > 1) {
    for (i = 1; i < *nstack; i++) {
      stack[i-1] = stack[i];
    }
    (*nstack)--;
  } else {
    /* Force nstack = 0 if previous nstack <= 1 */
    *nstack = 0;
  }
}


/************************************************************
 * Find a seed in an unvisited, trusted region 
 * with the largest mag signal
 ************************************************************/
static void find_seed(int *seed_loc,
		      double *mag,
		      int *visited,
		      int *trusted,
		      int *stack,
		      int *nstack,
		      int *nunwrapped,
		      int nx, int ny)
{
  double max_mag = 0.0;
  int max_i = 0;
  int i;
  int imsize = nx * ny;

  iloop {
    if (trusted[i] == 1 && visited[i] < 2) {
      if (mag[i] > max_mag) {
	max_mag = mag[i];
	max_i   = i;
      }
    }
  }

  *seed_loc = max_i;

  /* Mark the seed point as unwrapped (2) */
  visited[*seed_loc] = 2;
  (*nunwrapped)++;

  /* Initialize the neighbour stack counter */
  *nstack = 0;

  /* Add compass neighbours to the stack */
  add_neighbours(*seed_loc,
		 stack,
		 visited,
		 trusted,
		 nstack,
		 nx, ny);
}

/************************************************************
 * Estimate the phase ambiguity at this seed based on
 * previously unwrapped regions
 ************************************************************/
int seed_ambiguity(int seed_loc,
		   double *psi_uw,
		   int *visited,
		   int nx, int ny)
{
  int m;
  int x, y;
  int sx = seed_loc % nx;
  int sy = seed_loc / nx;
  double dx, dy, dr;
  double min_dr = 1e30;
  double dp;
  int loc;
  int closest_loc = 0;

  /* Search for the nearest unwrapped, trusted point to the seed */
  for (loc = 0, y = 0; y < ny; y++) {
    for (x = 0; x < nx; x++, loc++) {

      if (visited[loc] == 2 && x != sx && y != sy) {

	dx = (double)(sx - x);
	dy = (double)(sy - y);

	dr = sqrt(dx*dx + dy*dy);

	if (dr < min_dr) {
	  min_dr = dr;
	  closest_loc = loc;
	}

      } /* Only if visited and unwrapped */

    }
  }

  /************************************************************
   * Now calculate the ambiguity between the wrapped seed
   * phase and the unwrapped neighbour phase.
   * NB if the seed is unvisited, then psi_uw = psi_w.
   ************************************************************/
  dp = psi_uw[closest_loc] - psi_uw[seed_loc];
  m = (int)(fabs(dp) / TWO_PI + 0.5);
  m = (dp < 0) ? -m : m;

  return m;
}
