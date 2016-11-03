function mxybar = SSresponse(x, w, BWx, BWw)
% mxybar = SSresponse(x, w, BWx, BWf)
%
% Generate ideal response function, mbar(x,w, BWx BWw)
% mxybar represents the ideal transverse magnetization
% abs(mxybar) = size of flip angle
% angle(mxybar) = phase of transverse magnetization relative to x'
%
% Use notation from Morrel and Mackowski MRM 1997; 37:378-386
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE: City of Hope, Duarte CA
% DATES: 9/28/98
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

GAMMA = 2 * pi * 4.2e7;

nx = length(x);
nw = length(w);

% Determine limits of passband in terms of indices
xi = find(abs(x) <= BWx/2);
wi = find(abs(w) <= BWw/2);

% Fill response matrix with 1.0 within excitation region
% Scaling of this response is essential for proper calibration
% of the B1 waveform for the SS pulse.

mxybar = zeros(nx,nw);
mxybar(xi,wi) = 1.0/(nx*nw);
