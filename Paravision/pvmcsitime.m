function pvmcsitime(studydir,scannos)
% pvmcsitime(studydir,scannos)
%
% Reconstruct and process a CSI time-course
% CSI data must be 2D spatial, 1D spectral
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/08/2004 JMT From scratch
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

% Number of time points
nt = length(scannos);

% Loop over time points
for sc = 1:nt
  
  this_sc = scannos(sc);
  
  fprintf('Scan %d\n', this_sc);
  
  scandir = fullfile(studydir,num2str(this_sc));
  
  % Load the data
  [s,info,imWater,imFat,sWater,sFat] = pvmcsirecon(scandir);
  clear s;
  
  if sc == 1

    % Initialize start time
    t0 = parxdatenum(info.time);

    % Initialize movie
    mov = avifile(sprintf('%s_%d.avi',info.id,info.studyno));
    
  end

  dt = parxdatenum(info.time) - t0;
  timestring = sprintf('Time +%s', datestr(dt,13));

  figure(1); colormap(gray); clf
  subplot(221), imagesc(imWater); axis equal off; title(timestring);
  subplot(222), imagesc(imFat); axis equal off;
  
  subplot(223), plot(sWater);
  axis tight
  set(gca,'YLim',[0 0.05]);
  title('Mean water spectrum');
  
  subplot(224), plot(sFat);
  axis tight
  set(gca,'YLim',[0 0.002]);
  title('Mean fat spectrum');
  
  % Grab this frame
  F = getframe(gcf);
  mov = addframe(mov,F);
  
end

% Close movie file
close(mov);
