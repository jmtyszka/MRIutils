function [T1,S0,C,Mask] = srfitim(examdir,scanno,verbose)
% [T1,S0,C,Mask] = srfitim(examdir,scanno,verbose)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/13/2003 JMT From scratch. Use srfitn and srfit (JMT)
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

% Initialize return arguments
T1 = [];
S0 = [];
C  = [];
Mask = [];

if nargin < 2
  help srfitim
  return
end

% Verbosity flag
% 0 = no verbose output
% 1 = fit text results only
% 2 = fit text and graph
if nargin < 3 verbose = 0; end

if isempty(examdir) examdir = pwd; end

scandir = fullfile(examdir,num2str(scanno));
  
fprintf('Loading scan %d\n', scanno);

options.filttype = 'hamming';
options.fr = 0.5;
[ME,info,errmsg] = parxrecon(scandir,options);
  
if ~isempty(errmsg)
  fprintf(errmsg);
  return
end
  
fprintf('  TE      : %0.3f ms\n', info.te);
fprintf('  NEchoes : %d\n', info.nechoes);

% Construct echo time vector
nt = info.nechoes;
TE = (1:nt) * info.te;

% Fit T1 equation to the image stack
[S0, T1, C, Mask] = srfitn(TR, ME, verbose);
