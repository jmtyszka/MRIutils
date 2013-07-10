#include <math.h>

typedef struct {
  float re, im;
} fcomplex;

typedef struct {
  double re, im;
} dcomplex;

dcomplex dcset(dcomplex);
dcomplex dcsetri(double, double);

dcomplex dcadd(dcomplex, dcomplex);
dcomplex dcaddr(dcomplex, double);
dcomplex dcsub(dcomplex, dcomplex);
dcomplex dcmult(dcomplex, dcomplex);
dcomplex dcmultr(dcomplex, double);
dcomplex dcdiv(dcomplex, dcomplex);

double dcarg(dcomplex);
double dcmod(dcomplex);

dcomplex dcpoly(dcomplex, double [], int);
dcomplex dcexp(dcomplex);
