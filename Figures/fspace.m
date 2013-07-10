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
% This file is part of MRutils.
%
% MRutils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% MRutils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MRutils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

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
