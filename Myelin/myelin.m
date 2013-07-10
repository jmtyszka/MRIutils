function myelin
% Reconstruct T1, T2 and MWF maps from mcDESPOT data
%
% - Requires multiple flip angle SPGR and bSSFP datasets
% - Implements Deoni 2005 and Deoni 2008 DESPOT and mcDESPOT methods
% - Hybrid GA-Simplex solver for 6D space with SPGR and bSSFP contrasts
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/22/2012 JMT Implement from Deoni 2005 and 2008 papers

% Read imaging data from SPGR and bSSFP
% Performs DICOM to Nifti conversion if necessary
% Data is read from .nii.gz file and parameter text file
mcDESPOT = mcDESPOT_read_data(mcDESPOT_directory);

% Global optimization by GA-Simplex
mcpars = mcDESPOT_fit_all(mcDESPOT);

% Save results

% Display results