function stats = motion_analysis(moco_par_file, do_plot, do_report)
% Report statistics of FSL rigid body motion regression parameters
%
% ARGS:
% moco_par_file = filename of FSL motion parameter file
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/10/2012 JMT From scratch
%
% Copyright 2012 California Institute of Technology
% All rights reserved.

% Default arguments
if nargin < 1
  [fname, dname] = uigetfile('*.par','Select motion parameter file');
  if isequal(fname,0) || isequal(dname,0)
    return
  end
  moco_par_file = fullfile(dname, fname);
end

if nargin < 2; do_plot = true; end
if nargin < 3; do_report = true; end

% Load and parse file
C = textread(moco_par_file);

% Parse rotation (milliradians) and displacement (microns) columns
theta_x = C(:,1) * 1e3;
theta_y = C(:,2) * 1e3;
theta_z = C(:,3) * 1e3;

d_x = C(:,4) * 1e3;
d_y = C(:,5) * 1e3;
d_z = C(:,6) * 1e3;

% Total rotation angle at each time point in millidegrees
theta_total = total_rotation(theta_x, theta_y, theta_z);

% Total displacement in microns at each time point
d_total = sqrt(d_x.^2 + d_y.^2 + d_z.^2);

% Temporal differences
dd_x = [diff(d_x); 0];
dd_y = [diff(d_y); 0];
dd_z = [diff(d_z); 0];
dtheta_x = [diff(theta_x); 0];
dtheta_y = [diff(theta_y); 0];
dtheta_z = [diff(theta_z); 0];

% Total displacement difference
dd_total = sqrt(dd_x.^2 + dd_y.^2 + dd_z.^2);

% Total rotation difference
dtheta_total = total_rotation(dtheta_x, dtheta_y, dtheta_z);

% Summary statistics
stats.mean_d_total = mean(d_total);
stats.sd_d_total = std(d_total);
stats.max_d_total = max(d_total);
stats.mean_dd_total = mean(dd_total);
stats.sd_dd_total = std(dd_total);
stats.max_dd_total = max(dd_total);

stats.mean_theta_total = mean(theta_total) * 180/pi;
stats.sd_theta_total = std(theta_total) * 180/pi;
stats.max_theta_total = max(theta_total) * 180/pi;
stats.mean_dtheta_total = mean(dtheta_total) * 180/pi;
stats.sd_dtheta_total = std(dtheta_total) * 180/pi;
stats.max_dtheta_total = max(dtheta_total) * 180/pi;

%% Plot results

if do_plot
  
  figure(1), clf;
  
  t = 1:length(d_x);
  
  subplot(211), ax1 = plotyy(t, d_total, t, theta_total * 180/pi);
  
  set(get(ax1(1),'Ylabel'),'String','Total Displacement (um)')
  set(get(ax1(2),'Ylabel'),'String','Total Rotation (mdeg)')
  
  subplot(212), ax2 = plotyy(t, dd_total, t, dtheta_total * 180/pi);
  
  set(get(ax2(1),'Ylabel'),'String','Total Displacement Difference (um)')
  set(get(ax2(2),'Ylabel'),'String','Total Rotation Difference (mdeg)')
  
  drawnow
  
end

%% Write text report to command window

if do_report
  
  fprintf('Motion Analysis\n');
  fprintf('---------------\n');
  fprintf('MoCo file     : %s\n', moco_par_file);
  fprintf('Analysis Date : %s\n', datestr(now));
  fprintf('\n');
  
  fprintf('Total displacement : %0.3f (%0.3f) [ %0.3f - %0.3f ]\n', ...
    stats.mean_d_total, stats.sd_d_total, min(d_total), max(d_total));
  
  fprintf('F-F displacement   : %0.3f (%0.3f) [ %0.3f - %0.3f ]\n', ...
    stats.mean_dd_total, stats.sd_dd_total, min(dd_total), max(dd_total));
  
  fprintf('Total rotation     : %0.3f (%0.3f) [ %0.3f - %0.3f ]\n', ...
    stats.mean_theta_total, stats.sd_theta_total, min(theta_total), max(theta_total));
  
  fprintf('F-F rotation       : %0.3f (%0.3f) [ %0.3f - %0.3f ]\n', ...
    stats.mean_dtheta_total, stats.sd_dtheta_total, min(dtheta_total), max(dtheta_total));
  
  fprintf('---------------\n');
  fprintf('Displacements in microns\n');
  fprintf('Rotations in millidegrees\n');
  fprintf('Values quoted as mean (sd) [ min - max ]\n');
  
end

