function [s, ppm, info] = parxloadmrs(imnddir)
% [s, ppm, info] = parxloadmrs(imnddir)
%
% Load a Paravision 1D spectroscopy file.
% Assumes imnd, acqp, subject files are present for this series.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/06/2001 Adapt from parxload2dseq
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

fname = 'parxloadmrs';

% Default args
if nargin < 1; imnddir = pwd; end

% Load the series information
info = parxloadinfo(imnddir);

% Construct MRS channel pathnames
realfile = fullfile(imnddir,'pdata','1','1r');
imagfile = fullfile(imnddir,'pdata','1','1i');

% Set byte order flag
switch info.byteorder
  case 'littleEndian'
    border = 'ieee-le';
  case 'bigEndian'
    border = 'ieee-be';
end

% Open the real channel file
fdr = fopen(realfile,'r',border);
if fdr < 0
  errmsg = sprintf('%s: Could not open %s to read\n', fname, realfile);
  waitfor(errordlg(errmsg));
  return;
end

% Open the imag channel file
fdi = fopen(imagfile,'r',border);
if fdi < 0
  errmsg = sprintf('%s: Could not open %s to read\n', fname, imagfile);
  waitfor(errordlg(errmsg));
  return;
end

% Read the complex data
switch info.acqdepth
case 32
  dr = fread(fdr, Inf, 'int32');
  di = fread(fdi, Inf, 'int32');
case 16
  dr = fread(fdr, Inf, 'int16');
  di = fread(fdi, Inf, 'int16');
otherwise
  fprintf('%s: Unknown bit depth %s\n', fname, info.depth);
end  

% Close the files
fclose(fdr);
fclose(fdi);

% Create complex spectrum
s = complex(dr,di);

% Create ppm scale (assuming water on resonance)
nf = length(s);
sw = info.sw_spec_Hz;
if sw == 0 || isnan(sw); sw = info.bw; end
cf = info.cf;
ppm = 4.7 - (((1:nf) - 1)/nf - 0.5) * sw / cf;