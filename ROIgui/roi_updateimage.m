function roi_updateimage(fig)
% roi_updateimage(fig)
%
% Redraw the image and ROI montage in the GUI figure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 08/17/2001 From scratch

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


