function eta2_p = anova_partial_eta2(table)
% Calculate partial eta-squared for an ANOVA
%
% ARGS:
% table = table structure returned by anova, anova2 and anovan
%
% RETURNS:
% eta2_p = partial eta-squared effect size
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 2011 JMT From scratch
%          2012 JMT Generalize for arbitrary ANOVA designs
%
% Copyright 2012 California Institute of Technology.
% All rights reserved.

% Table is organized into the follow rows:
% 1        Column headers
% 2 .. N-2 Factors/Interactions
% N-1      Error
% N        Total
%
% and the following columns:
% 1        Row headers
% 2        Sum-of-squares
% 3 ..     Other stuff

n_rows = size(table,1);
n_factors = n_rows - 3;

% Extract factor/interaction names (cell array)
factor_names = table((1:n_factors)+1,1);

% Sum-of-squares error term
SS_err = table{n_factors+2,2};

% Make space for partial etas
eta2_p = zeros(n_factors,1);

fprintf('\n');
fprintf('--------------------------------\n');
fprintf('Partial Eta-squared Effect Sizes\n');
fprintf('--------------------------------\n');

% Extract sums of squares for each factor/interaction
for fc = 1:n_factors
  
  SS = table{fc+1,2};
  
  eta2_p(fc) = SS / (SS + SS_err);
  
  fprintf('%30s : %0.3f\n', factor_names{fc}, eta2_p(fc));
  
end