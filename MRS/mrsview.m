function mrsview(mrsdir,scoutdir,ppmlims,slims,lb)
% Paravision SV spectrum display
%
% mrsview(mrsdir,scoutdir,ppmlims,slims,lb)
%
% Display a Paravision single voxel spectrum, the localizer and metabolite
% voxel overlays. Assume voxel selection order of [slice, read, phase]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/18/2002 JMT From scratch
%          07/19/2002 JMT Add metabolite uncertainty voxel
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2002-2006 California Institute of Technology.
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

% Operational flags
doprint = 0;

% Catch argument error
if nargin < 2
  help mrsview
  return
end

if nargin < 3; ppmlims = [0 6]; end
if nargin < 4; slims = []; end
if nargin < 5; lb = 0.0; end

% Internal constants
xpad = 256;
ypad = 256;
water_shift = 4.70; % in ppm at 37degC
naa_shift   = 2.02; % in ppm at 37degC

%----------------------------------------------------------
% MRS VOXEL
%----------------------------------------------------------

% Load the spectrum and information structure
[mrs,ppm,info_vox] = parxloadmrs(mrsdir);

% Normalize noise sd (MAD estimate)
noise_samp = mrs(1:16);
sd_n = median(abs(noise_samp - median(noise_samp))) / 0.6745;
mrs = mrs / sd_n;

% Linebroaden
if lb > 0.0
  mrs = linebroaden(mrs,info_vox.bw,lb);
end

% Determine voxel slice bandwidths in Hz
switch upper(info_vox.method)
  case 'VSEL_SE'
    slbw = info_vox.excbw;
  case 'VSEL_STE'
    slbw = info_vox.excbw;
end

% Voxel location and size for water resonance
vpos = info_vox.vpos * 10; % mm
vsize = info_vox.vsize_mrs;    % mm

% Spatial extents for voxel in mm
voxlims = [vpos-vsize/2 vpos+vsize/2];
naa_scale = (water_shift - naa_shift) * info_vox.cf / slbw + 1;
voxlims_naa = [vpos-vsize/2*naa_scale vpos+vsize/2*naa_scale];

%----------------------------------------------------------
% SCOUT IMAGE
%----------------------------------------------------------

if ~isempty(scoutdir)
  
  % Load the scout images
  [img,info_img] = parxload2dseq(scoutdir);
  
  % Imaging axis vectors - assume parallel to cardinal direction - no obliques
  rv_img = info_img.rdvector;
  sv_img = info_img.slpackvector;
  pv_img = abs(cross(rv_img,sv_img));
  
  % Determine dimension index for each imaging axis
  % Assumes imaging axes are parallel to cardinal directions in gradient frame
  rdir_img = find(rv_img); 
  sdir_img = find(sv_img);
  pdir_img = find(pv_img);
  
  % Determine slice center coordinate vectors in mm
  spos  = cumsum([0;info_img.slsepn]);
  s0    = (info_img.slpackpos + spos - mean(spos));
  
  % Determine limits of read coordinates in mm
  % NOTE : Do not include read offset (info_img.rdoffset)
  % apparently it's already included in the voxel location
  % or isn't used by the scout
  
  rmin = -info_img.fov(1) * 5 + info_img.rdoffset;
  rmax = info_img.fov(1) * 5 + info_img.rdoffset;
  
  % Determine limits of phase coordinates in mm
  pmin = info_img.ph1offset - info_img.fov(2) * 5;
  pmax = info_img.ph1offset + info_img.fov(2) * 5;
  
  % Find nearest slice to voxel center
  ds = abs(vpos(sdir_img) - s0);
  [minds,nearsl] = min(ds);
  
  % Report key information
  fprintf('\nVoxel locator\n');
  fprintf('-------------\n');
  fprintf('Voxel size   : %0.1f mm x %0.1f mm x %0.1f mm\n', vsize(1), vsize(2), vsize(3));
  fprintf('Voxel center : (%0.1f, %0.1f, %0.1f) mm\n', vpos(1), vpos(2), vpos(3));
  fprintf('Closest slice : %d (%0.1f mm from voxel center)\n\n',nearsl,minds);
  
  % Display the scout image with a scaled mesh
  scoutim = imresize(fliplr(flipud(img(:,:,nearsl)')),[xpad ypad],'bicubic');
  
  set(gcf,'color','w');
  colormap(gray);
  subplot(121), imagesc([pmin pmax],[rmin rmax],scoutim);
  axis equal xy;
  grid on;
  set(gca,'XColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5]);
  
  % Overlay the voxel limits for water
  hold on;
  rd0 = voxlims(rdir_img,1);
  rd1 = voxlims(rdir_img,2);
  ph0 = voxlims(pdir_img,1);
  ph1 = voxlims(pdir_img,2);
  line([ph0, ph1, ph1, ph0, ph0],[rd0 rd0 rd1 rd1 rd0],'color','w','linewidth',1);
  hold off;
  
  % Overlay the voxel limits for NAA
  hold on;
  rd0 = voxlims_naa(rdir_img,1);
  rd1 = voxlims_naa(rdir_img,2);
  ph0 = voxlims_naa(pdir_img,1);
  ph1 = voxlims_naa(pdir_img,2);
  line([ph0, ph1, ph1, ph0, ph0],[rd0 rd0 rd1 rd1 rd0],'color','w','linewidth',1,'linestyle',':');
  hold off;
  
  % Display the spectrum
  subplot(122), mrsplot(ppm,mrs,ppmlims,slims,info_vox);
  
else

  % Just plot the spectrum without any anatomic localizer
  mrsplot(ppm,mrs,ppmlims,slims,info_vox);
  
end
  
% Print figure as EPS2 color to a file
if doprint
  tstring = sprintf('mrsview_%s_%d_%d_%s_%d_%d.eps',...
    info_vox.id, info_vox.studyno, info_vox.serno, info_vox.method, info_vox.tr, info_vox.te);
  fprintf('Printing file to %s\n', tstring);
  print('-depsc2',tstring);
end