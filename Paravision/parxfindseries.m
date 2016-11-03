function serlist = parxfindseries(methname, dataroot, subdir, serlist)
% serlist = parxfindseries(methname, dataroot, subdir, serlist)
%
% Return a structure array of the all datasets
% in the directory tree below dataroot with a given method.
% The tree is searched recursively using this function.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/24/2000 JMT From scratch
%          03/01/2001 JMT Adapt for use in PC GUI
%          03/12/2001 JMT Adapt for general use
%          01/03/2002 JMT Change name to parxfindexams.m
%          01/10/2002 JMT Change name to parxfindseries.m
%          03/14/2003 JMT Add support for PvM methods
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

if nargin < 3; subdir = []; end
if nargin < 4; serlist = {}; end

% Flag to continue search in lower directories
KeepGoing = 1;

% Pointer to the last element of the list of PC data dirs
ptr = length(serlist);

% Construct current search directory path
if isempty(subdir)
  curdir = dataroot;
else
  curdir = fullfile(dataroot,subdir);
end

% Report current directory
fprintf('  %s\n', curdir);

% List of all entries in the current directory
dirlist = dir(curdir);

% Loop over all current directory entries
for d = 1:length(dirlist)
  
  this_name = dirlist(d).name;
  
  if ~isequal(this_name, '.') && ~isequal(this_name, '..')
    
    % Check if this file is an IMND text info file
    if isequal(this_name, 'imnd') || isequal(this_name, 'method')
      
      % Load the info from imnd and other aux files
      info = parxloadinfo(curdir);
      switch this_name
        case 'imnd'
          info = parxloadinfo(curdir);
        case 'method'
          info = pvmloadinfo(curdir);
      end

      % Only proceed if the IMND parsed ok
      if ~isequal(upper(info.name),'UNKNOWN')
        
        % Is the current method name the one we're looking for?
        if isequal(upper(info.method), upper(methname)) || isempty(methname)
                
          ptr = ptr + 1;
          
          serlist(ptr).id        = info.id;
          serlist(ptr).serno     = info.serno;
          serlist(ptr).name      = info.name;
          serlist(ptr).studyname = info.studyname;
          serlist(ptr).studyno   = info.studyno;
          serlist(ptr).ndim      = info.ndim;
          serlist(ptr).method    = upper(info.method);
          serlist(ptr).tr        = info.tr;
          serlist(ptr).te        = info.te;
          serlist(ptr).dim       = info.sampdim;
          serlist(ptr).fov       = info.fov;
          serlist(ptr).path      = curdir;
          serlist(ptr).slthick   = info.slthick;
          serlist(ptr).remarks   = info.remarks;

          % Construct time string yyyy-mm-dd_hh:mm:ss
          dn = parxdatenum(info.time);
          [yyyy,mo,dd,hh,mn,ss] = datevec(dn);
          serlist(ptr).time = sprintf('%04d/%02d/%02d %02d:%02d:%02d',yyyy,mo,dd,hh,mn,round(ss));          

          % Bottom out here
          KeepGoing = 0;
          
        end
        
      end
      
    end
    
    % Continue search into subdirectories
    if dirlist(d).isdir && KeepGoing
      if isempty(subdir)
        nextdir = this_name;
      else
        nextdir = fullfile(subdir,this_name);
      end
      serlist = parxfindseries(methname, dataroot, nextdir, serlist);
    end
    
  end
  
end
