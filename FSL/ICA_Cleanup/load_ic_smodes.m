function IC_smodes = load_ic_smodes(ICA_dir)
% Load IC spatial modes from a Melodic output directory
%
% USAGE: 
% IC_smodes = load_ic_smodes(ICA_dir)
%
% ARGS:
% ICA_dir = Melodic .ica directory containing IC results [pwd]
%
% RETURNS:
% IC_smodes = matrix of IC spatial modes
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/24/2013 JMT Adapt from load_ic_smodes.m (JMT)
%
% Copyright 2013 California Institute of Technology.
% All rights reserved.

% Check that ICA directory exists
if ~exist(ICA_dir,'dir');
  fprintf('*** ICA directory not found - returning\n');
  IC_smodes = [];
  return
end

% Load spatial ICs from melodic_IC.nii.gz
IC_smodes = load_nii(fullfile(ICA_dir,'melodic_IC.nii.gz'));