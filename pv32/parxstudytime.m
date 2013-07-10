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
% Copyright 2004-2006 California Institute of Technology.
% All rights reserved.

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
        
