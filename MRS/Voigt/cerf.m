function c = cerf(x,y)
%
% Adaptive complex error function approximation
%
% x = vector
% y = scalar
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from web page Fortran code
% REFS   : Humlicek J, JQSRT 1982; 27:437
%          Schreier F JQSRT 1992; 48:743-762
%
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

T = y - i * x;

if (y > 15)

  c = cerf1(T);

elseif (y < 15 && y >= 5.5)

  S = abs(x) + y;

  if (S > 15)
    c = cerf1(T);
  else
    U = T .* T;
    c = cerf2(T,U);
  end

elseif (y < 5.5 && y > 0.75)

  S = abs(x) + y;

  if (S > 15)
    c = cerf1(T);
  elseif (S < 5.5)
    c = cerf3(T);
  else
    U = T .* T;
    c = cerf2(T,U);
  end

else

  AX = abs(x);
  S = AX + y;

  if (S >= 15)
    c = cerf1(T);
  elseif (S < 15 && S >= 5.5)
    U = T .* T;
    c = cerf2(T,U);
  elseif (S < 5.5 && y >= (0.195 * AX - 0.176))
    c = cerf3(T);
  else
    U  = T .* T;
    c = exp(U) - cerf4(T,U);
  end

end

% Handle case where y = 0
if (y == 0)
  c = exp(-x.^2) + i * imag(c);
end

