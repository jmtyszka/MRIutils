function c4 = cerf4(T,U)
% Approximation 4 to the complex error function
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

c4 = (T .* (36183.31 - U .* (3321.99 - U .* (1540.787 - U .* ...
     (219.031 - U .* (35.7668 - U .* (1.320522 - U .* .56419)))))) / ...
     (32066.6 - U .* (24322.8 - U .* (9022.23 - U .* ...
     (2186.18 - U .* (364.219 - U .* (61.5704 - U .* (1.84144 - U))))))));
