function [G, wf] = SSgradient(t, Gmax, wf)
% G = SSgradient(t, Gmax, wf)
%
% Generate a sinusoidal gradient based on Gmax and wf
%
% t    : temporal samples
% Gmax : maximum gradient amplitude
% wf   : angular frequency of sine gradient

% Set amplitude of first and last half cycles to Gmax/2
% to keep k-space trajectory
% centered about kx = 0

phi = wf * t;

n = floor(phi / pi);
first = 0.0;
last = max(n);

A = Gmax * (1.0 - 0.5 * ((n == first) | (n >= last)));
G = A .* sin(phi);
