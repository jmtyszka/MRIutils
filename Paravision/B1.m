function B1est = B1(studydir, scans)
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

nscans = length(scans);

for sc = 1:nscans
  
  scandir = fullfile(studydir,num2str(scans(sc)));
  
  [s,info] = parxrecon(scandir);
  
  fprintf('Loading scan %d\n',scans(sc));
  fprintf('Dimensions: %d x %d x %d\n', info.sampdim(1), info.sampdim(2), info.sampdim(3));
  fprintf('A0: %0.1fdB\n', info.

  if sc == 1
    
    B1est = zeros([size(s) nscans]);
    
  end
  
  size(s)
  
  B1est(:,:,:,sc) = s;
  
end

% FFT pulse amplitude dimension
B1est = fft(B1est,[],4);


  
  
  
