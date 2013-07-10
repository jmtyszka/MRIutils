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