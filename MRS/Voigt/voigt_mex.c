/************************************************************
 * C source for voigt_mex.dll MEX object
 *
 * SYNTAX: V = voigt_mex(f, I0, f0, gL, gD, phi)
 *
 * Fast c code implementing the Humlicek w4 algorithm
 * with additional scaling and phasing for the
 * complex Voigt lineshape.
 *
 * AUTHOR : Mike Tyszka, Ph.D.
 * PLACE  : City of Hope
 * DATES  : 5/21/00 Start from Fortran (Schreier) and
 *                  Matlab code (JMT)
 *          5/22/00 Convert to MEX routine
 ************************************************************/

#include <math.h>
#include "mex.h"

#include "cmath.c"

void humlicek_w4(int, double [], double, double *, double *);

dcomplex cerf1(dcomplex);
dcomplex cerf2(dcomplex, dcomplex);
dcomplex cerf3(dcomplex);
dcomplex cerf4(dcomplex, dcomplex);

/* Input Arguments */

#define	f_IN   prhs[0]
#define	I_IN   prhs[1]
#define	f0_IN  prhs[2]
#define	gL_IN  prhs[3]
#define	gD_IN  prhs[4]
#define	phi_IN prhs[5]

/* Output Arguments */

#define	V_OUT	plhs[0]

/************************************************************
 * Entry point for MEX call
 ************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], 
		 int nrhs, const mxArray *prhs[])
{
  double *f, *I, *f0, *gL, *gD, *phi; 
  double *cn_r, *cn_i;
  double c0_r, c0_i;
  double *v_r, *v_i; 
  double *x; 
  unsigned int fm, fn, i;
  double x0, y;
  double sqrtln2 = sqrt(log(2.0));
  double re, im;
  double sinphi, cosphi;
    
  /* Check for proper number of arguments */
    
  if (nrhs != 6 || nlhs > 1) { 
    mexErrMsgTxt("SYNTAX: V = voigt_mex(f,I,f0,gL,gD,phi)"); 
  } 

  /* Get the dimensions of vector f */
  fm = mxGetM(f_IN); fn = mxGetN(f_IN);

  if (fm > 1)
    mexErrMsgTxt("voigt(f,I,f0,gL,gD,phi) : f must be be a 1xN vector");

  /* Create a matrix for the return arguments */ 
  V_OUT = mxCreateDoubleMatrix(1, fn, mxCOMPLEX);
    
  /* Assign pointers to the complex output vector */ 
  v_r = mxGetPr(V_OUT);
  v_i = mxGetPi(V_OUT);

  /* Only consider the real parts of the inputs */
  f = mxGetPr(f_IN); 
  I = mxGetPr(I_IN);
  f0 = mxGetPr(f0_IN);
  gL = mxGetPr(gL_IN);
  gD = mxGetPr(gD_IN);
  phi = mxGetPr(phi_IN);

  /* Make temporary space for x[], cn_r[] and cn_i[] - autofreed */
  x = (double *)mxCalloc(fn, sizeof(double));
  cn_r = (double *)mxCalloc(fn, sizeof(double));
  cn_i = (double *)mxCalloc(fn, sizeof(double));

  /* Calculate x and y for the Humlicek w4 algorithm */
  y = sqrtln2 * gL[0] / gD[0];
  for (i = 0; i < fn; i++) x[i] = (f[i] - f0[0]) * sqrtln2 / gD[0];

  /* Call the Humlicek w4 routine */
  humlicek_w4(fn, x, y, cn_r, cn_i);

  /* Call routine for x = 0 */
  x0 = 0.0;
  humlicek_w4(1, &x0, y, &c0_r, &c0_i);

  /* Scale the vector by I / V0 * exp(i * phi) and conjugate */
  for (i = 0; i < fn; i++) {

      re = I[0] / c0_r * cn_r[i];
      im = -I[0] / c0_r * cn_i[i];

      sinphi = sin(phi[0]);
      cosphi = cos(phi[0]);

      v_r[i] = re * cosphi - im * sinphi;
      v_i[i] = im * cosphi + re * sinphi;
  }
 
  return;
}

/************************************************************
 * Fast approximation to cerf(z) using the Humlicek w4
 * algorithm
 ************************************************************/
void humlicek_w4(int n, double x[], double y, double *c_re, double *c_im)
{
  int i;
  double s, ax;
  dcomplex t, u, c, cexpu;

  if (y >= 15) {

    /* All points are in region I */

    for (i = 0; i < n; i++) {
      t = dcsetri(y, -x[i]);
      c = cerf1(t);
      c_re[i] = c.re; c_im[i] = c.im;
    }
    
  } else if (y < 15 && y >= 5.5) {

    /* Points are in region I or region II */

    for (i = 0; i < n; i++) {

      t = dcsetri(y, -x[i]);

      s = fabs(x[i]) + y;

      if (s >= 15) {
	c = cerf1(t);
	c_re[i] = c.re; c_im[i] = c.im;
      } else {
	u = dcmult(t, t);
	c = cerf2(t, u);
	c_re[i] = c.re; c_im[i] = c.im;
      }

    }

  } else if (y < 5.5 && y >= 0.75) {

    for (i = 0; i < n; i++) {

      t = dcsetri(y, -x[i]);

      s = fabs(x[i]) + y;

      if (s >= 15) {
	c = cerf1(t);
	c_re[i] = c.re; c_im[i] = c.im;
      } else if (s < 5.5) {
	c = cerf3(t);
	c_re[i] = c.re; c_im[i] = c.im;
      } else {
	u = dcmult(t, t);
	c = cerf2(t, u);
	c_re[i] = c.re; c_im[i] = c.im;
      }

    }

  } else {

    for (i = 0; i < n; i++) {

      t = dcsetri(y, -x[i]);
	  
      ax = fabs(x[i]);
      s = ax + y;

      if (s >= 15) {
	c = cerf1(t);
	c_re[i] = c.re; c_im[i] = c.im;
      } else if (s < 15.0 && s >= 5.5) {
	u = dcmult(t, t);
	c = cerf2(t, u);
	c_re[i] = c.re; c_im[i] = c.im;
      } else if (s < 5.5 && y >= (0.195 * ax - 0.176)) {
	c = cerf3(t);
	c_re[i] = c.re; c_im[i] = c.im;
      } else {
	u = dcmult(t, t);
	c = cerf4(t,u);
	cexpu = dcexp(u);
	c = dcsub(cexpu, c);
	c_re[i] = c.re; c_im[i] = c.im;
      }

    }

  }

  if (y == 0.0) {
    for (i = 0; i < n; i++) {
      c_re[i] = exp(-x[i]*x[i]);
    }
  }

}

/************************************************************
 * APPROX1(T)   = (T * .5641896) / (.5 + (T * T))
 ************************************************************/
dcomplex cerf1(dcomplex t)
{
  dcomplex p, q, c;

  p = dcmultr(t, 0.5641896);

  q = dcmult(t,t);
  q = dcaddr(q, 0.5);

  c = dcdiv(p,q);

  return c;
}
/************************************************************
 * APPROX2(T,U) = (T * (1.410474 + U *.5641896)) / (.75 + (U * (3. + U)))
 ************************************************************/
dcomplex cerf2(dcomplex t, dcomplex u)
{
  dcomplex p, q, c;

  p = dcmultr(u, 0.5641896);
  p = dcaddr(p, 1.410474);
  p = dcmult(t, p);

  q = dcaddr(u, 3.0);
  q = dcmult(u, q);
  q = dcaddr(q, 0.75);

  c = dcdiv(p, q);

  return c;
}

/************************************************************
 * APPROX3(T)   = ( 16.4955 + T * (20.20933 + T * (11.96482 +
 *                  T * (3.778987 + 0.5642236*T))))
 *              / ( 16.4955 + T * (38.82363 + T *
 *                ( 39.27121 + T * (21.69274 + T * (6.699398 + T)))))
 ************************************************************/
dcomplex cerf3(dcomplex t)
{
  dcomplex p, q, c;
  double a[5] = {16.4955, 20.20933, 11.96482, 3.778987, 0.5642236};
  double b[6] = {16.4955, 38.82363, 39.27121, 21.69274, 6.699398, 1.0};

  p = dcpoly(t, a, 4);
  q = dcpoly(t, b, 5);

  c = dcdiv(p, q);

  return c;
}

/************************************************************
 * APPROX4(T,U) = (T * (36183.31 - U * (3321.99 - U * (1540.787 - U
 *          * (219.031 - U *(35.7668 - U *(1.320522 - U * .56419))))))
 *        / (32066.6 - U * (24322.8 - U * (9022.23 - U * (2186.18
 *           - U * (364.219 - U * (61.5704 - U * (1.84144 - U))))))))
 ************************************************************/
dcomplex cerf4(dcomplex t, dcomplex u)
{
  dcomplex p, q, c;
  double a[7] = {36183.31, 3321.99, 1540.787, 219.031, 35.7668,
		1.320522, 0.56419};
  double b[8] = {32066.6, 24322.8, 9022.23, 2186.18, 364.219,
		61.5704, 1.84144, 1.0};

  /* Polynomials are all in -U */
  u = dcmultr(u, -1.0);

  p = dcpoly(u, a, 6);
  p = dcmult(t, p);

  q = dcpoly(u, b, 7); 

  c = dcdiv(p, q);

  return c;
}
