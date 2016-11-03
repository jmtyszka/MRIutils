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

% Read imaging data from SPGR and bSSFP
% Performs DICOM to Nifti conversion if necessary
% Data is read from .nii.gz file and parameter text file
mcDESPOT = mcDESPOT_read_data(mcDESPOT_directory);

% Global optimization by GA-Simplex
mcpars = mcDESPOT_fit_all(mcDESPOT);

% Save results

% Display results
