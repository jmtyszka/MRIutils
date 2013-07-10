function [M0,T1,im] = IREPI

directory = 'D:/Data/981104.IREPI';
ncomps = 1;

[M0,T1,im] = IRfit(directory,ncomps);

% Nice display of results
colormap(gray);
for c = 1:ncomps
   subplot(3,ncomps,3*c-2), pcolor(ClampImage(M0(:,:,c),[0 1000])); shading flat; title('M0'); axis off;
   subplot(3,ncomps,3*c-1), pcolor(ClampImage(T1(:,:,c),[0 1500])); shading flat; title('T1'); axis off;
   subplot(3,ncomps,3*c)  , pcolor(im(:,:,1)); shading flat; title('Base Image'); axis off;
end

