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
