function [xlims, ylims] = roigui(s)
% Allow user to specify a region of interest
%
% [xlims, ylims] = roigui(s)
%
% ARGS:
% s = 2D image on which to define the ROI
%
% RETURNS :
% xlims, ylims = pixel range of rectangular ROI
%
% DATES : 11/22/2004 JMT From scratch
%         01/17/2006 JMT M-Lint corrections
%
% Copyright 2004-2006 California Institute of Technology.
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


figure; clf
set(gcf,'Name','Specify an ROI');
imagesc(s); axis equal off xy;
[xlims,ylims] = roirect;
close(gcf);