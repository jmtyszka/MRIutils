function [T1,S0,Mask] = srfitseries(examdir,scannos,verbose)
% [T1,S0,Mask] = srfitseries(examdir,scannos)
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

if nargin < 2
  help srfitseries
  return
end

% Verbosity flag
% 0 = no verbose output
% 1 = fit text results only
% 2 = fit text and graph
if nargin < 3 verbose = 0; end

if isempty(examdir) examdir = pwd; end

nt = length(scannos);
TR = zeros(1,nt);

for tc = 1:nt
  
  this_scan = fullfile(examdir,num2str(scannos(tc)));
  
  fprintf('Image %d (scan %d)\n', tc, scannos(tc));

  options.filttype = 'hamming';
  options.fr = 0.5;
  [s,info,errmsg] = parxrecon(this_scan,options);
  
  if ~isempty(errmsg)
    fprintf(errmsg);
    return
  end
  
  if tc == 1
    
    [nx,ny,nz] = size(s);
    SR = zeros(nx,ny,nz,nt);
    
  end
  
  SR(:,:,:,tc) = s;
  TR(tc) = info.tr;
  
  fprintf('  TR = %0.3f ms\n', info.tr);

end

% Fit SR equation to the image stack
[S0, T1, Mask] = srfitn(TR, SR, verbose);
