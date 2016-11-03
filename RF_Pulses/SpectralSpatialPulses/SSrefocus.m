function tiso = SSrefocus(x, f, mx, my, mz)
% Calculate refocusing moments and isodelay for the SS rf pulse
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

nx = length(x);
nf = length(f);

df = (max(f) - min(f)) / nf; % In Hz
dx = (max(x) - min(x)) / nx; % In mm

% Extract dTheta/df
hf = nf/2;
hx = nx/2;
theta_0 = angle(mx(hf,hx) + i * my(hf,hx));
theta_df = angle(mx(hf+1,hx) + i * my(hf+1,hx));
theta_dx = angle(mx(hf,hx+1) + i * my(hf,hx+1));

tiso = (theta_df - theta_0)/(2*pi*df)*1e6; % us

fprintf('Isodelay is %g us\n', tiso);

% Extract dTheta/dx
