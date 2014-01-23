function [TIopt, TRopt] = IRBestContrast(bright_T1rng, dark_T1rng)
% Optimize TI and TR in an IR sequence for maximum contrast
%
% T1 ranegs are provided for tissues targetted to be bright and dark in the
% final IR-SE or IR-GE image. Sequence is assumed to
% Inv-TI-90-[180]-Echo-TD, where TR = TI + TD
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  :2014-01-16 JMT From scratch
%
% Copyright 2014 California Institute of Technology.
% All rights reserved.

bright_T1rng = [min(bright_T1rng(:)) max(bright_T1rng(:))];
dark_T1rng = [min(dark_T1rng(:)) max(dark_T1rng(:))];

% Number of samples per dimension
n = 256;

% Vector of TIs in ms
TI = linspace(0, 500, n);

% Vector of TDs in ms
TD = linspace(0, 500, n+1);

% T1 vectors
bright_T1 = linspace(bright_T1rng(1), bright_T1rng(2), n+2);
dark_T1   = linspace(dark_T1rng(1), dark_T1rng(2), n+2);

% Calculate mean signal for each tissue over TD and TI ranges
bright_mean = mean_signal(TI, TD, bright_T1);
dark_mean   = mean_signal(TI, TD, dark_T1);

% Bright/Dark tissue signal ratio
s_ratio = log10(bright_mean ./ (dark_mean + eps));

% Plot results

subplot(221), imagesc(TI, TD, bright_mean, [0 1]); axis xy equal; colorbar;
xlabel('TD (ms)');
ylabel('TI (ms)');
title(sprintf('Bright Mean : T_1 = [%d, %d]', bright_T1rng));

subplot(222), imagesc(TI, TD, dark_mean, [0 1]); axis xy equal; colorbar;
xlabel('TD (ms)');
ylabel('TI (ms)');
title(sprintf('Dark Mean : T_1 = [%d, %d]', dark_T1rng));

subplot(223), imagesc(TI, TD, s_ratio); axis xy equal; colorbar;
xlabel('TD (ms)');
ylabel('TI (ms)');
title('Log ratio');

% Get one point from the ratio image
P = ginput(1);

TD = P(1);
TI = P(2);
T1 = 0:4000;
Mz = IRShortTR_Contrast(T1, TI, TD);

subplot(224), plot(T1, abs(Mz));
xlabel('T1 (ms)');
ylabel('|Mz(T1)|');
title(sprintf('|Mz| for (TI, TR) = (%0.1f, %0.1f)', TI, TI+TD));

function ms = mean_signal(TI, TD, T1)

% Create 3D mesh of TI, TD and T1 for bright and dark tissues
[TIm, TDm, T1m] = ndgrid(TI, TD, T1);

% Note argument order
s = abs(IRShortTR_Contrast(T1m, TIm, TDm));

% Calculate mean signal over T1 (3rd dimension)
ms = mean(s,3);
