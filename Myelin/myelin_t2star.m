function myelin_t2star
% Reconstruct multicompartment T2*, B0 and MWF maps from MEGE data
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 08/07/2012 JMT From scratch

% Read imaging data from SPGR and bSSFP
% Performs DICOM to Nifti conversion if necessary
% Data is read from .nii.gz file and parameter text file
[S,TE] = ute_load(ute_directory);