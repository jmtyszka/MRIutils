/************************************************************
 * Complex arithmetic routines
 *
 * AUTHOR : Mike Tyszka, Ph.D.
 * PLACE  : Caltech BIC, Pasadena CA
 * DATES  : 11/11/99 Start from scratch
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
