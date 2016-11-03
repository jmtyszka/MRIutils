function fslb(fsldir,bvals,bvecs,suffix)
% fslb(fsldir,bvals,bvecs,suffix)
%
% Write bvals and bvecs text files for FSL FDT processing
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/28/2006 JMT Extract from dsifsl.m (JMT)
%          07/21/2008 JMT Add suffix
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

if nargin < 4; suffix = ''; end

%-----------------------------------------------------
% Write bvals text file to DWI directory
%-----------------------------------------------------

fd = fopen(fullfile(fsldir,['bvals' suffix]),'w');
if fd < 0
  fprintf('Problem opening bvals file\n');
  return
end

fprintf(fd,'%0.4f ',bvals); fprintf(fd,'\n');

% Close bvals file
fclose(fd);

%-----------------------------------------------------
% Write bvecs text file to DWI directory
%-----------------------------------------------------

fd = fopen(fullfile(fsldir,['bvecs' suffix]),'w');
if fd < 0
  fprintf('Problem opening bvecs file\n');
  return
end

fprintf(fd,'%0.4f ',bvecs(:,1)); fprintf(fd,'\n');
fprintf(fd,'%0.4f ',bvecs(:,2)); fprintf(fd,'\n');
fprintf(fd,'%0.4f ',bvecs(:,3)); fprintf(fd,'\n');

% Close bvals file
fclose(fd);
