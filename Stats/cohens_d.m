function d = cohens_d(x,y)
% Calculate Cohen's d effect size between two groups
%
% USAGE : d = cohens_d(x,y)
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 07/30/2011 JMT From scratch

% If x and y are matrices, d is calculated for each column
nx = size(x,1);
ny = size(y,1);

% Calculate mean over columns
mx = mean(x);
my = mean(y);
    
% var() normalizes by n-1
varx = var(x);
vary = var(y);

% Pooled sd
s = sqrt(((nx-1) * varx + (ny-1) * vary) / (nx + ny));

% Cohen's d for each column
d = (mx - my) ./ s;