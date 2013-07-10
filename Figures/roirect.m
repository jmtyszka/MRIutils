function [xlims, ylims] = roirect
% User defined rectangular ROI definition
%
% [xlims, ylims] = roirect
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

% Detect button press
waitforbuttonpress;
point1 = get(gca,'CurrentPoint');

% Rubberband box return figure units
rbbox;

% Button up detected
point2 = get(gca,'CurrentPoint');

% Extract x and y axis coordinates (x->cols, y->rows)
point1 = point1(1,1:2);
point2 = point2(1,1:2);

% Calculate corner coordinates
minxy = min(point1,point2);         
maxxy = max(point1,point2);

% Reassign x->rows and y->cols (matrix indexing)
xlims = round([minxy(2) maxxy(2)]);
ylims = round([minxy(1) maxxy(1)]);

