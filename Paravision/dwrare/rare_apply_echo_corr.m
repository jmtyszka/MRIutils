function k_corr = rare_apply_echo_corr(x, pars)
% Generate complex echo correction vector from optimization parameter
% vector. Always returns a complex value for each echo.
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

switch pars.corr_type
  case 'phase'
    phi = x;
    amp = ones(1,pars.etl);
  case 'complex'
    phi = x(1:pars.etl);
    amp = x((1:pars.etl)+pars.etl);
end

per_echo_corr = amp .* exp(1i * phi);

% Allocate phase correction volume
echo_corr = zeros(size(pars.k));

% Replicate current per-echo correction across whole k-space volume
% Use ky_order to handle phase encoding order
for ec = 1:pars.etl
  echo_corr(:,pars.ky_order(:,ec),:) = per_echo_corr(ec);
end

% Apply correction
k_corr = pars.k .* echo_corr;
