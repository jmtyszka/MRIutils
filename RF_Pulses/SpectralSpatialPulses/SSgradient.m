function [G, wf] = SSgradient(t, Gmax, wf)
% G = SSgradient(t, Gmax, wf)
%
% Generate a sinusoidal gradient based on Gmax and wf
%
% t    : temporal samples
% Gmax : maximum gradient amplitude
% wf   : angular frequency of sine gradient
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

% Set amplitude of first and last half cycles to Gmax/2
% to keep k-space trajectory
% centered about kx = 0

phi = wf * t;

n = floor(phi / pi);
first = 0.0;
last = max(n);

A = Gmax * (1.0 - 0.5 * ((n == first) | (n >= last)));
G = A .* sin(phi);
