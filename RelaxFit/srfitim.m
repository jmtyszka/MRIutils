function [T1,S0,C,Mask] = srfitim(examdir,scanno,verbose)
% [T1,S0,C,Mask] = srfitim(examdir,scanno,verbose)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/13/2003 JMT From scratch. Use srfitn and srfit (JMT)
% Copyright 2004 California Institute of Technology.
% All rights reserved.

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