function f = parxfilm(imnddir)
% f = parxfilm(imnddir)
%
% Create a one page PNG montage of a PARX data series
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/24/2001 From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

% Load the image data
s = parxload2dseq(imnddir);

% Create a PNG montage of the data
f = pngmontage(s);
