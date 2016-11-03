/************************************************************
 * Calculate the isodelay for RF refocusing and the gradient
 * delay for gradient refocusing.
 *
 * AUTHOR : Mike Tyszka, Ph.D.
 * DATES  : 1999-01-18 JMT From scratch
 * PLACE  : City of Hope, Duarte CA
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
#include <nmr.h>
#include <ss.h>
#include <bloch.h>
#include <jmt.h>

/************************************************************
 * Calculate the isodelay and gradient delay from the final
 * mxy distribution.
 * mx and my matrices are
 ************************************************************/
int IsoDelay(char *pulsename,
	     SSPARS *ssp,
	     int nw,
	     int nx,
	     float *w,
	     float *x,
	     float *mx,
	     float *my,
	     float *tiso,
	     float *tg)
{
  FILE *fd;
  char isoname[512];
  float mx0, my0;
  float mxx, myx;
  float mxw, myw;
  float dw, dx;
  float theta0;
  float thetax;
  float thetaw;
  float dtheta_dx;
  float dtheta_dw;
  int hnx = nx/2;
  int hnw = nw/2;
  int loc;

  /* Calculate the grid spacing in the X and W directions */
  dw = w[1] - w[0];
  dx = x[1] - x[0];

  /* Calculate dtheta/dw and dtheta/dx at the isocenter */

  loc = LOC(hnw, hnx, nw);

  mx0 = mx[loc];
  my0 = my[loc];
  mxx = mx[loc+nw];
  myx = my[loc+nw];

  /* Calculate the phases at these three points */
  theta0 = atan2(my0,mx0);
  thetax = atan2(myx,mxx);
  dtheta_dx = (thetax - theta0)/dx;

  if (ssp->ssflag) {
    mxw = mx[loc+1];
    myw = my[loc+1];
    thetaw = atan2(myw,mxw);

    dtheta_dw = (thetaw - theta0)/dw;

    /************************************************************
     * RF isodelay in seconds (always positive)
     * Time from end of pulse to RF isocenter
     ************************************************************/
    *tiso = fabs(dtheta_dw);

    /************************************************************
     * Gradient delay in seconds
     * tg is the duration of a Gmax constant pulse that would
     * refocus the spatial linear dephasing in Mxy 
     ************************************************************/
  
    *tg = dtheta_dx / (GAMMA_1H * ssp->Gmax);

    printf("IsoDelay: Isodelay       = %g us\n", *tiso * 1e6);
    printf("IsoDelay: Gradient delay = %g us\n", *tg * 1e6);

  } else {
    /************************************************************
     * RF isodelay in seconds (always positive)
     * Time from end of pulse to RF isocenter
     ************************************************************/
    *tiso = fabs(dtheta_dx) / (GAMMA_1H * ssp->Gmax);

    printf("IsoDelay: Isodelay       = %g us\n", *tiso * 1e6);
  }

  /************************************************************
   * Write isodelay and gradient delay to <pulsename>.iso
   ************************************************************/
  sprintf(isoname, "%s.iso", pulsename);
  if ((fd = fopen(isoname, "w")) == NULL) {
    fprintf(stderr, "IsoDelay: Could not open %s to write\n", isoname);
    return FAILURE;
  }

  fprintf(fd, "IsodelayUS %g\n", *tiso * 1e6);

  if (ssp->ssflag) {
    fprintf(fd, "GradDelayUS %g\n", *tg * 1e6);
  }

  fclose(fd);

  return SUCCESS;
}
