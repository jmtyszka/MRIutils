function kspacesim
% kspacesim
%
% Simulate the raster acquisition of k-space and the resulting real-space
% MR image.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/18/2005 JMT From scratch
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

% Load axial T2 MRI
fprintf('Loading Axial T2 MRI\n');
s = double(mean(imread('AxT2.jpg'),3));

% Downsample to 128 wide
nx0 = 128;
[nx,ny] = size(s);
ar = nx/ny;
s = imresize(s,[ar * nx0 nx0],'bicubic'); 

% FFT Image
fprintf('FFTing Image\n');
k = fftshift(fftn(fftshift(s)));
maxk = max(abs(k(:)));

[nx,ny] = size(k);
ky = zeros(size(k));

figure(1); clf; colormap(gray);
set(gcf,'Position',[50 50 800 450]);

for xc = 1:nx
  
  ky(xc,:) = k(xc,:);
  sy = abs(fftshift(ifftn(fftshift(ky))));
  
  subplot(121), imagesc(log(abs(ky)+eps),[0 log(maxk)]); axis image off;
  title('k-space','fontsize',[20]);
  
  subplot(122), imagesc(sy); axis image off;
  title('Image space','fontsize',[20]);
  
  drawnow;
    
  % Add frame to movie
  mov(xc) = getframe(gcf);
  
end

% Write AVI movie
aviname = 'kspacesim.avi';
if exist(aviname,'file') delete(aviname); end
movie2avi(mov,aviname,...
  'compression','Indeo5',...
  'quality',90,...
  'fps',24);
