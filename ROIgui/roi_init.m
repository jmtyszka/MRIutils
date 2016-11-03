function roi_init(fig)
% roi_init(fig)
%
% Initialize ROI drawing interface
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 08/17/2001 From scratch
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

% Get the GUI data structure
data = guidata(fig);

% Default data directory
data.datadir = 'D:\B0 Maps\Head Tilt Maps';

% Create image childern in the Fuse and Map axes
set(fig,'HandleVisibility','on');
figure(fig);
colormap(gray);

axes(data.ROIAxes);
data.ROIImage = imagesc(zeros(64,64));
axis off xy;

% Set callback function for the ROI image
set(data.ROIImage, 'ButtonDownFcn', 'roi_drawroi');

axes(data.MontageAxes);
data.MontageImage = imagesc(zeros(256,256));
axis off xy;

set(fig,'HandleVisibility','off');

% Setup RGB compositing
data.CompMode = 'multiply';

% Resave GUI data
guidata(fig,data);
