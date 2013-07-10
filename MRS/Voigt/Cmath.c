/************************************************************
 * Complex arithmetic routines
 *
 * AUTHOR : Mike Tyszka, Ph.D.
 * PLACE  : Caltech BIC, Pasadena CA
 * DATES  : 11/11/99 Start from scratch
 ************************************************************/

#include "cmath.h"

dcomplex dcset(dcomplex a)
{
  dcomplex b;
  b.re = a.re;
  b.im = a.im;
  return b;
}

dcomplex dcsetri(double a_re, double a_im)
{
  dcomplex b;
  b.re = a_re;
  b.im = a_im;
  return b;
}

dcomplex dcaddr(dcomplex a, double b)
{
  dcomplex c;
  c.re = a.re + b;
  c.im = a.im;
  return c;
}

dcomplex dcadd(dcomplex a, dcomplex b)
{
  dcomplex c;
  c.re = a.re + b.re;
  c.im = a.im + b.im;
  return c;
}

dcomplex dcsub(dcomplex a, dcomplex b)
{
  dcomplex c;
  c.re = a.re - b.re;
  c.im = a.im - b.im;
  return c;
}

dcomplex dcmultr(dcomplex a, double b)
{
  dcomplex c;
  c.re = a.re * b;
  c.im = a.im * b;
  return c;
}

dcomplex dcmult(dcomplex a, dcomplex b)
{
  dcomplex c;
  c.re = a.re * b.re - a.im * b.im;
  c.im = a.re * b.im + a.im * b.re;
  return c;
}

dcomplex dcdiv(dcomplex a, dcomplex b)
{
  dcomplex c;
  double den = b.re * b.re + b.im * b.im;
  c.re = (a.re * b.re + a.im * b.im) / den;
  c.im = (a.im * b.re - a.re * b.im) / den;
  return c;
}

double dcarg(dcomplex a)
{
  return atan2(a.im, a.re);
}

double dcmod(dcomplex a)
{
  return sqrt(a.re * a.re + a.im * a.im);
}

dcomplex dcpoly(dcomplex x, double a[], int n)
{
  int i;
  dcomplex p;

  if (n < 1) {
    p = dcsetri(0.0, 0.0);
  } else {
    p = dcsetri(a[n], 0.0);
    for (i = n-1; i >= 0; i--) {
      p = dcmult(p, x);
      p = dcaddr(p, a[i]);
    }
  }

  return p;
}

/************************************************************
 * Complex exponential function cexp(z)
 * If z = x + iy then
 *  cexp(z) = exp(x) * exp(iy)
 *          = exp(x) * (cos(y) + i * sin(y))
 ************************************************************/
dcomplex dcexp(dcomplex a)
{
  dcomplex b;
  double expx = exp(a.re);

  b.re = expx * cos(a.im);
  b.im = expx * sin(a.im);
  
  return b;
}
