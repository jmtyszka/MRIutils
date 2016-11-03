function parx2fslfmap(study_dir,mge_scan)
% Convert Paravision MGE image pair to FSL fmap using PRELUDE and FUGUE
%
% parx2fslfmap(study_dir,mge)
%
% ARGS:
% study_dir = study directory containing all GRE scans
% mge_scan = scan number of two-echo MGE3D data
%
% OUTPUTS
% fmap.nii.gz and fmap_mag.nii.gz ready for FUGUE processing of EPI data
%
% DATES: 10/10/2005 JMT From scratch
%        01/17/2006 JMT M-Lint corrections
%        10/26/2010 JMT Switch to PRELUDE and FUGUE
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

if nargin < 2
  help parx2fslfmap
  return
end

% Complex reconstruction of GRE images
options.imtype = 'c'; % Complex image returned
fprintf('Reconstructing MGE fieldmap\n');
[mge,info] = parxrecon(fullfile(study_dir,num2str(mge_scan)),options);

dTE_ms = info.esp; % Echo time difference in ms
bw_Hz = 1000 / dTE_ms; % Frequency bandwidth in Hz

fprintf('dTE   : %0.3f ms\n', dTE_ms);
fprintf('BW    : %0.3f Hz\n', bw_Hz);

fprintf('Calculating magnitude thresholds\n');
mag = mean(abs(mge),4);
fmap_mag = mag / max(mag(:));

fprintf('Calculating phase differences\n');
phi = angle(mge);

% Map phase difference to -pi .. pi for PRELUDE
phi_rad = mod(diff(phi,1,4) + pi, 2*pi) - pi;

% Output filenames
phi_rad_file = fullfile(study_dir,'phi_rad.nii.gz');
fmap_mag_file = fullfile(study_dir,'fmap_mag.nii.gz');
phi_rad_uw_file = fullfile(study_dir,'phi_rad_uw.nii.gz');
fmap_file = fullfile(study_dir,'fmap.nii.gz');

fprintf('Saving mag and phase images\n');
mat = eye(4);
mat(1:3,1:3) = diag(info.vsize(1:3));
save_nii(phi_rad_file, phi_rad, 'FLOAT32', mat, mat);
save_nii(fmap_mag_file, fmap_mag, 'FLOAT32', mat, mat);

% Run PRELUDE phase unwrapping
fprintf('Phase unwrapping using PRELUDE (3D)\n');
cmd = sprintf('!prelude -a %s -p %s -o %s -v -f -t 0.05\n', fmap_mag_file, phi_rad_file, phi_rad_uw_file);
eval(cmd);

% Scale fmap to rad/s (ie multiply by bandwidth in Hz) for FUGUE
fprintf('Scaling field map to rad/s\n');
cmd = sprintf('!fslmaths %s -mul %0.3f %s -odt float',phi_rad_uw_file, bw_Hz, fmap_file);
eval(cmd);

% Condition fmap using FUGUE
fprintf('Conditioning fieldmap using FUGUE\n');
cmd = sprintf('!fugue --loadfmap=%s -m --savefmap=%s', fmap_file, fmap_file);
eval(cmd);
cmd = sprintf('!fugue --loadfmap=%s -s 1 --savefmap=%s', fmap_file, fmap_file);
eval(cmd);

fprintf('Done\n');
