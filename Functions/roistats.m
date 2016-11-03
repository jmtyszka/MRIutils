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
