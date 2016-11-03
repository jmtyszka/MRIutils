function mpcu_data = mpcu
% Demonstration of MPCU log parsing
%
% VERSION : 2.0
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 03/10/2011 JMT From scratch
%          05/08/2013 JMT Correct ECG header parsing and trigger handling
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

% Allow user to select one or more MPCU log files
[fname,dname] = uigetfile(...
  {'*.ecg;*.puls;*.resp;*.ext','MPCU log files'},...
  'Select log file(s)',...
  'Multiselect','On');

% Handle cancel
if isequal(dname,0) || isequal(fname,0)
  return
end

% Number of logfiles to parse and plot
if iscell(fname)
  nlogs = length(fname);
else
  nlogs = 1;
end

% Make space for waveforms
mpcu_data = cell(1,nlogs);

for lc = 1:nlogs
  
  % Handle multiple log files
  if nlogs == 1
    this_log = fname;
  else
    this_log = fname{lc};
  end
  
  fprintf('Parsing %s\n', this_log);
  
  % Parse waveform from file
  d = mpcu_parse(fullfile(dname,this_log));
  
  % Report waveform information
  fprintf('\n');
  fprintf('-------------------\n');
  fprintf('Mode              : %s\n', d.mode);
  fprintf('Sampling interval : %0.1f ms\n', d.dt * 1000);
  fprintf('Total samples     : %d\n', length(d.data));
  fprintf('Total time        : %0.3f s\n', d.n * d.dt);
  fprintf('Median interval   : %0.3f s\n', d.trigger_interval);
      
  % Add to plot figure
  subplot(nlogs,1,lc), plot(d.t, d.data);
  
  hold on
  plot(d.t(d.trigger_on_idx), 4500 * ones(size(d.trigger_on_idx)), 'r^');
  hold off
  
  set(gca,'YLim',[0 5000]);
  title(this_log);
  xlabel('Time (s)');
  
  % Save data in cell array
  mpcu_data{lc} = d;
  
end

