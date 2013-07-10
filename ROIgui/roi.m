function roi
% roi
%
% Wrapper function for ROI drawing GUI
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 08/17/2001 From scratch

% Start the GUI
fig = roi_gui;

% Initialize the GUI
roi_init(fig);

% Control passes to the GUI
