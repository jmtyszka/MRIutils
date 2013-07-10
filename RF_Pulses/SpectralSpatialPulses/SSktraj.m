function kx = SSktraj(G, dt)
% kx = SSktraj(G, dt)
%
% k-space trajectory for 2D spectral-spatial pulse
% Assumes a sinusoidal gradient waveform
% Returns kx(kf) for trajectory
%
% G  : gradient waveform
% dt : temporal sample spacing
% k0 : initial value for k

% Gyromagnetic ratio for 1H (rad/s/T)
GAMMA = 2 * pi * 4.2e7;

% Now integrate REMAINING gradient
reverseG = G(length(G):-1:1);
kx = GAMMA * dt * cumsum(reverseG);