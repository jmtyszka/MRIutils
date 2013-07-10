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
% Copyright 2005 California Institute of Technology.
% All rights reserved.

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