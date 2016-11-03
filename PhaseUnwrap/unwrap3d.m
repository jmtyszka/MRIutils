function [psi_uw,trust] = unwrap3d(psi_w, mag, mag_thresh)
% Unwrap 3D phase image by region growing
%
% [psi_uw,trust] = unwrap3d(psi_w, mag, mag_thresh)
%
% ARGS:
% psi_w      = 3D phase-wrapped data
% mag        = 3D magnitude data
% mag_thresh = magnitude threshold to create mask
%
% RETURNS:
% psi_uw     = unwrapped 3D phase image
% trust      = trust region mask
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/06/2000 JMT Adapt from MEX_Unwrap2D
%          04/10/2001 JMT Add M-file wrapper
%          01/17/2006 JMT M-Lint corrections
%
% REFS   : Based on ideas in Wei Xu and Ian Cumming
%          "A Region Growing Algorithm for InSAR Phase Unwrapping".
%          Proceedings of the 1996 IEEE International Geoscience and Remote Sensing Symposium.
%          IGARSS'96, pp. 2044-2046, Lincoln, USA, May. 1996.
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


[psi_uw,trust] = MEX_Unwrap3D(psi_w, mag, mag_thresh);
