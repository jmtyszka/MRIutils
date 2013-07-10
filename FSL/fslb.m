function fslb(fsldir,bvals,bvecs,suffix)
% fslb(fsldir,bvals,bvecs,suffix)
%
% Write bvals and bvecs text files for FSL FDT processing
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/28/2006 JMT Extract from dsifsl.m (JMT)
%          07/21/2008 JMT Add suffix
%
% Copyright 2006 California Institute of Technology.
% All rights reserved.

if nargin < 4; suffix = ''; end

%-----------------------------------------------------
% Write bvals text file to DWI directory
%-----------------------------------------------------

fd = fopen(fullfile(fsldir,['bvals' suffix]),'w');
if fd < 0
  fprintf('Problem opening bvals file\n');
  return
end

fprintf(fd,'%0.4f ',bvals); fprintf(fd,'\n');

% Close bvals file
fclose(fd);

%-----------------------------------------------------
% Write bvecs text file to DWI directory
%-----------------------------------------------------

fd = fopen(fullfile(fsldir,['bvecs' suffix]),'w');
if fd < 0
  fprintf('Problem opening bvecs file\n');
  return
end

fprintf(fd,'%0.4f ',bvecs(:,1)); fprintf(fd,'\n');
fprintf(fd,'%0.4f ',bvecs(:,2)); fprintf(fd,'\n');
fprintf(fd,'%0.4f ',bvecs(:,3)); fprintf(fd,'\n');

% Close bvals file
fclose(fd);