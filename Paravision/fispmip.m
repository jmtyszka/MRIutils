function fispmip(fisp_scans)
% Maximum intensity projection addition of multiple FISP datasets
%
% ARGS:
% fisp_scans = scan numbers of FISP data (eg [2 4 5 8])
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : Caltech
% DATES : 10/13/2010 JMT From scratch
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

if nargin < 1
  fprintf('No FISP directories provided\n');
  return
end

nfisp = length(fisp_scans);

% Recon options
options.filttype = 'none';
options.fr = 0.47;
options.fw = 0.03;
options.zpad = 1;
options.fidw = 0;
options.bline = 1;

for dc = 1:nfisp

  fprintf('Reconstructing Scan %d\n', dc);
  
  scan_dir = num2str(fisp_scans(dc));
  
  info = parxloadinfo(scan_dir);
  if strcmp(info.method,'FISP')
    [s,info] = parxrecon(scan_dir,options); 
  else
    fprintf('*** Scan %d is not a FISP scan\n', dc);
    fprintf('*** Exiting\n');
    return
  end
   
  if dc == 1
    fisp = zeros([size(s) nfisp]);
  end
  
  fisp(:,:,:,dc) = s;
  
end

fprintf('MIPing FISP data\n');
mip = max(fisp,[],4);

% Construct basic transform matrix
mat0 = eye(4);
mat0(1:3,1:3) = diag(info.vsize(1:3));

mip_name = 'fispmip.nii.gz';
fprintf('Writing MIP to %s\n', mip_name);
save_nii(mip_name, mip, 'FLOAT32',mat0,mat0);

