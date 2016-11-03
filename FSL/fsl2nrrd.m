function fsl2nrrd(fsldir)
% fsl2nrrd(fsldir)
%
% Convert FSL DTI volumes (dti_*.nii.gz) to BioTensor compatible
% tensor component 4D volume in NRRD format
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech CBIC
% DATES  : 03/01/2006 JMT From scratch
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

if nargin < 1; fsldir = pwd; end

% LR flip flag
dolrflip = 1;

% Construct filestubs
L1stub = fullfile(fsldir,'dti_L1');
L2stub = fullfile(fsldir,'dti_L2');
L3stub = fullfile(fsldir,'dti_L3');
V1stub = fullfile(fsldir,'dti_V1');
V2stub = fullfile(fsldir,'dti_V2');
V3stub = fullfile(fsldir,'dti_V3');
Mask = fullfile(fsldir,'nodif_brain_mask');

% Load the eigenvalues and eigenvectors
fprintf('Loading eigen images\n');
[L1,L1nii] = load_niigz(L1stub);
[L2,L2nii] = load_niigz(L2stub);
[L3,L3nii] = load_niigz(L3stub);
[V1,V1nii] = load_niigz(V1stub);
[V2,V2nii] = load_niigz(V2stub);
[V3,V3nii] = load_niigz(V3stub);
[Mask,Masknii] = load_niigz(Mask);

% Extract voxel size
% dx = Masknii.hdr.dime.pixdim(2);
% dy = Masknii.hdr.dime.pixdim(3);
% dz = Masknii.hdr.dime.pixdim(4);
dx = 1;
dy = 1;
dz = 1;

% Calculate the tensor elements Dxx Dxy Dxz Dyy Dyz Dzz
% Use D = lambdaV * inv(V)
% Where V = [v1 v2 v3]
% and lambdaV = [l1*v1 l2*v2 l3*v3]

[nx,ny,nz] = size(L1);

DD = zeros(7,nx,ny,nz);

fprintf('Calculating tensor elements\n');

for zc = 1:nz
  fprintf('.');
  for yc = 1:ny
    for xc = 1:nx
      
      Mask_vox = double(Mask(xc,yc,zc));
      
      if Mask_vox > 0
      
        L1xyz = double(L1(xc,yc,zc));
        L2xyz = double(L2(xc,yc,zc));
        L3xyz = double(L3(xc,yc,zc));

        V1xyz = double(squeeze(V1(xc,yc,zc,:)));
        V2xyz = double(squeeze(V2(xc,yc,zc,:)));
        V3xyz = double(squeeze(V3(xc,yc,zc,:)));

        % Apply RL flip if requested
        if dolrflip
          V1xyz(1) = -V1xyz(1);
          V2xyz(1) = -V2xyz(1);
          V3xyz(1) = -V3xyz(1);
        end
        
        % Invert characteristic equation to recover diffusion tensor
        V = [V1xyz V2xyz V3xyz];
        
        if isinf(cond(V)) % Check for zeroed eigenvectors
          D = eye(3);
        else
          lambdaV = [L1xyz*V1xyz L2xyz*V2xyz L3xyz*V3xyz];
          D = lambdaV * inv(V) * 1e3; % Convert from mm^2/s to um^2/ms for BioTensor
        end
        
      else
        
        D = eye(3);
        
      end
      
      Dxx = D(1,1);
      Dyy = D(2,2);
      Dzz = D(3,3);
      Dxy = D(1,2);
      Dxz = D(1,3);
      Dyz = D(2,3);
      
      % Order of components defined by NRRD header spec
      DD(:,xc,yc,zc) = [Mask_vox Dxx Dxy Dxz Dyy Dyz Dzz];
      
    end
  end
end

fprintf('\n');

% Export mask and diffusion tensor components to an NRRD format file
fprintf('Writing NRRD format tensor file\n');
fname = fullfile(fsldir,'tensor.nrrd');
dims = [nx ny nz];
vox = [dx dy dz];
dtiwritenrrd(fname,DD,dims,vox);

% Also export in single-precision format to tensor.mat
fprintf('Writing 4D tensor.mat\n');
fname = fullfile(fsldir,'tensor.mat');
sDD = single(DD);
save(fname,'sDD');
