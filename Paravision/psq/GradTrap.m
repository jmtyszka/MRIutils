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