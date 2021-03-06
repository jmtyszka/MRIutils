function roi_load(fig)
% roi_load(fig)
%
% Load a 3D magnitude image (Mraw[]) from a .MAT file
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
[fname, dname] = uigetfile([data.datadir '\*.mat']);

% Catch cancel button
if isequal(fname,0) | isequal(dname,0)
  return
end

% Load the specified .MAT file
d = load([dname '\' fname]);

% Store dataset information in the GUI data structure
data.datadir = dname;
data.datamat = fname;
data.info    = d.info;

% Also check for corresponding ROI data
r = [];
roiname = sprintf('%s\\%d_%d_ROI.mat', dname, data.info.exno, data.info.seno);
if exist(roiname) == 2
  r = load(roiname);
end

% Place image data in GUI data structure
data.M = d.M;

% Place ROI data in GUI data structure
% Use existing data if present
if ~isempty(r)
  data.ROI = r.ROI;
else
  data.ROI = zeros(size(data.M));
end

% Save the data dimensions and default slice
[nx, ny, nz] = size(data.M);
data.slice = round(nz/2);
data.nx = nx;
data.ny = ny;
data.nz = nz;

% Set the slice slider range, step sizes and value
if nz > 1
  set(data.SliceSlider, 'Min', 1, 'Max', nz, 'SliderStep', [2 2] / (nz - 1));
  set(data.SliceSlider, 'Value', data.slice);
  set(data.SliceSlider, 'Visible', 'on');
else
  % Hide the unregistered image slider
  set(data.SliceSlider, 'Visible', 'off');
end

% Resave GUI data
guidata(fig,data);

% Update the display
roi_updateinfo(fig);
roi_updateimage(fig);
roi_updatemontage(fig);
