function [s0,H] = pvmdestar(s)
% Remove star artifact from MR images
% This artifact is typically caused by signal un-encoded by the 
% field gradients and may be off-center in the image
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 11/01/2010 JMT From scratch

% Find center of the artifact
sflat = s(:);
[smax,imax] = max(sflat);

[x0,y0,z0] = ind2sub(size(s),imax);
m = [x0 y0 z0];
sz = size(s);
c = fix(sz/2);

fprintf('Maximum found at (%d,%d,%d)\n', x0, y0, z0);

% Create a 3D radial Gaussian filter to match the artifact
H = 1 - gauss3(sz,8,0.5);

H = circshift(H,m-c);

s0 = s .* H;