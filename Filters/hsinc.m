function [B1, t] = hsinc(n, cycs, verbose, filegen)
% [B1, t] = hsinc(n, cycs, verbose, filegen)
%
% n point Hamming sinc function with cycs cycles
%
% ARGS:
% n       = number of samples [256]
% cycs    = number of sinc cycles [3]
% verbose = plot the function [0]
% filegen = generate a file 'hsinc.txt' int the current directory [0]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/20/2000 From scratch
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

% Default arguments
if nargin < 4 filegen = 0; end
if nargin < 3 verbose = 0; end
if nargin < 2 cycs = 3; end
if nargin < 1 n = 256; end

% Generate a time vector
t = 2 * pi * (-(n/2):(n/2-1)) / n;

% Generate the Hamming filter
H = 0.54 + 0.46 * cos(t);

% Generate the B1 waveform
B1 = H .* sin(cycs * t + 1e-30) ./ (cycs * t + 1e-30);

% Plot the HSINC function
if verbose plot(t, B1); end

% Write out pulse in BRUKER text format
if filegen
  fd = fopen('hsinc.txt','w');
  fprintf(fd, 'RFVERSION_F\n');
  for c = 1:length(B1)
    fprintf(fd, '%0.3f %0.3f\n', abs(B1(c)) * 100, 180 * (B1(c) < 0));
  end
  fclose(fd);
end

