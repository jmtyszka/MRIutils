function parx2tiff(rootdir)
% parx2tiff(rootdir)
%
% Convert all qualifying Paravision image series within the
% supplied root directory to TIFF stacks. A new subdirectory
% is created within each series directory containing the new stack.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/03/2001 Adapt from bix_saveas.m (JMT BIX package)
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2004-2006 California Institute of Technology.
% All rights reserved.

% Defaults
if nargin < 1
  rootdir = pwd;
end

% Get a cell structure array containing info about all PARX series in rootdir
serlist = parxfindseries([], rootdir, [], {});

% Loop over all exams
for sc = 1:length(serlist);
  
  % Extract current exam info
  se = serlist(sc);
  
  % Create subdirectory for TIFF stack
  tiffdir = sprintf('%s_%d_TIFF',se.id,se.serno);
  [status,msg] = mkdir(se.path,tiffdir);

  if status == 0

    % Problem creating TIFF directory
    fprintf('Problem creating TIFF directory : %s\n', msg);
    
  else
  
    % Extract image spatial and temporal dimensions
    nz = se.dim(3);
    nt = se.dim(4);
  
    count = 1;
  
    for tc = 1:nt
      for zc = 1:nz
      
        % Create a filename for this image
        fname = sprintf('%s\\%s_z%04d_t%04d.tif', pathname, filestub,zc,tc);
        
        % Save this image
        this_im = data.s(:,:,zc,tc);
        imwrite(this_im, fname, 'tif');
      
        % Increment the image counter
        count = count+1;
      
      end
    end
  
  end
  
end
