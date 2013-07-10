function moco_pars = load_moco_pars(feat_dir)
% Load FEAT motion correction parameters
%
% USAGE: moco_pars = load_moco_pars(feat_dir)
%
% ARGS:
% feat_dir = .feat directory containing mc subdirectory
%
% RETURNS:
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 05/24/2012 JMT From scratch

% Default args
if nargin < 1; feat_dir = pwd; end

% Default return
moco_pars = [];

% Motion correction subdirectory
moco_dir = fullfile(feat_dir, 'mc');

% MOCO parameter file name
moco_file = fullfile(moco_dir, 'prefiltered_func_data_mcf.par');

% Try loading parameters
try
  moco_pars = load(moco_file);
catch MOCO
  rethrow MOCO
end