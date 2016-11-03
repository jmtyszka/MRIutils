function [dt,tstart,tend] = parxstudytime(studydir)
% [dt,tstart,tend] = parxstudytime(studydir)
%
% Calculate total time taken for a Paravision study
%
% RETURNS:
% dt = study duration in minutes
% tstart,tend = datenums for the start and end times of the study
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/27/2004 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
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

% Defaults
if nargin < 1; studydir = pwd; end

% Initialize start and end times
tstart = Inf;
tend = -Inf;
dt = Inf;
tend_dur = 0;

if ~exist(fullfile(studydir,'subject'),'file')
  return
end

% Get scan directory contents
d = dir(studydir);

for dc = 1:length(d)

  this_name = d(dc).name;
  
  if ~isequal(this_name,'.') && ~isequal(this_name,'..')
    
    this_path = fullfile(studydir,this_name);
    
    info = parxloadinfo(this_path);
    
    if isfield(info,'time')

      if isequal(info.time,'NULL')
        t0 = tend;
      else
        t0 = datenum(info.time);
      end
      
      if t0 < tstart; tstart = t0; end
      if t0 > tend
        
        % Update start time of final scan
        tend = t0;

        % Parse acqtime string (%dh%dm%ds%dms)
        [h,m,s] = parxacqtime(info.acqtime);
      
        % Convert to seconds and multiply by NR
        % This is the duration of the final scan in seconds
        tend_dur = (((h * 60) + m) * 60 + s) * info.nreps;
        
      end
      
    end
    
  end
    
end

% Add duration of final scan
tend = tend + tend_dur / (3600 * 24);

% Calculate scan duration in minutes
dt = round((tend - tstart) * (60 * 24));
        
