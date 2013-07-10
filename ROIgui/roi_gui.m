function varargout = roi_gui(varargin)
% ROI_GUI Application M-file for roi_gui.fig
%    FIG = ROI_GUI launch roi_gui GUI.
%    ROI_GUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 17-Aug-2001 15:50:31

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = SliceSlider_Callback(h, eventdata, handles, varargin)

% Update the unregistered slice number from the slider
% Keep the slice number even
s = get(handles.SliceSlider,'Value');
s = round(s/2) * 2;
if s > handles.nx s = handles.nx; end
if s < 1 s = 1; end
handles.slice = s;
guidata(handles.fig, handles);

% Update displayed slice in ROI drawing window
roi_updateimage(handles.fig);


% --------------------------------------------------------------------
function varargout = FileMenu_Callback(h, eventdata, handles, varargin)

% Do nothing


% --------------------------------------------------------------------
function varargout = FileLoad_Callback(h, eventdata, handles, varargin)

% Load the file using a dialog
roi_load(handles.fig);


% --------------------------------------------------------------------
function varargout = FileSave_Callback(h, eventdata, handles, varargin)

% Save the ROI and M data in a new file
roi_save(handles.fig);


% --------------------------------------------------------------------
function varargout = FileQuit_Callback(h, eventdata, handles, varargin)

% Call the ROI save dialog
roi_save(handles.fig);

% Destroy the figure (avoids close request loops)
delete(handles.fig);
