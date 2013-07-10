function roi_drawroi
% roi_drawroi
%
% Draw the ROI in the image window
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 08/22/2001 From scratch

% Get the figure handle
fig = get(get(gcbo,'Parent'),'Parent');;

% Get GUI data
data = guidata(fig);

% Allow user to draw ROI in this slice
set(fig,'HandleVisibility','on');
axes(data.ROIAxes);
ROIs = roipoly;
set(fig,'HandleVisibility','off');

% Orient ROIs correctly
ROIs = flipdim(ROIs',1);

% Convert to logical binary mask
data.ROI(data.slice,:,:) = ROIs;

% Resave GUI data
guidata(fig,data);

% Update Image and ROI montage
roi_updateimage(fig);
roi_updatemontage(fig);