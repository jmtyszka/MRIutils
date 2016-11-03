function [fid, info] = parxloadpc(imnddir)
% [fid, info] = parxloadpc(imnddir)
%
% Load a Paravision 3D PC fid file into an array
%
% ARGS:
% filename = fid filename (full path)
%
% RETURNS:
% fid      = complex double fid data
% info     = data information structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/25/2000 Adapt from BIC_Load2DSeq.m
%          03/22/2001 Use imnd directory and return info structure
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

fname = 'parxloadpc';

% Load the imnd, etc information
info = parxloadinfo(imnddir);

% Spatial dimensions of the dataset
nx = info.sampdim(1);
ny = info.sampdim(2);
nz = info.sampdim(3);

% Number of velocity encoding echoes
switch info.vencdir
case 'All_VENC'
  nvenc = 4;
otherwise
  nvenc = 2;
end

% Clear the returned matrix
fid = zeros(nx,ny,nz,nvenc);

% Construct the full path fid filename
fidname = fullfile(imnddir,'fid');

% Open the file
switch info.byteorder
  case 'bigEndian'
    fd = fopen(fidname,'r','ieee-be');
  case 'littleEndian'
    fd = fopen(fidname,'r','ieee-le');
end

if (fd < 1)
  errmsg = sprintf('%s: Could not open %s to read\n', fname, fidname);
  waitfor(errordlg(errmsg));
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fidraw = fread(fd, Inf, 'int32');

% Close the file
fclose(fd);

% Expected and actual voxel count
vexpect = 2 * prod([nx ny nz nvenc]);
vactual = length(fidraw);

if (vexpect ~= vactual)
  
  errmsg = sprintf('%s: fid file error (%d expected %d actual)\n', ...
    fname, vexpect, vactual);
  waitfor(errordlg(errmsg));
  return;
  
else

  % Reshape the data
  % The loop order is x, v, y, z in the pulse sequence
  fidraw = reshape(fidraw, nx * 2, nvenc, ny, nz);

  % Construct the complex matrix from the odd and even x rows
  fid = squeeze(fidraw(1:2:nx*2,:,:,:) + i * fidraw(2:2:nx*2,:,:,:));

  % Transpose the dimensions into the order x,y,z,v
  fid = permute(fid, [1 3 4 2]);

end
