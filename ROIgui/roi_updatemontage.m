function roi_updatemontage(fig)
% roi_updatemontage(fig)
%
% Redraw the ROI montage in the GUI figure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 08/22/2001 From scratch
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

% Get GUI data
data = guidata(fig);

% Create a new montage image in memory
ROIMont = montagegray(data.ROI);
MMont = montagegray(data.M);

% Resize to fit the montage display
ROIMont = imresize(ROIMont, [256 256]);
MMont = imresize(MMont, [256 256]);

% Colorize both images and composite
ROIMont_rgb = MEPSI_Colorize(ROIMont, [0 1], jet(128));
MMont_rgb = MEPSI_Colorize(MMont, [0 1], gray(128));
Mont_rgb = MEPSI_Composite(ROIMont_rgb, MMont_rgb, 0.5, 1.0, data.CompMode);

% Paint the image of the requested map slice
set(fig,'HandleVisibility','on');

set(data.MontageImage,'CData',Mont_rgb);

% Hide the figure handles again
set(fig,'HandleVisibility','off');
