function xtime(sdir,snos,filt,fr)
% Convert a Paravision time series to a set of Nifti-1 volumes
%
% xtime(sdir,snos,filt,fr)
%
% ARGS:
% sdir = directory containing time series scans
% snos = scan numbers of time series
%
% RETURNS:
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/13/2005 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2005-2006 California Institute of Technology.
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
if nargin < 3; filt = 'none'; end
if nargin < 4; fr = 0.5; end

if isempty(snos)
  
  fprintf('Scanning the directory for Paravision scans\n');

  count = 0;
  
  % Parse the directory structure of sdir
  d = dir(sdir);
  
  % Lexically sort names
  count = 0;
  for sc = 1:length(d)
    n = str2double(d(sc).name);
    if ~isempty(n) && ~isnan(n)
      count = count + 1;
      dn(count) = n;
    end
  end
  
  snos = sort(dn);
    
end

% Count number of scans to convert
nt = length(snos);

fprintf('Detected %d scans\n', nt);

% Make space for voxel size and time
vsize = zeros(3,nt);
t = zeros(1,nt);

% Construct options stucture for parxrecon
opts.filttype = filt;
opts.fr = fr;

for sc = 1:nt
  
  fprintf('Converting scan %d -> time %d\n',snos(sc), sc);
  
  % Construct the Pv scan directory name
  sname = fullfile(sdir,num2str(snos(sc)));

  if exist(sname,'dir')
  
    % Reconstruct the image
    [s,info] = parxrecon(sname,opts);
    
    if sc == 1

      % Initialize scale factor
      % Include a 25% safety factor on variations in max intensity over the
      % timeseries
      sf = 1/(max(s(:)) * 1.25);
      
      % Make a NIFTI subdirectory in sdir first time round
      niftidir = sprintf('%s_%d_NIFTI',info.name,info.studyno);
      niftipath = fullfile(sdir,niftidir);
      if ~exist(fullfile(sdir,niftidir),'dir')
        mkdir(sdir,niftidir);
      end

      % Initialize the Nifti-1 matrices
      mat = diag([info.vsize; 1]);
      mat0 = mat;
      
    end
    
    t(sc) = datenum(info.time);
    vsize(:,sc) = info.vsize;
    
    % Scale the image and clamp intensities
    maxvox = 2^15-1;
    s = s * sf * maxvox;
    s(s > maxvox) = maxvox;
    s(s < 0) = 0;
  
    % Output in Nifti-1 volume format
    save_nii(fullfile(niftipath,sprintf('t%03d.nii.gz',sc)),s,'INT16-LE',mat,mat0);
    
  end

end

%--------------------------------------------------------
% Write a text information file to the NIFTI subdirectory
%--------------------------------------------------------

fprintf('Writing information file to NIFTI directory\n');

infoname = fullfile(niftipath,sprintf('%s_%d_info.txt',info.name,info.studyno));
fd = fopen(infoname,'w');
if fd < 1
  fprintf('Could not write to information file\n');
  return
end

% Study directory
fprintf(fd,'Study Dir     : %s\n', sdir);

% Voxel size
mdx = median(vsize) * 1e3;
fprintf(fd,'Voxel size    : %0.1f x %0.1f x %0.1f microns\n',...
  mdx(1),mdx(2),mdx(3));

% Calculate mean time interval from scan date numbers
dt = mean(diff(t));
fprintf(fd,'Time Interval : %s (HH:MM:SS)\n',datestr(dt,13));

% Close the info file
fclose(fd);