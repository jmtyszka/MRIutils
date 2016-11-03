function roi_save(fig)
% roi_save(fig)
%
% Save the ROI
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

% Get data from GUI
data = guidata(fig);

% Show a file load dialog
[fname, dname] = uiputfile(sprintf('%s\\%d_%d_ROI.mat',data.datadir,data.info.exno, data.info.seno));

% Catch cancel button
if isequal(fname,0) | isequal(dname,0)
  return
end

% Extract the image data from the GUI structure
M    = data.M;
ROI  = data.ROI;
info = data.info;

% Interpolate the odd sagittal slices of the ROI
fprintf('Interpolating odd sagittal slices of ROI mask\n');

% Preblur even ROIs using a 5 x 5 (sd = 2.0) Gaussian convolution filter
PSF = fspecial('gaussian',5,2);
ROIb = zeros(size(ROI));
for x = 2:2:data.nx
  ROIb(x,:,:) = imfilter(squeeze(double(ROI(x,:,:))),PSF,'conv');
end

% Interpolate odd slices by binarizing the mean of the blurred adjacent ROIs
for x = 3:2:(data.nx-1);
  ROIprev = ROIb(x-1,:,:);
  ROInext = ROIb(x+1,:,:);
  ROI(x,:,:) = ((ROIprev + ROInext) > 1);
end

% Save the complete ROI in the specified .MAT file
save([dname '\' fname],'ROI','M','info');
