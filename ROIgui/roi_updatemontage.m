function roi_updatemontage(fig)
% roi_updatemontage(fig)
%
% Redraw the ROI montage in the GUI figure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 08/22/2001 From scratch

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