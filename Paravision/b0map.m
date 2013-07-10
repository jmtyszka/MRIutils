function parx2fslfmap(sdir,snos)
% Calculate a B0 map from multiple gradient echo scans
%
% b0map(sdir,snos)
%
% ARGS:
% sdir = study directory containing all GRE scans
% snos = scan numbers of GREs used to calculate B0
%
% OUTPUTS
% fmap.nii.gz and fmap_mag.nii.gz ready for FUGUE processing of EPI data
%
% DATES: 10/10/2005 JMT From scratch
%        01/17/2006 JMT M-Lint corrections
%        10/26/2010 JMT Switch to PRELUDE and FUGUE 
%
% Copyright 2010 California Institute of Technology.
% All rights reserved.
%
% This file is part of MRutils.
%
% MRutils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% MRutils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MRutils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

if nargin < 1; sdir = pwd; end
if nargin < 2; snos = []; end

if isempty(snos)
  fprintf('Please provide the scan numbers to use for B0 calculation\n');
  return
end

options.imtype = 'c'; % Complex image returned

% Assume two GREs
fprintf('Reconstructing S(0)\n');
[s0,info0] = parxrecon(fullfile(sdir,num2str(snos(1))),options);
fprintf('Reconstructing S(1)\n');
[s1,info1] = parxrecon(fullfile(sdir,num2str(snos(2))),options);

te0 = info0.te;
te1 = info1.te;
bw = 1000 / (te1 - te0);

fprintf('TE(0) : %0.3fms\n', te0);
fprintf('TE(1) : %0.3fms\n', te1);
fprintf('BW    : %0.3fHz\n', bw);

fprintf('Calculating magnitude thresholds\n');
mag = abs(s0) + abs(s1);
mag = mag / max(mag(:));
magth = graythresh(mag);

fprintf('Calculating phase differences\n');
phi0 = angle(s0);
phi1 = angle(s1);
dphi = phi1 - phi0;

fprintf('Phase unwrapping\n');
[dphi_uw,trust] = unwrap3d(dphi,mag,magth);

fprintf('Calculating B0\n');
B0 = dphi_uw * bw / (2 * pi);
Mask = logical(trust);
B0 = B0 .* Mask;

% Unbias the B0 map using very strong median filtering
mB0 = medfilt3(B0,21);

% Subtract baseline
B0 = B0 - mB0;

% Display threeplane view of field map
threeplane(B0,[-200 200],redblue);
