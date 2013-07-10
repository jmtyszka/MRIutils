function [x,w,mxy] = SStest
% Test Bloch Equation simulation of a pulse
% 1ms 3-lobe sinc has BW = 6000Hz
% 1G/cm = 4200 Hz/cm
% Slice width = 6000/4200 = 1.4cm

PW = 1e-3;
dt = 8e-6;
t = (0:dt:(PW-dt))-PW/2;   % 1ms pulse in 8us increments
w = 3.0*2*pi/PW;           % 3-lobe sinc
phi = w*t;
B1t = sin(phi)./(phi);
B1t(isnan(B1t)) = 1.0;

B1t = B1t / 1e6; % Scale B1 into low flip angle regime

Gt = 1.0e-2*ones(size(B1t)); % 1 G/cm gradient

[x,w,mxy] = SSBlochSim(t,Gt,B1t);

surfl(w,x,abs(mxy)); shading interp;