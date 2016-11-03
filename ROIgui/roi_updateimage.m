function roi_updateimage(fig)
% roi_updateimage(fig)
%
% Redraw the image and ROI montage in the GUI figure
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

% Get GUI data
data = guidata(fig);

% Extract sagittal slice from image data
Ms = squeeze(data.M(data.slice,:,:));
ROIs = squeeze(data.ROI(data.slice,:,:));

% Orient correctly
Ms = flipdim(Ms',2);
ROIs = flipdim(ROIs',2);

% Colorize both images and composite
ROIs_rgb = MEPSI_Colorize(ROIs, [0 1], jet(128));
Ms_rgb = MEPSI_Colorize(Ms, [0 1], gray(128));
s_rgb = MEPSI_Composite(ROIs_rgb, Ms_rgb, 0.5, 1.0, data.CompMode);

% Paint the image of the requested map slice
set(fig,'HandleVisibility','on');
set(data.ROIImage,'CData',s_rgb);

% Hide the figure handles again
set(fig,'HandleVisibility','off');

% Update the slice number
set(data.SliceText, 'String', sprintf('Slice %d/%d\n', data.slice, data.nx));


