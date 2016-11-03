function c = jmt_ddr_costfn(x,pars)
% Optimization cost function
% Based on residual image-space signal outside of mask defined by reference
% image
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

% x is a vector of phases corresponding to each CPMG echo
% Expand to cover k-space

[nx,ny,nz] = size(pars.k);

phi_corr = repmat(x,[pars.nshots 1]);
phi_corr = phi_corr(:)';
phi_corr = repmat(phi_corr,[nx 1 nz]);

k_corr = pars.k .* exp(-i * phi_corr);

% Reconstruct image space
s_corr = abs(fftshift(fftn(k_corr)));

% Extract ghost + noise signal
c = s_corr(pars.outside);
