function vals = roistats(s)
% Calculate descriptive statistics for a user-drawn ROI.
%
% vals = roistats(s)
%
% Look until ROI has zero size (double-click) outputting
% stats for each new ROI drawn.
%
% ARGS :
% s = 2D grayscale image
%
% RETURNS :
% vals = stats results structure for last ROI
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : Caltech BIC
% DATES : 03/15/2002 JMT From scratch
%         01/17/2006 JMT M-Lint corrections
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

% Print help if no arguments supplied
if nargin < 1
  help roistats
  return
end

% Setup figure window
clf; colormap(gray);
set(gcf,'color','k');

% Draw image
imagesc(s); axis equal off;

% Set continue flag
keepgoing = 1;

% Loop until zero size ROI is defined
while keepgoing
  
  % Let user draw a polygonal ROI
  proi = roipoly;
  
  % Extract ROI sample from image
  samp = s(proi);
  
  % Check for zero size ROI
  if isempty(samp)
  
    % Unset continue flag
    keepgoing = 0;
    
  else
    
    % Construct stats structure
    vals.n      = length(samp);
    vals.mean   = mean(samp);
    vals.median = median(samp);
    vals.sd     = std(samp);
    vals.var    = var(samp);
    vals.se     = vals.sd / sqrt(vals.n-1);
    vals.noise  = median(abs(samp - median(samp))) / 0.6745;
    
    % Display results
    disp(vals);
    
  end
    
end
