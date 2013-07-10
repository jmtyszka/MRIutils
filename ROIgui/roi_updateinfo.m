function roi_updateimage(fig)
% roi_updateimage(fig)
%
% Display dataset information in the InfoText field
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 08/24/2001 From scratch

% Get GUI data
data = guidata(fig);

% Construct the text field
set(data.InfoText,'String',sprintf('Exam: %d Series: %d', data.info.exno, data.info.seno));
