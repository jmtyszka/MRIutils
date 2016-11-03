function B1t = RFWave(t,B1t,shapename,flip,phi,t0,trf)
% B1t = RFWave(t,B1t,shapename,flip,phi,t0,trf)
%
% Generate shaped RF waveform on the TX channel
%
% ARGS :
% t         = time point vector (s)
% B1t       = existing RF waveform vector (T)
% shapename = waveform shape - 'sinc', etc
% flip      = flip angle (degs)
% phi       = RF phase relative to x' axis (degs)
% t0        = start time of pulse (s)
% trf       = duration of waveform (s)
%
% RETURNS :
% B1t       = updated RF waveform vector
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/31/2001 From scratch
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

% NMR Constants
GAMMA_1H = 360 * 42e6; % deg/s/T

% Find indices for waveform
inds = find(t >= t0 & t < t0 + trf);
n = length(inds);

if isequal(n,0)
  return
end

switch shapename
  
case 'hsinc'
  
  % Three-lobe Hamming filtered sinc
  w = hsinc(n,3);
  
case 'rect'
  
  % Rectangular pulse
  w = ones(1,n);
  
otherwise
  
  fprintf('No support for %s waveform yet\n', shapename);
  return
  
end

% Scale and phase waveform
k = flip / (GAMMA_1H * mean(w) * trf);
B1 = k * w * exp(i * phi * pi / 180); 

% Place RF waveform into B1 vector
B1t(inds) = B1;
