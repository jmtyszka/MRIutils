function aviwrite(s,aviname,clims,cmap,fps)
% Write a 3D dataset as an AVI movie using the CinePak codec
% 
% aviwrite(s,aviname,clims)
%
% ARGS :
% s       = 3D data
% aviname = output AVI filename
% clims   = normalized colormap limits in range 0..1 [0 1]
% cmap    = colormap vector [gray(128)]
% fps     = frames per second [10]
% 
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/22/2001 JMT From scratch
%          02/24/2004 JMT Debug args and cmap
%          01/18/2005 JMT Add fps argument
%          01/17/2006 M-Lint corrections
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

if nargin < 3; clims = [0 1]; end
if nargin < 4; cmap = gray(128); end
if nargin < 5; fps = 15; end

if isempty(clims); clims = [0 1]; end
if isempty(cmap); cmap = gray(128); end
if isempty(fps); fps = 15; end

if ndims(s) ~= 3
  fprintf('Input data must have three dimensions\n');
  return
end

% Grab data dimensions
[nx,ny,nt] = size(s);

if isempty(clims); clims = [0 1]; end

% Globally scale data to colormap range
ncol = length(cmap);
minc = 1;
maxc = ncol;
mins = min(s(:));
maxs = max(s(:));
rngs = maxs - mins;

% Adjust source limits
mins = mins + rngs * clims(1);
maxs = mins + rngs * clims(2);

% Clamp data
s(s < mins) = mins;
s(s > maxs) = maxs;

% Scale data to colormap range
s = fix((s - mins) / (maxs - mins) * (maxc - minc) + minc);

% Flip first dimension (X = rows)
s = flipdim(s,1);

% Remove file if it exists
if exist(aviname,'file') > 0
  fprintf('Overwriting %s\n', aviname);
  delete(aviname);
end

% Open AVI file
% 'Indeo3', 'Indeo5', 'Cinepak', 'MSVC', 'RLE' or 'None'
try
  af = avifile(aviname,...
    'compression','None',...
    'fps',fps,...
    'colormap',cmap);
catch
  fprintf('Problem opening AVI file - exiting\n');
  return
end

% Interpolated size (target largest dimension to 256)
if nx > ny
  nx_i = 256;
  ny_i = 256 * ny / nx;
else
  nx_i = 256 * nx / ny;
  ny_i = 256;
end

% Write frames
for tc = 1:nt

  % Fourier interpolate s to 256 x 256
  sf = imresize(s(:,:,tc),[nx_i ny_i],'bicubic');

  % Clamp interpolated image to colormap range
  sf(sf > maxc) = maxc;
  sf(sf < minc) = minc;

  % Add indexed color frame to movie
  try
    af = addframe(af,sf);
  catch
    af = close(af);
  end
  
end

% Close AVI file
close(af);
