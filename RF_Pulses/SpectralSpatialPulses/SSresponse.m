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