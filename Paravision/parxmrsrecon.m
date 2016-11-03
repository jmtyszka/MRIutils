function [s,ppm,info] = parxmrsrecon(scandir,zpad,lb,hamming,autophase)
% [s,ppm,info] = parxmsrecon(scandir,zpad,lb,hamming,autophase)
%
% Reconstruct a single-voxel spectrum acquired using a Paravision method
% (PvM or IMND)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/01/2004 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Default returns
s = [];
ppm = [];

if nargin < 1; scandir = pwd; end
if nargin < 2; zpad = 1; end
if nargin < 3; lb = 0; end
if nargin < 4; hamming = 1; end
if nargin < 5; autophase = 1; end

if isempty(zpad); zpad = 1; end
if isempty(lb); lb = 0; end
if isempty(hamming); hamming = 1; end
if isempty(autophase); autophase = 1; end

% Load the raw FID data from scandir
[k,info] = parxloadfid(scandir);

if isempty(k)
  fprintf('Problem loading FID\n');
  return
end

% Remove first 72 points and zero pad to original length
nt = length(k);
ndisc = 72;
k = [k((ndisc+1):nt,1); zeros(ndisc,1)];

% Extract spectral width and central frequency
sw_ppm = info.sw_spec_ppm;

% Apply spatial Hamming filter
if hamming
end

% Apply Lorentz to Gauss filter
if lb > 0
end

%----------------------------------------------------------
% FFT spectrum
% Include orgin displacement and zero-padding for FFT
%----------------------------------------------------------

recosize = length(k) .* zpad;
s = fftshift(fft(k,recosize));

% Get sampling dimensions
nf = length(k);

% Construct the ppm scale for 1H water centered spectra
ppm = linspace(0,sw_ppm,nf) - sw_ppm/2 + 4.7 + info.sw_offset_ppm;

% Autophase 
if autophase
  
  % Set the region around water to zero
  srng = ppm > 4.5 & ppm < 4.9;
  s(srng) = 0.0;
  
  s = ACME(s,[0 0]);
  
end

mrsplot(ppm,s);
