function fspace(A,B)
% Plot a 2D feature space histogram for the vectors A and B
%
% fspace(A,B)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/15/2003 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2003-2006 California Institute of Technology.
% All rights reserved.
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

A = A(:);
B = B(:);

nA = length(A);
nB = length(B);

if nA ~= nB
  fprintf('Size of vectors should match\n');
  return
end

nBin = 100;

minA = min(A);
maxA = max(A);
minB = min(B);
maxB = max(B);

Bv = linspace(minB,maxB,nBin);

A = ceil((A - minA) / (maxA - minA) * (nBin-1)) + 1;
B = ceil((B - minB) / (maxB - minB) * (nBin-1)) + 1;

Av = linspace(minA,maxA,nBin);

k = zeros(nBin,nBin);

for ic = 1:nA
  k(A(ic),B(ic)) = k(A(ic),B(ic)) + 1;
end

imagesc(Av,Bv,log(k'));
axis xy
xlabel('A');
ylabel('B');
