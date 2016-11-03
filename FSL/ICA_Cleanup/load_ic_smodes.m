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

% Check that ICA directory exists
if ~exist(ICA_dir,'dir');
  fprintf('*** ICA directory not found - returning\n');
  IC_smodes = [];
  return
end

% Load spatial ICs from melodic_IC.nii.gz
IC_smodes = load_nii(fullfile(ICA_dir,'melodic_IC.nii.gz'));
