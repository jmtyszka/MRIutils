function [T1,S0,C,Mask] = t1fit_vtr(examdir,scanno,verbose)
% [T1,S0,C,Mask] = t1fit_vtr(examdir,scanno,verbose)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/13/2003 JMT From scratch. Use srfitn and srfit (JMT)
%          11/06/2007 JMT Update for PV4.0
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

if nargin < 2
  help t1fit_vtr
  return
end

% Initialize return arguments
T1 = [];
S0 = [];
C  = [];
Mask = [];

% Verbosity flag
% 0 = no verbose output
% 1 = fit text results only
% 2 = fit text and graph
if nargin < 3 verbose = 2; end

if isempty(examdir); examdir = pwd; end

fprintf('T1 Mapping : Pv4.0\n');
fprintf('--------------------------\n');
fprintf('AUTHOR: Mike Tyszka, Ph.D.\n');
fprintf('Copyright 2007 Caltech\n');

scandir = fullfile(examdir,num2str(scanno));
  
fprintf('Loading scan %d\n', scanno);

[VTR,info,errmsg] = parxload2dseq(scandir);
  
if ~isempty(errmsg)
  fprintf(errmsg);
  return
end

VTR = squeeze(VTR);

% Gauss filter image
gauss_fwhm = 1.0;
fprintf('Gauss filtering : FWHM = %0.1f\n',gauss_fwhm);
nvtr = size(VTR,3);
for ic = 1:nvtr
  VTR(:,:,ic) = gaussfilt2(VTR(:,:,ic),gauss_fwhm);
end

fprintf('TR : ');
fprintf('%0.0f ', info.trs);
fprintf('\n');

% Construct echo time vector
TR = info.trs;

% Start stopwatch
t0 = clock;

% Fit T2 equation to the image stack
[S0, T1, C, Mask] = srfitn(TR, VTR, verbose);

% Report calculation time
t = etime(clock,t0);
fprintf('Elapsed time : %0.1fs\n',t);

% Save results
fprintf('Saving results to T1_fit_results\n');
save T1_fit_results info S0 T1 C Mask

% Display results figure
figure(1); clf; colormap(flame);
subplot(121), imagesc(T1',robustrange(T1)); axis image off; title('T1 (ms)'); colorbar;
subplot(122), imagesc(S0',robustrange(S0)); axis image off; title('S0 (AU)'); colorbar;

fprintf('Printing figure to T1_fit_figure.png\n');
print('T1_fit_figure.png','-dpng','-r300');
