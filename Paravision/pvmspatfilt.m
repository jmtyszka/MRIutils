function kf = pvmspatfilt(k, filttype, fr, fw, echopos)
% Apply spatial filter to k-space data
%
% SYNTAX: kf = pvmspatfilt(k, filttype, fr, fw, echopos)
%
% ARGS:
% k = 2D or 3D complex k-space
% filttype = filter type: 'hamming','gauss','fermi'
% fr = normalized filter radius or PSF FWHM for Gauss filtering [0.5]
% fw = normalized filter width (0 - 0.5) [0.0]. Unused by Gauss filtering
% echopos = echo location in 1st dimension (0-100%) [50%]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/10/2007 JMT Extract and adapt from parxrecon.m
%          2015-04-05 JMT Map fr to FWHM for Gauss filtering
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

% k-space dimensionality (presumed <= 3)
nDim = ndims(k);
[nx,ny,nz] = size(k);

%----------------------------------------------------------
% Spatial filter
%----------------------------------------------------------

switch filttype

  case 'hamming'

    switch nDim
      case 2
        Hfilt = hamming2([nx ny], fr, echopos/100);
        Hfilt = repmat(Hfilt,[1 1 nz]);
      case 3
        Hfilt = hamming3([nx ny nz], fr, echopos/100);
    end

    % Apply filter
    kf = k .* Hfilt;

  case 'gauss'
    
    % For Gauss filtering, fr is the FWHM of the PSF in voxels
    FWHM = fr;

    switch nDim
      case 2
        Hfilt = gauss2([nx ny], FWHM, echopos/100);
        Hfilt = repmat(Hfilt,[1 1 nz]);
      case 3
        Hfilt = gauss3([nx ny nz], FWHM, echopos/100);
    end

    % Apply filter
    kf = k .* Hfilt;

  case 'fermi'

    switch nDim
      case 2
        Hfilt = fermi2([nx ny], fr, fw, echopos/100);
      case 3
        Hfilt = fermi3([nx ny nz], fr, fw, echopos/100);
    end

    % Apply filter
    kf = k .* Hfilt;

  otherwise

    % Do nothing
    kf = k;
    
end
