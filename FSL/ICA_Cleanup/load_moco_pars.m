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
