function [hardi_scans, s0_scans, dwi_scans] = jmt_ddr_findscans(study_dir)
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

d = dir(study_dir);
nd = length(d);

hardi_scans = zeros(1,nd);
s0_scans = zeros(1,nd);
dwi_scans = zeros(1,nd);

hardi_count = 0;
dwi_count = 0;
s0_count = 0;

for dc = 1:length(d)
  
  fname = d(dc).name;
  
  % Convert directory/filename to a number if possible
  scan_no = str2double(fname);
  
  % Check for scan directory (number)
  if isnumeric(scan_no)
    
    info = parxloadinfo(fullfile(study_dir,fname));
    if ~isequal(info.name,'Unknown')
    
      if isequal(info.method,'jmt_ddr')
        
        if (info.ndim == 3) && (info.etl ~= info.sampdim(2))

          if info.bfactor > 0.0
            dwi_count = dwi_count + 1;
            dwi_scans(dwi_count) = scan_no;
          else
            s0_count = s0_count + 1;
            s0_scans(s0_count) = scan_no;
          end
          
        end
        
      end
      
    end
    
  end
  
end

% Clip unused elements
s0_scans = s0_scans(1:s0_count);
dwi_scans = dwi_scans(1:dwi_count);

% Sort scan lists
s0_scans = sort(s0_scans);
dwi_scans = sort(dwi_scans);
hardi_scans = sort([s0_scans dwi_scans]);
