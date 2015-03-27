function [b,kx,ky,kz] = psqbmatrix(t,Gx,Gy,Gz,kinv,echoloc)
% Calculate 
% 
% SYNTAX: [b,kx,ky,kz] = psqbmatrix(t,Gx,Gy,Gz,kinv)
%
% ARGS:
% t = 1 x nt time vector (s)
% Gx,Gy,Gz = n x nt gradient vectors (T/m)
% kinv = 1 x nt inversion point vector
% echoloc = echo location (s)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/07/2004 JMT Adapt from psq
%          07/19/2008 JMT Update for multiple waveforms
%
% Copyright 2001-2008 California Institute of Technology.
% All rights reserved.

% Verbosity flag
verbose = true;

if nargin < 6;
  help psqbmatrix;
  return
end

% Number of gradient waveforms to process
[nw,nt] = size(Gx);

if verbose; fprintf('Detected %d waveforms of %d points\n', nw, nt); end

% Zero gradient waveforms for t < 0
negi = t < 0;
Gx(:,negi) = 0;
Gy(:,negi) = 0;
Gz(:,negi) = 0;

% First calculate the k trajectory without inversions
dt = t(2) - t(1);
kx = GAMMA_1H * cumsum(Gx,2) * dt;
ky = GAMMA_1H * cumsum(Gy,2) * dt;
kz = GAMMA_1H * cumsum(Gz,2) * dt;

% Preallocate b-matrices
b = zeros(3,3,nw);

% Inversion points may differ between waveforms/pathways
% so compute separately

for wc = 1:nw
  
  if verbose fprintf('Processing waveform %d\n', wc); end
  
  kinvw = kinv{wc};
  
  % Locate indices of k inversion points
  iinv = round(interp1(t,1:length(t),kinvw,'*linear'));
  iinv(isnan(iinv)) = [];

  % Apply cumulative inversions to k trajectory
  % Invert by subtracting 2 * k'(tinv) from all t > tinv
  % Repeat for all inversions, replacing k with k' at each iteration

  Ninv = length(iinv);
  Nsamp = length(kx);

  for ks = 1:Ninv
  
    iinv_ks = iinv(ks);
    kinds = iinv_ks:Nsamp;
  
    kx(wc,kinds) = kx(wc,kinds) - 2 * kx(wc,iinv_ks);
    ky(wc,kinds) = ky(wc,kinds) - 2 * ky(wc,iinv_ks);
    kz(wc,kinds) = kz(wc,kinds) - 2 * kz(wc,iinv_ks);
  
  end

  % Calculate b-matrix at echo location (not necessarily t = TE, eg STE)
  b_i = (t >= 0 & t <= echoloc);
  kxb = kx(wc,b_i);
  kyb = ky(wc,b_i);
  kzb = kz(wc,b_i);

  % Calculate upper triangle of b-matrix in s/(m^2)
  bxx = sum(kxb .* kxb) * dt;
  byy = sum(kyb .* kyb) * dt;
  bzz = sum(kzb .* kzb) * dt;
  bxy = sum(kxb .* kyb) * dt;
  bxz = sum(kxb .* kzb) * dt;
  byz = sum(kyb .* kzb) * dt;

  % Construct the b-matrix and rescale from s/(m^2) to s/(mm^2)
  b(:,:,wc) = [bxx bxy bxz; bxy byy byz; bxz byz bzz] * 1e-6;
  
end