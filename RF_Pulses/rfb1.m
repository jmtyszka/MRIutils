function [t, B1, f, alphascale, mxy, mz, mxyc] = rfb1(rfname, flipangle, duration)
%
% [t, B1, f, alphascale, mxy, mz, mxyc] = rfb1(rfname, flipangle, duration)
%
% Bloch simulation of the B1 senstivity of an RF pulse.
%
% ARGS:
% rfname    = Name of RF pulse - used to construct full path to .rho file
% flipangle = nominal flip angle of pulse in degrees
% duration  = nominal pulse width in seconds
%
% RETURNS:
% t     = time vector for waveform in seconds
% B1    = B1 waveform in Gauss
% f     = simulation frequency vector in Hz
% alphascale = simulation scaling vector for B1
% mxy   = simulated Mxy(alphascale, f)
% mz    = simulated Mz(alphascale, f)
% mxyc  = simulated crushed Mxy(alphascale, f) - for spin echo pulses
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 11/27/2000 From scratch
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

global rfdir

% Construct filenames for the .rho RF waveform and .mat results file
rhofile  = [rfdir '\' rfname '\' rfname '.rho'];
resfile  = [rfdir '\' rfname '\' rfname '.mat'];

% Load the RHO file data
[t, B1] = loadrho(rhofile, flipangle, duration);

% Bloch simulation over +/- 5kHz (few SLR pulses have a larger BW due to B1 constraints)
fN = 5000;
nf = 128;
df = fN / nf;
f = 0:df:fN;

% Loop over B1 scale factors from 0.5 to 1.5
alphascale = 0.5:0.05:1.5;

% Make space for results matrix
na = length(alphascale);

% Start simulation loop
for ac = 1:na
   fprintf('Simulating alpha = %g\n', alphascale(ac));
   [mxy(ac,:), mz(ac,:), mxyc(ac,:)] = blochsim(t, B1 * alphascale(ac), f);
end

% Save the results
save(resfile,'t','B1','mxy','mz','mxyc','f','alphascale');
