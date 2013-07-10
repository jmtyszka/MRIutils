function acqmeth = parxacqmeth(scandir)
% acqmeth = parxacqmeth(scandir)
%
% Determine acquisition method type (IMND or PvM) from
% the presence or absence of imnd or method files
%
% RETURNS:
% acqmeth = 'imnd' or 'pvm'
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/03/2003 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2004-2006 California Institute of Technology.
% All rights reserved.

if nargin < 1; scandir = pwd; end

acqmeth = 'none';

if exist(fullfile(scandir,'imnd'),'file')
  acqmeth = 'imnd';
end

if exist(fullfile(scandir,'method'),'file')
  acqmeth = 'pvm';
end
