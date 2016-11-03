function fsl2dt(fsldir,machine,swdest)
% fsl2dt(fsldir,machine,swdest)
%
% Convert FSL DTI volumes (dti_*.nii.gz) to six component Nifti-1 file
%
% ARGS:
% fsldir = directory containing dti_* files
% machine = 'siemens' or 'bruker'
% swdest = 'biotensor', 'dtiquery' or 'amira'
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech CBIC
% DATES  : 05/02/2006 JMT From scratch
%          09/26/2006 JMT Add ARGS section to comments
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
if nargin < 2; machine = 'siemens'; end
if nargin < 3; swdest = 'amira'; end

fprintf('\n');
fprintf('FSL to Diffusion Tensor Conversion\n');
fprintf('----------------------------------\n');
fprintf('Source machine type  : %s\n', machine);
fprintf('Software destination : %s\n', swdest);

% Directional flip vector
switch machine
  case 'siemens'
    flip = [1 1 1]';
  case 'bruker'
    flip = [-1 1 1]';
  otherwise
    flip = [1 1 1]';
end

% Read FSL output type from environment
fslouttype = getenv('FSLOUTPUTTYPE');
if isempty(fslouttype)
  fslouttype = 'NIFTI_GZ';
end
fprintf('FSL output type : %s\n', fslouttype);
switch fslouttype
  case 'NIFTI_GZ'
    fslext = '.nii.gz';
  case 'NIFTI'
    fslext = '.nii';
  otherwise
    fprintf('Unsupported image type : %s\n',fslouttype);
    return
end

fprintf('Directional flip     : [%d,%d,%d]\n',flip(1),flip(2),flip(3));

% Construct filefiles
L1file = fullfile(fsldir,['dti_L1' fslext]);
L2file = fullfile(fsldir,['dti_L2' fslext]);
L3file = fullfile(fsldir,['dti_L3' fslext]);
V1file = fullfile(fsldir,['dti_V1' fslext]);
V2file = fullfile(fsldir,['dti_V2' fslext]);
V3file = fullfile(fsldir,['dti_V3' fslext]);
Maskfile = fullfile(fsldir,['nodif_brain_mask' fslext]);

% Load the eigenvalues and eigenvectors
fprintf('Loading eigen images : ');
fprintf('L1 '); [L1,L1nii] = load_nii(L1file);
fprintf('L2 '); [L2,L2nii] = load_nii(L2file);
fprintf('L3 '); [L3,L3nii] = load_nii(L3file);
fprintf('V1 '); [V1,V1nii] = load_nii(V1file);
fprintf('V2 '); [V2,V2nii] = load_nii(V2file);
fprintf('V3 '); [V3,V3nii] = load_nii(V3file);
fprintf('Mask\n'); [Mask,Masknii] = load_nii(Maskfile);

% Grab data dimensions
dim = size(Mask);

% Create file array for DT
dat        = file_array;
dat.fname  = ['dt.nii'];
dat.dim    = [dim 6];
dat.dtype  = 'FLOAT32-LE';
dat.offset  = ceil(348/8)*8;

% Create the Nifti tensor image object
DT = nifti;

% Fill Nifti fields
DT.dat = dat;
DT.mat = L1nii.mat;
DT.mat_intent = L1nii.mat_intent;
DT.mat0 = L1nii.mat0;
DT.mat0_intent = L1nii.mat0_intent;
DT.descrip = 'Diffusion Tensor';

% Calculate the tensor elements Dxx Dyy Dzz Dxy Dxz Dyz
% Use D = lambdaV * inv(V)
% Where V = [v1 v2 v3]
% and lambdaV = [l1*v1 l2*v2 l3*v3]

DD = zeros([dim(1) dim(2) dim(3) 6]);

fprintf('Calculating tensor elements\n');

for zc = 1:dim(3)
  
  fprintf('Slice %d/%d\n',zc,dim(3));
  
  for yc = 1:dim(2)
    for xc = 1:dim(1)
      
      Mask_vox = Mask(xc,yc,zc);
      
      if Mask_vox > 0
      
        L1xyz = L1(xc,yc,zc);
        L2xyz = L2(xc,yc,zc);
        L3xyz = L3(xc,yc,zc);
        V1xyz = squeeze(V1(xc,yc,zc,:));
        V2xyz = squeeze(V2(xc,yc,zc,:));
        V3xyz = squeeze(V3(xc,yc,zc,:));

        % Apply directional flips
        V1xyz = V1xyz .* flip;
        V2xyz = V2xyz .* flip;
        V3xyz = V3xyz .* flip;
        
        % Invert characteristic equation to recover diffusion tensor
        V = [V1xyz V2xyz V3xyz];
        
        if isinf(cond(V)) % Check for zeroed eigenvectors
          D = eye(3);
        else
          lambdaV = [L1xyz*V1xyz L2xyz*V2xyz L3xyz*V3xyz];
          D = lambdaV * inv(V) * 1e3;
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
      
      % Compose tensor vector
      DDxyz = [Dxx Dxy Dxz Dyy Dyz Dzz];

      switch lower(swdest)
        case 'biotensor'
          % Convert from mm^2/s to um^2/ms for BioTensor
          DDxyz = DDxyz * 1e3;
        case 'dtiquery'
          % Convert from mm^2/s to um^2/s for DTIQuery
          DDxyz = DDxyz * 1e6;
        case 'amira'
          % Convert from mm^2/s to um^2/s for DTIQuery
          DDxyz = DDxyz;
      end
      
      % Order of components defined by 
      DD(xc,yc,zc,:) = DDxyz;
      
    end
  end
end

% Write scale
DT.cal = [min(DD(:)) max(DD(:))];

% Create the Nifti-1 header
create(DT);

% Finally write data to dt.nii.gz
dat(:,:,:,:) = DD;
