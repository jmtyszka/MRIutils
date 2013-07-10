function [cohen_d, desc] = eta2_to_cohen_d(eta2)

% Convert eta2 to cohen's d.
%
% ARGS :
% eta2 = percent variance explained from ANOVA result (see anova_eta2.m)
%
% RETURNS :
% cohen_d : Cohen's d effect size
% desc    : Adjective associated with d 
%
% AUTHORS : Dan Kennedy and Mike Tyszka
% PLACE  : Caltech
% DATES  : 05/01/2012 From scratch
%          05/01/2012 Added descriptive return
%          
% Copyright 2012 California Institute of Technology
% All rights reserved.

cohen_d = 2*sqrt(eta2/(1-eta2));

% Adjective for effect size
% < 0.2      'negligible'
% 0.2 .. 0.5 'small'
% 0.5 .. 0.8 'medium'
% > 0.8      'large     

desc = 'negligible';

if cohen_d >= 0.2
  desc = 'small';
end

if cohen_d >= 0.5
  desc = 'medium';
end

if cohen_d >= 0.8
  desc = 'large';
end

