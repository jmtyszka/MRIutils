function sm = movmed(s,k)
% SYNTAX: sm = movmed(s,k)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/08/2007 JMT Rewrite from memory
%
% Copyright 2007 California Institute of Technology
% All rights reserved.

% Force row vector
s = s(:)';

% Get size and make space for filtered vector
n = length(s);
sm = zeros(size(s));

% Round up to next odd number
kk = fix(k/2)*2+1;
if kk ~= k
  fprintf('Rounding kernel size to %d\n',kk);
end

% Half-size of filter
hk = fix(kk/2);

for xc = 1:n
  
  % Start and end points of kernel
  m0 = xc-hk;
  m1 = xc+hk;

  % Clamp to vector limits
  if m0 < 1; m0 = 1; end
  if m1 > n; m1 = n; end
  
  % Add median of kernel to return vector
  sm(xc) = median(s(m0:m1));
  
end