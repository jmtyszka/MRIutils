function [S0, T2, Mask] = mefitn(ME, TE)
% [S0, T2, Mask] = mefitn(ME, TE)
%
% Fit the ME contrast equation:
%
%   ME(TE) = S0 * ((1 - exp(-TE/T2))
%
% to the last dimension of an N-D matrix, SR[]
%
% ARGS:
% ME = N-D matrix with inversion time as final dimension
% TE = Inversion times for each time point
%
% RETURNS:
% S0 = S(TE=Inf) matrix
% T2 = T2 matrix (ms)
% Mask = fit mask used to reduce voxel count
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/06/2001 Adapt from srfit.m
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

% Get dimensions
dims = size(ME);
ndims = length(dims);
nvox = prod(dims(1:(ndims-1)));
nti1 = dims(ndims);
nti2 = length(TE);

% Default returns
S0 = [];
T2 = [];

% Check that enough TE values were provided
if ~isequal(nti1, nti2)
  fprintf('Not enough TE values provided for final dimension of data\n');
  return
else
  nt = nti1;
end

% Reshape and make space for results
ME = reshape(ME, [nvox nt]);
S0 = zeros(nvox,1);
T2 = zeros(nvox,1);

% Remove the first four echoes
%ME = ME(:,5:nt);
%TE = TE(5:nt);
%nt = nt - 4;

% Create a mask from the image with the shortest TE
[minTE, tmin] = min(TE(:));
maxME = ME(:,tmin);
MEthresh = max(maxME(:)) * 0.25;
Mask = maxME > MEthresh;

nmask = sum(Mask);

% Fit ME equation to each voxel in turn
hwb = waitbar(0,'');
for v = 1:nvox
  waitbar(v/nvox,hwb,sprintf('Fitting ME equation : %d/%d', v, nvox));
  if Mask(v)
    [S0(v), T2(v)] = mefit(ME(v,:), TE);
  end
end
close(hwb);

% Reshape maps back to Ndims-1
vdims = dims(1:(ndims-1));
S0 = reshape(S0, vdims);
T2 = reshape(T2, vdims);
Mask = reshape(Mask, vdims);

