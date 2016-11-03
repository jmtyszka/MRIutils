function [My,T1m,T2m,TRm,TEm,alpham,TIm] = mrcontrast(pseq,T1,T2,TR,TE,alpha,TI)
% [My,T1m,T2m,TRm,TEm,alpham,TIm] = mrcontrast(pseq,T1,T2,TR,TE,alpha,TI)
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

if nargin < 1 pseq = 'GE'; end
if nargin < 2 T1 = 2000; end
if nargin < 3 T2 = 20; end
if nargin < 4 TR = 500; end
if nargin < 5 TE = 10; end
if nargin < 6 alpha = 90; end
if nargin < 7 TI = 0; end

% Convert alpha to radians
alpha = alpha * pi / 180;

[T1m,T2m,TRm,TEm,alpham,TIm] = ndgrid(T1,T2,TR,TE,alpha,TI);

E1m = exp(-TRm ./ T1m);
E2m = exp(-TEm ./ T2m);

switch upper(pseq)
  
  case {'GE','GRE','FLASH','FISP','GRASS'}
    
    My = (1 - E1m) ./ (1 - cos(alpham) .* E1m) .* sin(alpham) .* E2m;
    
  case {'SE'}
    
    My = (1 - E1m) .* E2m;

  otherwise
    
    fprintf('Unkown pulse sequence\n');
    return
    
end

My = squeeze(My);
T1m = squeeze(T1m);
T2m = squeeze(T2m);
TRm = squeeze(TRm);
TEm = squeeze(TEm);
alpham = squeeze(alpham);
TIm = squeeze(TIm);
