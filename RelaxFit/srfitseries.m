function [T1,S0,Mask] = srfitseries(examdir,scannos,verbose)
% [T1,S0,Mask] = srfitseries(examdir,scannos)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/13/2003 JMT From scratch. Use srfitn and srfit (JMT)
% Copyright 2004 California Institute of Technology.
% All rights reserved.

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