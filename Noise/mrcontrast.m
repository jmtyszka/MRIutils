function [My,T1m,T2m,TRm,TEm,alpham,TIm] = mrcontrast(pseq,T1,T2,TR,TE,alpha,TI)
% [My,T1m,T2m,TRm,TEm,alpham,TIm] = mrcontrast(pseq,T1,T2,TR,TE,alpha,TI)

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
