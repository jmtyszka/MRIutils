function [k, navk, examinfo] = parxloadpcnav(imnddir, verbose)
% [k, navk, examinfo] = parxloadpcnav(imnddir, verbose)
%
% Load a Paravision 4D PC k-space with navigators into an array
%
% ARGS:
% imnddir = directory containing the fid file
%
% RETURNS:
% k        = complex double k-space data
% navk     = complex double navigator k-space data
% examinfo = information structure for the exam
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/02/2000 Adapt from parxloadpc.m
%          11/06/2000 Update for 4D data
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

fname = 'parxloadpcnav';

if nargin < 2
   verbose = 1;
end

% Load the imnd, etc information
examinfo = parxloadinfo(imnddir);

% Spatial dimensions of the dataset
nx = examinfo.sampdim(1);
ny = examinfo.sampdim(2);
nz = examinfo.sampdim(3);

% Number of velocity encoding echoes
switch examinfo.vencdir
case 'All_VENC'
  nvenc = 4;
otherwise
  nvenc = 2;
end

% There are two echoes/TR (venc and nav)
necho = 2;

% The number of RR repeats is examinfo.nims / (nv * necho)
nrr = round(examinfo.nims / (nvenc * necho));

if verbose
   fprintf('Navigated PC Data\n');
   fprintf('--------------------\n');
   fprintf('Dimensions : %d x %d x %d\n', nx, ny, nz);
   fprintf('VENCs      : %d\n', nvenc);
   fprintf('RR reps    : %d\n', nrr);
   fprintf('Est memory : %d MB\n', nx * ny * nz * nvenc * nrr * 32 / (1024^2));
end

% Clear the returned matrices
k    = [];
navk = [];

% Construct the full path fid filename
fidname = fullfile(imnddir,'fid');

% Open the file
fd = fopen(fidname,'r','ieee-be');
if (fd < 1)
  errmsg = sprintf('%s: Could not open %s to read\n', fname, fidname);
  waitfor(errordlg(errmsg));
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Making space for temporary arrays\n');
k    = zeros([nx nvenc nrr ny nz]);
navk = zeros([nx nvenc nrr ny nz]);

% Load pc data into memory
if verbose; fprintf('%s: Reading data:', fname); end

nel = 2 * nx * necho * nvenc * nrr * ny;

for z = 1:nz
  
  fprintf(' %d', z);

  kbuf    = fread(fd, nel, 'int32');
  kbuf_re = reshape(kbuf(1:2:nel), [nx necho nvenc nrr ny]);
  kbuf_im = reshape(kbuf(2:2:nel), [nx necho nvenc nrr ny]);
  
  k(:,:,:,:,z)    = double(complex(kbuf_re(:,1,:,:,:),kbuf_im(:,1,:,:,:)));
  navk(:,:,:,:,z) = double(complex(kbuf_re(:,2,:,:,:),kbuf_im(:,2,:,:,:)));
  
end

fprintf('\n');

% Close the file
fclose(fd);

% Free temporary memory
clear kbuf kre kim navkre navkim;

% We're done
if verbose; fprintf('%s: Done\n', fname); end
