function s = model_mrs(f, I, f0, gL, gD, phi)
%
% s = model_mrs(I, f0, gL, gD, phi, T)
%
% f   = Frequency vector (ppm)
% I   = Amplitude vector [4]
% f0  = Central frequency vector [4]
% gL  = Lorentzian width vector [4]
% gD  = Doppler (Gaussian) width vector [4]
% phi = Phase vector [4] in radians
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from memory

n = length(f);

V = zeros(4, n);

for c = 1:4
  V(c,:) = voigt(f, I(c), f0(c), gL(c), gD(c), phi(c));
end

s = sum(V);

