function [ADC, S0, Mask] = adcfitn(b, S, verbose)
% [ADC, S0, Mask] = t2fitn(TE, S, verbose)
%
% Fit the ADC contrast equation in log-linear space:
%
%   log(S(b)) = S0 - b.ADC
%
% to the last dimension of an N-D matrix, S[]
%
% ARGS:
% b = b-factor vector in s/mm^2
% S = N-D matrix with echo time as final dimension
%
% RETURNS:
% S0  = S(b=0) matrix
% ADC = ADC matrix in mm^2/s
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/06/2004 JMT Adapt from t2fitn.m (JMT)
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

% Default args
if nargin < 3 verbose = 0; end

% Get dimensions
dims = size(S);
ndims = length(dims);
nvox = prod(dims(1:(ndims-1)));
nb1 = dims(ndims);
nb2 = length(b);

% Default returns
S0 = [];
ADC = [];
Mask = [];

% Check that enough b values were provided
if ~isequal(nb1, nb2)
  fprintf('b values do not match final dimension of data\n');
  return
else
  nb = nb1;
end

% Force b to be a column vector
b = b(:);

% Reshape and take log of S(b)
S  = reshape(S, [nvox nb])';
logS = log(S);

% Calculate regression coefficients
[S0,ADC,r] = lrn(b,logS);

ADC = -ADC;

% Create a 10% mask from the mean image over b
mS = mean(S,1);
Mask = mS > max(mS(:)) * 0.1;

% Apply mask
S0 = S0 .* Mask;
ADC = ADC .* Mask;

% Reshape maps back to Ndims-1
vdims = dims(1:(ndims-1));
S0 = reshape(S0, vdims);
ADC = reshape(ADC, vdims);
Mask = reshape(Mask, vdims);
