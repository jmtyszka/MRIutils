function Gt = GradTrap(t,Gt,G,t0,tr,tc,Gscale)
% Gt = GradTrap(t,Gt,G,t0,tr,tc,Gscale)
%
% Generate trapezoidal gradient waveform with the attack ramp
% starting at t0.
%
% ARGS :
% t  = time point vector (s)
% Gt = existing gradient waveform vector (T)
% G  = gradient pulse amplitude (T)
% t0 = start time of attack ramp (s)
% tr = rise time (s)
% tc = duration of constant section (s)
% Gscale = gradient scaling (for phase encoding, etc) [optional, default = 1.0]
%
% RETURNS :
% Gt = updated gradient waveform vector
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

if nargin < 7
  Gscale = 1.0;
end

% Find indices of segment boundaries

t0_i = find((t - (t0)) >= 0);
if isempty(t0_i)
  return
else
  t0_i = t0_i(1);
end

t1_i = find((t - (t0+tr)) >= 0);
if isempty(t1_i)
  return
else 
  t1_i = t1_i(1);
end

t2_i = find((t - (t0+tr+tc)) >= 0);
if isempty(t2_i) 
  return
else 
  t2_i = t2_i(1); 
end

t3_i = find((t - (t0+tr+tc+tr)) >= 0);
if isempty(t3_i) 
  return
else 
  t3_i = t3_i(1);
end

% Index range of each segment : attack, constant and decay
ta_i = t0_i:(t1_i-1);
tc_i = t1_i:(t2_i-1);
td_i = t2_i:(t3_i-1);

% Slope of attack ramp
slope = G / tr;

% Construct gradient waveform to add to existing vector
Gplus = zeros(size(t));
Gplus(ta_i) = slope * (t(ta_i) - t0);
Gplus(tc_i) = G;
Gplus(td_i) = G - slope * (t(td_i) - (t0+tr+tc));

% Add waveform to existing vector
Gt = Gt + Gplus * Gscale;
