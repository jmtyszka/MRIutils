/************************************************************
 * Unwrap 3D phase image by region growing with nearest
 * neighbour prediction of unwrapped phase.
 *
 * SYNTAX: [PSI_UW,TRUST] = MEX_Unwrap3D(PSI_W, MAG, MAG_THRESH)
 *
 * RETURNS:
 * PSI_UW = unwrapped 3D phase image
 * TRUST  = trust region mask
 *
 * AUTHOR : J. Michael Tyszka, Ph.D.
 * PLACE  : Caltech BIC
 * DATES  : 07/06/2000 JMT Adapt from MEX_Unwrap3D
 *          10/10/2005 JMT Update to Matlab 7
 *
 * REFS   : Based on ideas in Xu, Wei, Ian Cumming
 *          "A Region Growing Algorithm for InSAR Phase Unwrapping".
 *          Proceedings of the 1996 IEEE International Geoscience and Remote Sensing Symposium.
 *          IGARSS'96, pp. 2044-2046, Lincoln, USA, May. 1996.
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

#define PSI_UW_MAT   plhs[0]
#define TRUST_MAT    plhs[1]

#define PSI_W_MAT    prhs[0]
#define MAG_MAT      prhs[1]
#define MAGTH_MAT    prhs[2]

#define TWO_PI (2.0 * M_PI)

#define LOC3D(x,y,z) ((x) + nx * ((y) + ny * (z)))
#define xloop for(x=0;x<nx;x++)
#define yloop for(y=0;y<ny;y++)
#define zloop for(z=0;z<nz;z++)
#define iloop for(i=0;i<volsize;i++)

/* Function declarations */
static void add_neighbours(int,	     /* loc */
			   int *,    /* stack [] */
			   char *,   /* visited [] */
			   double *,   /* trust [] */
			   int *,    /* &nstack */
			   int,	     /* nx */
			   int,	     /* ny */
			   int);     /* nz */

static void add_pixel(int,	     /* x */
		      int,	     /* y */
		      int,	     /* z */
		      int *,	     /* stack [] */
		      char *,	     /* visited [] */
		      double *,	     /* trust [] */
		      int *,	     /* &nstack */
		      int,	     /* nx */
		      int,	     /* ny */
		      int);	     /* nz */

int inbounds(int,		     /* x */
	     int,		     /* y */
	     int,		     /* z */
	     int,		     /* nx */
	     int,		     /* ny */
	     int);		     /* nz */

double predict_phase(int,	     /* loc */
		     double *,	     /* phi_uw [] */
		     char *,	     /* visited [] */
		     double *,	     /* trust [] */
		     int,	     /* nx */
		     int,	     /* ny */
		     int);	     /* nz */

static void extrap_phase(double *,
			 double *,
			 double *,
			 char *,     /* visited [] */
			 double *,   /* trust []*/
			 int,	     /* x0 */
			 int,	     /* y0 */
			 int,	     /* z0 */
			 int,	     /* dx */
			 int,	     /* dy */
			 int,	     /* dz */
			 int,	     /* nx */
			 int,	     /* ny */
			 int);	     /* nz */

static void downstack(int *, int *);

static void find_seed(int *,	     /* &seed loc */
		      double *,	     /* mag[] */
		      char *,	     /* visited [] */
		      double *,	     /* trust [] */
		      int *,	     /* stack [] */
		      int *,	     /* &nstack */
		      int *,	     /* &nunwrapped */
		      int,	     /* nx */
		      int,	     /* ny */
		      int);	     /* nz */

static void toxyz(int, int *, int *, int *, int, int, int);

/************************************************************
 * MAIN ENTRY POINT TO MEX_Unwrap3D()
 ************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int this_loc, i;
  const int *psi_dim;
  const int *mag_dim;
  int nx, ny, nz;
  double *psi_uw;
  double *psi_w;
  double *mag;
  double *magth;
  double psi_p;
  char *visited;
  double *trust;
  int *stack;
  int volsize;
  int seed_loc;
  int nstack;
  int ntrust;
  int nunwrapped;
  int m;
  double dp;
  int ndim = 3;

  /* Check for proper number of arguments */
  mxAssert(nrhs == 3,
	   "MEX_Unwrap3D: [psi_uw, mask] = MEX_unwrap2d(psi_w, mag, magthresh)");
  mxAssert(nlhs == 2,
	   "MEX_Unwrap3D: [psi_uw, mask] = MEX_unwrap2d(psi_w, mag, magthresh)");

  /* Get matrix dimensions */
  psi_dim = mxGetDimensions(PSI_W_MAT);
  mag_dim = mxGetDimensions(MAG_MAT);

  mxAssert((psi_dim[0] == mag_dim[0]) &&  (psi_dim[1] == mag_dim[1]) && (psi_dim[2] == mag_dim[2]),
  "MEX_Unwrap3D: psi and mag volumes are different sizes");

  nx = psi_dim[0];
  ny = psi_dim[1];
  nz = psi_dim[2];
  volsize = nx * ny * nz;
  
  if (DEBUG) mexPrintf("Phase data is %d x %d x %d = %d voxels\n", nx, ny, nz, volsize);
  if (DEBUG) mexPrintf("Allocating scratch space and stack\n");

  /* Create real matrices for the return arguments */
  PSI_UW_MAT = mxCreateNumericArray(ndim, psi_dim, mxDOUBLE_CLASS, mxREAL);
  TRUST_MAT  = mxCreateNumericArray(ndim, psi_dim, mxDOUBLE_CLASS, mxREAL);

  /* Make space for internal matrices and stacks */
  visited   = (char *)mxCalloc(volsize, sizeof(char));
  stack     = (int *)mxCalloc(volsize, sizeof(int));

  /* Get the data pointers */
  psi_w   = mxGetPr(PSI_W_MAT);
  psi_uw  = mxGetPr(PSI_UW_MAT);
  mag     = mxGetPr(MAG_MAT);
  magth   = mxGetPr(MAGTH_MAT);
  trust   = mxGetPr(TRUST_MAT);

  /* Initialize unwrapped phase matrix, visited map */

  if (DEBUG) {
    mexPrintf("Initializing unwrapped phase matrix and visited map\n");
    mexPrintf("Magnitude threshold : %0.3f\n", *magth);
  }
  
  ntrust = 0;
  
  iloop {

    psi_uw[i] = psi_w[i];
    trust[i] = (double)(mag[i] >= *magth);
    visited[i] = 0; /* Unvisited*/
    if (trust[i] > 0.0) ntrust++;
  }

  /************************************************************
   * Find the initial seed location
   ************************************************************/

  if (DEBUG) mexPrintf("Finding initial seed  ... ");

  find_seed(&seed_loc,
	    mag,
	    visited,
	    trust,
	    stack,
	    &nstack,
	    &nunwrapped,
	    nx, ny, nz);

  if (DEBUG) mexPrintf("location %d\n", seed_loc);

  /************************************************************
   * MAIN REGION GROWING LOOP
   ************************************************************/

  if (DEBUG) mexPrintf("Start region growing from seed\n");

  nunwrapped = 0;

  while (nunwrapped < ntrust) {

    while (nstack > 0 && nstack < volsize) {

      /* Get location at top of stack */
      this_loc = stack[0];

      /* Remove this location from the stack */
      downstack(&nstack, stack);

      psi_p = predict_phase(this_loc,
			    psi_uw,
			    visited,
			    trust,
			    nx, ny, nz);

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
		     trust,
		     &nstack,
		     nx, ny, nz);

    } /* While stack is not empty */

    if (DEBUG) mexPrintf("Region filled : %d voxels\n", nunwrapped);
    
    if (DEBUG) mexPrintf("Finding new seed ... ");

    find_seed(&seed_loc,
              mag,
	          visited,
	          trust,
	          stack,
	          &nstack,
	          &nunwrapped,
	          nx, ny, nz);

    if (DEBUG) mexPrintf("location %d\n", seed_loc);
	          
    /************************************************************
     * Estimate the phase ambiguity at this seed based on
     * previously unwrapped regions
     ************************************************************/
    if (DEBUG) mexPrintf("Estimating region ambiguity\n");
    m = 0;

    /* Correct the ambiguity before continuing with the new region growth */
    if (DEBUG) mexPrintf("Correcting ambiguity\n");
    psi_uw[seed_loc] = psi_w[seed_loc] + m * TWO_PI;

  } /* While unwrapped pixels still exist in trust regions */

  if (nstack >= volsize)
    mexPrintf("Stack grew too large - aborting\n");
  
  /* Clean up */
  mxFree(visited);
  mxFree(stack);

  if (DEBUG) mexPrintf("Done\n");
}

/************************************************************
 * Add the 8 compass neighbors to the stack with conditions.
 ************************************************************/
static void add_neighbours(int loc,
			   int *stack,
			   char *visited,
			   double *trust,
			   int *nstack,
			   int nx,
			   int ny,
			   int nz)
{
  int x, y, z;

  toxyz(loc, &x, &y, &z, nx, ny, nz);

  add_pixel(x-1,y-1,z-1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x-1,y-1,z  ,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x-1,y-1,z+1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x-1,y  ,z-1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x-1,y  ,z  ,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x-1,y  ,z+1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x-1,y+1,z-1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x-1,y+1,z  ,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x-1,y+1,z+1,stack,visited,trust,nstack,nx,ny,nz);

  add_pixel(x  ,y-1,z-1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x  ,y-1,z  ,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x  ,y-1,z+1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x  ,y  ,z-1,stack,visited,trust,nstack,nx,ny,nz);

  /* Omit the central location */

  add_pixel(x  ,y  ,z+1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x  ,y+1,z-1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x  ,y+1,z  ,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x  ,y+1,z+1,stack,visited,trust,nstack,nx,ny,nz);

  add_pixel(x+1,y-1,z-1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x+1,y-1,z  ,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x+1,y-1,z+1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x+1,y  ,z-1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x+1,y  ,z  ,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x+1,y  ,z+1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x+1,y+1,z-1,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x+1,y+1,z  ,stack,visited,trust,nstack,nx,ny,nz);
  add_pixel(x+1,y+1,z+1,stack,visited,trust,nstack,nx,ny,nz);
}

/************************************************************
 * Add a given voxel location to the stack if it is:
 * (a) in bounds AND
 * (b) not previously visited
 * (c) in a trust region
 ************************************************************/
static void add_pixel(int x, int y, int z,
		      int *stack,
		      char *visited,
		      double *trust,
		      int *nstack,
		      int nx,
		      int ny,
		      int nz)
{
  int loc = LOC3D(x,y,z);

  if (inbounds(x,y,z,nx,ny,nz) && visited[loc] == 0 && trust[loc] > 0.0) {

    /* Add location to the stack */
    stack[*nstack] = loc;
    
    /* Mark as a neighbour */
    visited[loc] = 1;

    /* Increment the stack length */
    (*nstack)++;
  }
}

/************************************************************
 * Check whether (x,y,z) is in bounds
 ************************************************************/
int inbounds(int x, int y, int z, int nx, int ny, int nz)
{
  return (x >= 0 && x < nx &&
	  y >= 0 && y < ny &&
	  z >= 0 && z < nz);
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
		     char *visited,
		     double *trust,
		     int nx, int ny, int nz)
{
  int i;
  int x0, y0, z0;
  double p[26];
  double w[26];
  double sum_pw, sum_w;

  toxyz(loc0, &x0, &y0, &z0, nx, ny, nz);

  /* Back extrapolate the phase in the compass directions */
  extrap_phase(p+0,w+0,psi_uw,visited,trust,x0,y0,z0,-1,-1,-1,nx,ny,nz);
  extrap_phase(p+1,w+1,psi_uw,visited,trust,x0,y0,z0,-1,-1, 0,nx,ny,nz);
  extrap_phase(p+2,w+2,psi_uw,visited,trust,x0,y0,z0,-1,-1, 1,nx,ny,nz);
  extrap_phase(p+3,w+3,psi_uw,visited,trust,x0,y0,z0,-1, 0,-1,nx,ny,nz);
  extrap_phase(p+4,w+4,psi_uw,visited,trust,x0,y0,z0,-1, 0, 0,nx,ny,nz);
  extrap_phase(p+5,w+5,psi_uw,visited,trust,x0,y0,z0,-1, 0, 1,nx,ny,nz);
  extrap_phase(p+6,w+6,psi_uw,visited,trust,x0,y0,z0,-1, 1,-1,nx,ny,nz);
  extrap_phase(p+7,w+7,psi_uw,visited,trust,x0,y0,z0,-1, 1, 0,nx,ny,nz);
  extrap_phase(p+8,w+8,psi_uw,visited,trust,x0,y0,z0,-1, 1, 1,nx,ny,nz);

  extrap_phase(p+9,w+9,psi_uw,visited,trust,x0,y0,z0, 0,-1,-1,nx,ny,nz);
  extrap_phase(p+10,w+10,psi_uw,visited,trust,x0,y0,z0, 0,-1, 0,nx,ny,nz);
  extrap_phase(p+11,w+11,psi_uw,visited,trust,x0,y0,z0, 0,-1, 1,nx,ny,nz);
  extrap_phase(p+12,w+12,psi_uw,visited,trust,x0,y0,z0, 0, 0,-1,nx,ny,nz);

  extrap_phase(p+13,w+13,psi_uw,visited,trust,x0,y0,z0, 0, 0, 1,nx,ny,nz);
  extrap_phase(p+14,w+14,psi_uw,visited,trust,x0,y0,z0, 0, 1,-1,nx,ny,nz);
  extrap_phase(p+15,w+15,psi_uw,visited,trust,x0,y0,z0, 0, 1, 0,nx,ny,nz);
  extrap_phase(p+16,w+16,psi_uw,visited,trust,x0,y0,z0, 0, 1, 1,nx,ny,nz);

  extrap_phase(p+17,w+17,psi_uw,visited,trust,x0,y0,z0, 1,-1,-1,nx,ny,nz);
  extrap_phase(p+18,w+18,psi_uw,visited,trust,x0,y0,z0, 1,-1, 0,nx,ny,nz);
  extrap_phase(p+19,w+19,psi_uw,visited,trust,x0,y0,z0, 1,-1, 1,nx,ny,nz);
  extrap_phase(p+20,w+20,psi_uw,visited,trust,x0,y0,z0, 1, 0,-1,nx,ny,nz);
  extrap_phase(p+21,w+21,psi_uw,visited,trust,x0,y0,z0, 1, 0, 0,nx,ny,nz);
  extrap_phase(p+22,w+22,psi_uw,visited,trust,x0,y0,z0, 1, 0, 1,nx,ny,nz);
  extrap_phase(p+23,w+23,psi_uw,visited,trust,x0,y0,z0, 1, 1,-1,nx,ny,nz);
  extrap_phase(p+24,w+24,psi_uw,visited,trust,x0,y0,z0, 1, 1, 0,nx,ny,nz);
  extrap_phase(p+25,w+25,psi_uw,visited,trust,x0,y0,z0, 1, 1, 1,nx,ny,nz);

  /* Calculate weighted mean predicted phase */
  sum_pw = 0.0;
  sum_w = 0.0;
  for (i = 0; i < 26; i++) {
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
			 char *visited,
			 double *trust,
			 int x0, int y0, int z0,
			 int dx, int dy, int dz,
			 int nx, int ny, int nz)
{
  int x1, y1, z1, loc1;

  /* Set defaults for the extrapolated phase and weight */
  *p = 0.0;
  *w = 0;

  /* Determine location of first point along vector */
  x1 = x0 + dx;
  y1 = y0 + dy;
  z1 = z0 + dz;
  loc1 = LOC3D(x1,y1,z1);

  /* If this point is in bounds and has been unwrapped ... */
  if (inbounds(x1, y1, z1, nx, ny, nz)) {
    if (visited[loc1] == 2) {

      /* Nearest neighbour prediction of phase */
      *p = psi_uw[loc1];
      *w = trust[loc1] + 1.0;

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
		      char *visited,
		      double *trust,
		      int *stack,
		      int *nstack,
		      int *nunwrapped,
		      int nx, int ny, int nz)
{
  double max_mag = 0.0;
  int max_i = 0;
  int i;
  int imsize = nx * ny;
  int volsize = nx * ny * nz;

  iloop {
    if (trust[i] > 0.0 && visited[i] < 2) {
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
		 trust,
		 nstack,
		 nx, ny, nz);
}

/************************************************************
 * Estimate the phase ambiguity at this seed based on
 * previously unwrapped regions
 ************************************************************/
int seed_ambiguity(int seed_loc,
		   double *psi_uw,
		   int *visited,
		   int nx, int ny, int nz)
{
  int m;
  int x, y, z;
  int sx, sy, sz;
  double dx, dy, dz, dr;
  double min_dr = 1e30;
  double dp;
  int loc;
  int closest_loc = 0;

  /* Convert seed location to coordinates */
  toxyz(seed_loc, &sx, &sy, &sz, nx, ny, nz);
  
  /* Search for the nearest unwrapped, trusted point to the seed */

  loc = 0;

  zloop {
    yloop {
      xloop {
      
	    if (visited[loc] == 2 && x != sx && y != sy) {

	      dx = (double)(sx - x);
	      dy = (double)(sy - y);
	      dz = (double)(sz - z);

	      dr = sqrt(dx*dx + dy*dy + dz*dz);

	      if (dr < min_dr) {
	        min_dr = dr;
	        closest_loc = loc;
	      }

	    } /* Only if visited and unwrapped */

	    loc++;

      }
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

/************************************************************
 * Convert a vector location into (x,y,z) coordinates
 ************************************************************/
static void toxyz(int loc, int *x, int *y, int *z, int nx, int ny, int nz)
{
  int imsize = nx * ny;
  *z = loc / imsize; loc = loc - *z * imsize;
  *y = loc / nx; loc = loc - *y * nx;
  *x = loc;
}
