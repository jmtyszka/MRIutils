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

