function mpcu = mpcu_parse(logfile)
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
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : Caltech
% DATES : 06/30/2010 JMT From Siemens documentation
%         03/10/2011 JMT Update for function use
%         05/06/2011 JMT Correct preamble handling for ecg
%         05/08/2013 JMT Further generalization of ECG preamble
%                        New trigger handling with calibration
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

% Parse preamble
switch mode
  
  case 'ecg'
    
    % Skip through long form preamble
    % None of these fields is typically used for MRI postprocessing
    textscan(fd,'%d',6);
    textscan(fd,'%s %d %d %d',1);
    
    % Variable MSGTYPE groups
    keep_going = true;
    while keep_going
      
      % Read MSGTYPE string and message number
      msg = textscan(fd,'%s %d',1);
            
      switch msg{2}
        
        case 103
          
          % Message consists of two integers (6002 5002)
          textscan(fd,'%d',2);
          keep_going = true;
          
        case {104, 210}

          % Message consists of single integer (6002)
          textscan(fd,'%d',1);
          keep_going = false;

        case 220
          
          % Message consists of twelve strings ('eTriggerMethod:', etc)
          textscan(fd,'%s',12);
          keep_going = true;
          
        otherwise
          
          fprintf('Unkown message type : %d\n', msg{2});
          keep_going = false;
          
      end
      
    end
    
  otherwise
    
    % Skip through short form preamble
    d1 = textscan(fd,'%d', 4);
    
end

% Finally read data stream
data = textscan(fd, '%d');

% Extract first line and chop final point (5003)
data = data{1};
data(end) = [];
    
% Close log file
fclose(fd);

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
    mpcu.dt = 1.25e-3;
  case {'ext'}
    mpcu.dt = 5e-3;
  case {'puls','resp'}
    mpcu.dt = 20e-3;
  otherwise
    mpcu.dt = 1;
end

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
