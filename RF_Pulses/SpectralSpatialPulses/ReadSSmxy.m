function [mx,my,mz] = ReadSSmxy(dirname, name, nf, nx)

mxyfile = sprintf('%s/%s.mxy', dirname, name);

% Read in Mxy data
fd = fopen(mxyfile,'r');
mxy = fscanf(fd, '%f', [7, Inf]);
fclose(fd);

% Extract magnetization components
mx = reshape(mxy(1,:),nf,nx);
my = reshape(mxy(2,:),nf,nx);
mz = reshape(mxy(3,:),nf,nx);