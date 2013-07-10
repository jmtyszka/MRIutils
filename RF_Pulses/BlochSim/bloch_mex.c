/************************************************************
 * MEX Bloch simulator for PSQ package
 *
 * SYNTAX: [Mx,My,Mz] = bloch_mex(tv,B1,Gx,Gy,Gz,xm,ym,zm,Mx0,My0,Mz0)
 *
 * AUTHOR : Mike Tyszka, Ph.D.
 * PLACE  : Caltech BIC
 * DATES  : 04/10/2002 Adapt wrapper code from tricubic8.c
 ************************************************************/

#include <stdio.h>
#include <math.h>
#include <mex.h>

#define DEBUG
#undef DEBUG

/* 1H gamma in rad/s/T */
#define GAMMA_1H (2.6754e8)

#define MX_MAT   plhs[0]
#define MY_MAT   plhs[1]
#define MZ_MAT   plhs[2]

#define TV_MAT   prhs[0]
#define B1_MAT   prhs[1]
#define GX_MAT   prhs[2]
#define GY_MAT   prhs[3]
#define GZ_MAT   prhs[4]
#define XM_MAT   prhs[5]
#define YM_MAT   prhs[6]
#define ZM_MAT   prhs[7]
#define MX0_MAT  prhs[8]
#define MY0_MAT  prhs[9]
#define MZ0_MAT  prhs[10]

#define LOC3D(x,y,z) ((x) + nx * ((y) + ny * (z)))
#define tloop for(t=0;t<nt;t++)
#define xloop for(x=0;x<nx;x++)
#define yloop for(y=0;y<ny;y++)
#define zloop for(z=0;z<nz;z++)
#define iloop for(i=0;i<nvox;i++)

/* Function declarations */
static void toxyz(int, int *, int *, int *, int, int, int);

/************************************************************
 * MAIN ENTRY POINT TO bloch_mex()
 ************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Version number */
  double verno = 0.2;

  int i, t, x, y, z;
  int nt, nvox;
  double *tv, *B1r, *B1i, *Gx, *Gy, *Gz; 
  double *xm, *ym, *zm;
  double *Mx, *My, *Mz;
  double *Mx0, *My0, *Mz0;
  double *Mxt, *Myt, *Mzt;
  double *Mx_m, *My_m, *Mz_m;
  double *Mx_p, *My_p, *Mz_p;
  double dt;
  double B_eff, B_eff_x, B_eff_y, B_eff_z;
  double T1, T2, E1, E2;
  double st, ct, tt, txy, txz, tyz;
  double rx, ry, rz;
  double theta;
  double R[3][3];
  int curprog, prevprog = 0;
  int Tdim[2];

  /* Check for proper number of arguments */
  if (nrhs != 11 || nlhs > 3) {
	mexErrMsgTxt("[Mx,My,Mz] = bloch_mex(t,B1,Gx,Gy,Gz,x,y,z,Mx0,My0,Mz0)");
  }
  
  if (!mxIsComplex(B1_MAT)) {
    mexErrMsgTxt("B1 must be complex valued");
  }
  
  /* Determine number of ticks and voxels */
  nt  = mxGetNumberOfElements(TV_MAT);
  nvox = mxGetNumberOfElements(XM_MAT);

  /* Get the data pointers */
  tv   = mxGetPr(TV_MAT);
  B1r  = mxGetPr(B1_MAT);
  B1i  = mxGetPi(B1_MAT);
  Gx   = mxGetPr(GX_MAT);
  Gy   = mxGetPr(GY_MAT);
  Gz   = mxGetPr(GZ_MAT);
  xm   = mxGetPr(XM_MAT);
  ym   = mxGetPr(YM_MAT);
  zm   = mxGetPr(ZM_MAT);
  Mx0  = mxGetPr(MX0_MAT);
  My0  = mxGetPr(MY0_MAT);
  Mz0  = mxGetPr(MZ0_MAT);
  
  if (tv == NULL |
      B1r == NULL |
      B1i == NULL |
      Gx == NULL |
      Gy == NULL |
      Gz == NULL |
      xm == NULL |
      ym == NULL |
      zm == NULL |
      Mx0 == NULL |
      My0 == NULL |
      Mz0 == NULL) {
        mexPrintf("Problem getting data pointers\n");
        return;
  }
  
  /* Create real matrices for the magnetization waveforms */
  Tdim[0] = 1; Tdim[1] = nt;
  MX_MAT = mxCreateNumericArray(2, Tdim, mxDOUBLE_CLASS, mxREAL);
  MY_MAT = mxCreateNumericArray(2, Tdim, mxDOUBLE_CLASS, mxREAL);
  MZ_MAT = mxCreateNumericArray(2, Tdim, mxDOUBLE_CLASS, mxREAL);
  
  /* Total magnetization at each time sample */
  Mxt = mxGetPr(MX_MAT);
  Myt = mxGetPr(MY_MAT);
  Mzt = mxGetPr(MZ_MAT);
    
  /* Magnetization of each isochromat at start (_m) and end (_p) of tick */
  Mx_m = mxCalloc(nvox, sizeof(double));
  My_m = mxCalloc(nvox, sizeof(double));
  Mz_m = mxCalloc(nvox, sizeof(double));
  Mx_p = mxCalloc(nvox, sizeof(double));
  My_p = mxCalloc(nvox, sizeof(double));
  Mz_p = mxCalloc(nvox, sizeof(double));

  /**********************************************************
   * START OF MAIN BLOCH SIMULATION LOOP
   **********************************************************/

  /* Assume uniform temporal sampling for now */
  dt = tv[1] - tv[0];

  /* Initialize magnetization at start of first temporal sample */
  iloop {
    Mx_p[i] = Mx0[i];
    My_p[i] = My0[i];
    Mz_p[i] = Mz0[i];
  }
  
  /* Temporary relaxation parameters - add as argument later */
  T1 = 1.0;
  T2 = 0.025;
  E1 = exp(-dt/T1);
  E2 = exp(-dt/T2);
  
  /* Loop over all time samples */
  tloop {

    B_eff_x = B1r[t];
    B_eff_y = B1i[t];
    
    /* Initialize total magnetization */
    Mxt[t] = 0.0;
    Myt[t] = 0.0;
    Mzt[t] = 0.0;
    
    /* Loop over all isochromats */
    iloop {

      /* Initialize M- */
      Mx_m[i] = Mx_p[i];
      My_m[i] = My_p[i];
      Mz_m[i] = Mz_p[i];

      /* Calculate B_eff - B1 is a complex waveform with real part on x' */
      B_eff_z = Gx[t] * xm[i] + Gy[t] * ym[i] + Gz[t] * zm[i];
      B_eff = sqrt(B_eff_x * B_eff_x + B_eff_y * B_eff_y + B_eff_z * B_eff_z);
      
      if (B_eff > 0.0) {
      
        rx = B_eff_x / B_eff;
        ry = B_eff_y / B_eff;
        rz = B_eff_z / B_eff;
      
        /* Precession angle about B_eff */
        theta = GAMMA_1H * B_eff * dt;
      
        /* Trig terms for the rotation matrix */
        st = sin(theta);
        ct = cos(theta);
        tt = 1-cos(theta);
        txy = tt * rx * ry;
        txz = tt * rx * rz;
        tyz = tt * ry * rz;
      
        /* Construct rotation matrix - See Graphics Gems I p466 */
        R[0][0] = tt * rx * rx + ct;
        R[0][1] = txy + st * rz;
        R[0][2] = txz - st * ry;
        R[1][0] = txy - st * rz; 
        R[1][1] = tt * ry * ry + ct;
        R[1][2] = tyz + st * rx;
        R[2][0] = txz + st * ry;
        R[2][1] = tyz - st * rx;
        R[2][2] = tt * rz * rz + ct;
        
        /* Apply rotation to this isochromat -> M+ */
        Mx_p[i] = R[0][0] * Mx_m[i] + R[0][1] * My_m[i] + R[0][2] * Mz_m[i];
        My_p[i] = R[1][0] * Mx_m[i] + R[1][1] * My_m[i] + R[1][2] * Mz_m[i];
        Mz_p[i] = R[2][0] * Mx_m[i] + R[2][1] * My_m[i] + R[2][2] * Mz_m[i];
        
      } else {
      
        /* No precession during this time sample */
        Mx_p[i] = Mx_m[i];
        My_p[i] = My_m[i];
        Mz_p[i] = Mz_m[i];
        
      }
       
      /* Relax M+ by T1 and T2 */
      Mx_p[i] = Mx_p[i] * E2;
      My_p[i] = My_p[i] * E2;
      Mz_p[i] = Mz0[i] * (1 - E1) + Mz_p[i] * E1;
      
#ifdef DEBUG
        mexPrintf("r = (%g, %g, %g)\n", xm[i], ym[i], zm[i]);
        mexPrintf("G = (%g, %g, %g)\n", Gx[t], Gy[t], Gz[t]);
        mexPrintf("B_eff = %g\n", B_eff);
        mexPrintf("theta = %g\n", theta);
        mexPrintf("%g %g %g\n", R[0][0], R[0][1], R[0][2]);
        mexPrintf("%g %g %g\n", R[1][0], R[1][1], R[1][2]);
        mexPrintf("%g %g %g\n", R[2][0], R[2][1], R[2][2]);
        mexPrintf("M- = (%g, %g, %g\n", Mx_m[i], My_m[i], Mz_m[i]);
        mexPrintf("M+ = (%g, %g, %g\n", Mx_p[i], My_p[i], Mz_p[i]);
        mexPrintf("\n");
#endif

      /* Add isochromat magnetization to running total */
      Mxt[t] += Mx_p[i];
      Myt[t] += My_p[i];
      Mzt[t] += Mz_p[i];
      
    } /* End of isochromat loop */
      
  } /* End of time loop */

  /* Normalize magnetization */
  tloop {
    Mxt[t] /= (double)nvox;
    Myt[t] /= (double)nvox;
    Mzt[t] /= (double)nvox;
  }
  
  /* Tidy up */
  mxFree(Mx_m);
  mxFree(My_m);
  mxFree(Mz_m);
  mxFree(Mx_p);
  mxFree(My_p);
  mxFree(Mz_p);
  
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