function parx2an(scandir)
% parx2an(scandir)
%
% Converts a 2D or 3D Paravision dataset to SPM Analyze 7.5 format.
% The resultsing hdr/img pair are written into the scan directory supplied.
% Handles bigendian, littleendian IMND or PvM Paravision data.
%
% ARGS:
% scandir = Paravision scan directory (contains imnd, method, acqp, etc)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/24/2004 JMT From scratch using parx tools (JMT)
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

% Function name
fname = 'parx2an';

% Default arguments
if nargin < 1; scandir = pwd; end

% Attempt to load Paravision dataset
[s,info] = parxload2dseq(scandir);

% Check for load error
if isempty(s) || isempty(info)
  fprintf('%s : No Paravision data loaded\n', fname);
  return
end

% Check for non 2D/3D imaging data
if info.ndim < 2 || info.ndim > 3
  fprintf('%s : Dataset dimensionality (%d) < 2 or > 3\n', fname, info.ndim);
  return
end

% Initialize Analyze header
hdr.vsize = info.vsize;

% Construct Analyze file name from <PatientID><Study><Scan>
fname = fullfile(scandir,sprintf('%s_%d_%d',info.id,info.studyno,info.scanno));
anwrite(fname,s,hdr);
