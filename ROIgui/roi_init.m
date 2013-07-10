function roi_init(fig)
% roi_init(fig)
%
% Initialize ROI drawing interface
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 08/17/2001 From scratch

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
