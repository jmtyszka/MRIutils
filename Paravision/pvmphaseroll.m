function kr = pvmphaseroll(k,info)
% kr = pvmphaseroll(k,info)
%
% Apply the phase rolls from the reco file (RECO_rotate) as
% linear phasings to a 3D k-space.
%
% ARGS :
% k    = 3D complex k-space data
% info = info structure for Paravision dataset (info.recorot[])
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/17/2002 From scratch
%          09/10/2007 JMT Move to PVM utilities toolbox
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

% Grab k-space dimensions
[nkx,nky,nkz] = size(k);

% k-space coordinate vectors for each dimension
kx = ((1:nkx)-1) - nkx/2;
ky = ((1:nky)-1) - nky/2;
kz = ((1:nkz)-1) - nkz/2;

% Normalized k-space coordinate grids
[kxg,kyg,kzg] = ndgrid(kx,ky,kz);

% Generate combined linear phase function

switch info.ndim
  case 2
    fx = info.recorot(1,1);
    fy = info.recorot(1,2);
    fz = 0.0;
  case 3
    fx = info.recorot(1);
    fy = info.recorot(2);
    fz = info.recorot(3);
end

phi = exp(-2 * pi * 1i * (fx * kxg + fy * kyg + fz * kzg));

% Apply phase functions
kr = k .* phi;




