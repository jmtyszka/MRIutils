function mpcu = mpcu_parseJD(logfile)
% Parse a Siemens MPCU log file
%
% USAGE: mpcu = mpcu_parse(logfile)
%
% ARGS:
% logfile = filename of log file to parse
% 
% RETURNS:
% mpcu = results structure
% .mode = physio mode (eg 'ecg')
% .waveform = sampled physio waveform (AU)
% .t = time vector (seconds)
% .dt = sampling dwell time (seconds)
% .trigger_idx = indices of on rhythm triggers
% .trigger = times of on-rhythm triggers
%
% VERSION : 2.0
%
% AUTHORS : Mike Tyszka, Ph.D. and Julien Dubois, Ph.D.
% PLACE   : Caltech
% DATES   : 06/30/2010 JMT From Siemens documentation
%           03/10/2011 JMT Update for function use
%           05/06/2011 JMT Correct preamble handling for ecg
%           05/08/2013 JMT Further generalization of ECG preamble
%                          New trigger handling with calibration
%           02/04/2016 JD  changed preamble handling
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

% Catch no arguments
if nargin < 1
  fprintf('USAGE: [d,t] = mpcu_parse(logname)\n');
  return
end

% Determine mode from file extension
[~, ~, mode] = fileparts(logfile);
mode(1) = [];

% Open selected file
fd = fopen(logfile,'r');
if fd < 0
  fprintf('Problem opening log file to read\n');
  return
end
% get first line
l=fgetl(fd);
lorig=l;
% close file
fclose(fd);

% find 5002 & 6002 (beginning/end logging message)
while 1
    startMsg=strfind(l,'5002 ');
    endMsg=strfind(l,' 6002 ');
    if isempty(startMsg) || isempty(endMsg),
        break
    end
    endMsg=endMsg+6;
    l = [l(1:startMsg(1)-1) l(endMsg(1):end)];
end

% read data stream
data = textscan(l, '%d');
data=data{1};

% chop final point (5003)
data(end) = [];
  
switch mode
    case 'ecg'
        % chop first 5
        data(1:5)=[];
    otherwise
        % chop first 4
        data(1:4)=[];
end

% Find MPCU detected on- and off-rhythm trigger marks
trigger_on_idx = find(data == 5000);
trigger_off_idx = find(data == 6000);

% Remove trigger marks from waveform
data(trigger_on_idx) = [];
data(trigger_off_idx) = [];

% Adjust mark indices to account for removal
trigger_on_idx = trigger_on_idx - (1:length(trigger_on_idx))';
trigger_off_idx = trigger_off_idx - (1:length(trigger_off_idx))';

% Sampling intervals (dwell times) for each channel in seconds
% Rates determined empirically against known timings
switch mode
    case {'ecg'}
        foundat=strfind(lorig,'ECG_SAMPLE_INTERVAL = ');
        if ~isempty(foundat),
            thisl=lorig((foundat+22):end);
            dt=textscan(thisl,'%d',1);
            mpcu.dt=double(dt{1})*1e-6;
        else
            mpcu.dt = 1.25e-3;
        end
  case {'ext'}
      foundat=strfind(lorig,'EXT_SAMPLE_INTERVAL = ');
      if ~isempty(foundat),
            thisl=lorig((foundat+22):end);
            dt=textscan(thisl,'%d',1);
            mpcu.dt=double(dt{1})*1e-6;
      else
          mpcu.dt = 5e-3;
      end
  case 'puls'
      foundat=strfind(lorig,'PULS_SAMPLE_INTERVAL = ');
      if ~isempty(foundat),
            thisl=lorig((foundat+23):end);
            dt=textscan(thisl,'%d',1);
            mpcu.dt=double(dt{1})*1e-6;
      else
          mpcu.dt = 20e-3;
      end
  case 'resp'
      foundat=strfind(lorig,'RESP_SAMPLE_INTERVAL = ');
      if ~isempty(foundat),
          thisl=lorig((foundat+23):end);
          dt=textscan(thisl,'%d',1);
          mpcu.dt=double(dt{1})*1e-6;
      else
          mpcu.dt = 20e-3;
      end
  otherwise
      mpcu.dt = 1;
end

fprintf('%s: Sampling period is %.6fs\n',mode,mpcu.dt);

% Time vector in seconds
mpcu.n = length(data);
mpcu.t = ((1:mpcu.n) - 1)' * mpcu.dt;

% Calibrate triggers in seconds after first sample
mpcu.trigger_on_idx  = trigger_on_idx;
mpcu.trigger_on      = trigger_on_idx * mpcu.dt;
mpcu.trigger_off_idx  = trigger_off_idx;
mpcu.trigger_off      = trigger_off_idx * mpcu.dt;

% Calculate median on-rhythm trigger interval (in seconds) and rate (Hz)
mpcu.trigger_interval = median(diff(mpcu.trigger_on));

% Save waveform
mpcu.mode = mode;
mpcu.data = data;
