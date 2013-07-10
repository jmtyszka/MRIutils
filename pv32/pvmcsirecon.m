function [s,ppm,info] = pvmcsirecon(scandir,lb,hamming,autophase)
% [s,ppm,info] = pvmcsirecon(scandir,zpad,lb,hamming,autophase)
%
% Reconstruct a single 2D CSI acquired using the PvM CSI method
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/07/2004 JMT From scratch - use existing JMT utility routines
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

if nargin < 1; scandir = pwd; end
if nargin < 2; lb = 0; end
if nargin < 3; hamming = 1; end
if nargin < 4; autophase = 0; end

if isempty(lb); lb = 0; end
if isempty(hamming); hamming = 1; end
if isempty(autophase); autophase = 0; end

% Load the raw CSI k-space data from scandir
[k,info] = pvmloadfid(scandir);

if isempty(k)
  fprintf('Problem loading CSI k-space\n');
  return
end

% Extract spectral width and central frequency
sw     = info.sw_spec_Hz;
sw_ppm = info.sw_spec_ppm;

% Apply pre-FFT phase rolls to correct for phase encoding offsets
k = pvmcsiphaseroll(k,info);
nf = size(k,1);

% Apply spatial Hamming filter
if hamming
  k = csihamming2d(k);
end

% Apply Lorentz to Gauss filter
if lb > 0
  T2_est = 0.025; % seconds
  k = csilorentz2gauss2(k,sw,T2_est,lb);
end

%----------------------------------------------------------
% FFT all dimensions
% Include orgin displacement and zero-padding for FFT
%----------------------------------------------------------

% Spatial FFT
k = fft(k,[],2);
k = fft(k,[],3);

% Phase correct in time domain
if autophase

  phi0 = angle(k(1,:,:));
  phi0 = repmat(phi0,[nf 1 1]);
  k = k .* exp(-i * phi0);
  
end

% Spectral FFT
s = fft(k,[],1);

% Get CSI dimensions
nf = size(s,1);

% Construct the ppm scale
ppm = linspace(0,sw_ppm,nf) - sw_ppm/2 + 4.7 + info.sw_offset_ppm;

% Write resulting CSI dataset to a .mat file in the scan directory
fname = fullfile(scandir,'csi.mat');
fprintf('Writing reconstructed CSI to %s\n', fname);
save(fname,'ppm','s','info','zpad','lb','hamming','autophase');
