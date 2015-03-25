function stats = meeg_plot_ttest_tcourse(cfg)

% meeg_plot_ttest_tcourse(cfg)
%
% Input, e.g. (defaults):
%	cfg.data       = [] % channel x time x condition x subject
%	cfg.slwin      = 40; % sliding window in ms
%	cfg.overlap    = 30; % overlap in ms
%	cfg.multiplier = 1; % use it to multiply the data before analysis
%	cfg.type       = 'none'; % for averaging the channels apply transform: 'none', 'abs' or 'rms'
%	cfg.sfreq      = 500; % sampling frequency
%	cfg.alpha      = 0.05; % define alpha for t-statistic
%	cfg.contrasts  = [1 2; 3 4]; % contrasts for t-statistic (condition indices), e.g. [1 0] for condition1 vs. zero
%	cfg.con_names  = {'aoc'; 'amc'; 'goc'; 'goi'};
%	cfg.dcolor     = {'k'; 'g'; 'b'; 'r'}; % color for the data conditions
%	cfg.tcolor     = {'m'; 'c'}; % color for the t-contrasts
%	cfg.dylim      = [min max]; % y-limits for the data plot
%	cfg.tylim      = [min max]; % y-limits for the t-stats plot
%	cfg.xlabel     = 'time'; % label for the x-axis
%   cfg.time       = 1 by timepoints, x-axis
%	cfg.dylabel    = 'amplitude'; % y-label for data plot
%	cfg.tylabel    = 't-value'; % y-label for t-stats plot
%   cfg.cor_mode   = MCP correction method, either 'bonferroni' (default)
%                    or 'fdr'
%
% ------------------------------------------------------------------------------------------------
% This program plots t-statistic for time courses.
% copyright (c) 2010, Bjoern Herrmann, Email: bherrmann@cbs.mpg.de, 2010-06-02

% vers20140402 - added MCP correction mode (for fdr mainly)

% Load defaults if appropriate
% ----------------------------
fs = filesep;
if ~isfield(cfg, 'data'),       fprintf('Error: cfg.data needs to be defined.\n'); return; end
if ~isfield(cfg, 'sfreq'),  fprintf('Error: cfg.sfreq needs to be defined.\n'); return; end
if ~isfield(cfg, 'contrasts'),  fprintf('Error: cfg.contrasts needs to be defined.\n'); return; end
if ~isfield(cfg, 'time'),       cfg.time = 1:1000/cfg.sfreq:size(cfg.data,2)*1000/cfg.sfreq; end
if ~isfield(cfg, 'type'),       cfg.type = 'none'; end
if ~isfield(cfg, 'con_names'),  cfg.con_names(1:size(cfg.data,3)) = {'con'}; end
if ~isfield(cfg, 'dcolor'),     cfg.dcolor(1:size(cfg.data,3)) = {'k'}; end
if ~isfield(cfg, 'tcolor'),     cfg.tcolor(1:size(cfg.contrasts,1)) = {'g'}; end
if ~isfield(cfg, 'slwin'),      cfg.slwin = 40; end
if ~isfield(cfg, 'overlap'),    cfg.overlap = 30; end
if ~isfield(cfg, 'multiplier'), cfg.multiplier = 1; end
if ~isfield(cfg, 'alpha'),      cfg.alpha = 0.05; end
if ~isfield(cfg, 'xlabel'),     cfg.xlabel = 'time'; end
if ~isfield(cfg, 'dylabel'),    cfg.dylabel = 'amplitude'; end
if ~isfield(cfg, 'tylabel'),    cfg.tylabel = 't-value'; end
if ~isfield(cfg, 'cor_mode'),   cfg.cor_mode = 'bonferroni'; end

% Get average for the channels included
% -------------------------------------
for c = 1 : size(cfg.data,3)
    if strcmp(cfg.type, 'none')
        D(c,:,:) = mean(cfg.data(:,:,c,:), 1) * cfg.multiplier;
    elseif strcmp(cfg.type, 'abs')
        D(c,:,:) = mean(abs(cfg.data(:,:,c,:)), 1) * cfg.multiplier;
    elseif strcmp(cfg.type, 'rms')
        D(c,:,:) = sqrt(mean(cfg.data(:,:,c,:) .^ 2, 1)) * cfg.multiplier;
    end
end
Dm = mean(D,3);


% Plot time courses for all ROIs
% ------------------------------
figure;
set(gcf, 'Color', [1 1 1]);
hold on;
ROIp(1) = subplot(4, 1, 1);
title('data time courses');
hold on;
for c = 1 : size(Dm,1)
    plot(cfg.time, Dm(c,:), [cfg.dcolor{c} '-'], 'LineWidth', 2);
    hold on;
end
if ~isfield(cfg, 'dylim'), cfg.dylim = [-max(abs(Dm(:))) max(abs(Dm(:)))]; end
axis([cfg.time(1) cfg.time(end) cfg.dylim(1) cfg.dylim(2)]);
set(get(gca, 'YLabel'), 'String', cfg.dylabel);
legend(cfg.con_names);
hold off;


% Add a condition of zeros in case of contrasts against zero
% ----------------------------------------------------------
wzeros = cfg.contrasts == 0;
if find(wzeros == 1)
    D(end+1,:,:) = 0;
    cfg.contrasts(wzeros) = size(D,1);
end


% Get steps of the sliding window
% -------------------------------
ROIp(2) = subplot(4, 1, 2);
title('t-statistic');
hold on;
steps = round((cfg.sfreq / 1000 * cfg.slwin) - (cfg.sfreq / 1000 * cfg.overlap));
steps_ms =  steps*1000/cfg.sfreq;
tmat = [];
ttim = [];
for c = 1 : size(cfg.contrasts,1)
    slwin_samp = [1 : round(cfg.sfreq / 1000 * cfg.slwin)];
    co = cfg.contrasts(c,:);
    i = 1;
    while slwin_samp(end) <= size(D,2)
        [h p ci stat] = ttest(mean(D(co(1),slwin_samp,:),2), mean(D(co(2),slwin_samp,:),2));
        tmat(c,i) = stat.tstat;
        pmat(c,i) = p;
        if i == 1
            ttim(i) = cfg.time(1) + cfg.slwin/2;
        else
            ttim(i) = ttim(i-1) + steps_ms;
        end
        
        slwin_samp = slwin_samp + steps;
        i = i + 1;
    end
    utcrit = abs(tinv(cfg.alpha/2, size(D,3)-1)); % two-tailed test
    btcrit = abs(tinv(cfg.alpha/2/length(ttim), size(D,3)-1)); % bonferroni
    
    plot(cfg.time, zeros(length(cfg.time),1), 'k', 'LineWidth', 2);
    plot(cfg.time, ones(length(cfg.time),1)* -utcrit, 'k--', 'LineWidth', 1);
    plot(cfg.time, ones(length(cfg.time),1)* utcrit, 'k--', 'LineWidth', 1);
    plot(cfg.time, ones(length(cfg.time),1)* -btcrit, 'k:', 'LineWidth', 1);
    plot(cfg.time, ones(length(cfg.time),1)* btcrit, 'k:', 'LineWidth', 1);
    plot(ttim, tmat(c,:), [cfg.tcolor{c} '-'], 'LineWidth', 2);
end
if ~isfield(cfg, 'tylim'), cfg.tylim = [-max(abs(tmat(:))) max(abs(tmat(:)))]; end
axis([cfg.time(1) cfg.time(end) cfg.tylim(1) cfg.tylim(2)]);
set(get(gca, 'YLabel'), 'String', cfg.tylabel);


% Get significant time points
% ---------------------------
utmat = double(tmat >= utcrit | tmat <= -utcrit);
btmat = double(tmat >= btcrit | tmat <= -btcrit);

% fdr
% ---
fdr_p = fdr(pmat, cfg.alpha);
fdrtcrit = abs(tinv(fdr_p, size(D,3)-1));
ftmat = double(abs(tmat) >= fdrtcrit);

% Plot significance boxes for each contrast (uncorrected p)
% ---------------------------------------------------------
ROIp(3) = subplot(4, 1, 3);
title(['uncorrected (p = ' num2str(cfg.alpha) ')']);
hold on;
vbox = (100 / (size(cfg.contrasts,1) + 1)) / 5;
for c = 1 : size(cfg.contrasts,1)
    vline = 100 - (100 / (size(cfg.contrasts,1) + 1)) * c;
    plot(cfg.time, ones(length(cfg.time),1)*vline, 'k', 'LineWidth', 2);
    
    preentry = NaN;
    found    = 0;
    for i = 1 : size(utmat,2)
        curentry = utmat(c,i);
        if curentry ~= 0 && curentry ~= preentry
            on_idx = i;
            found  = 1;
        elseif curentry == 0 && curentry ~= preentry && found == 1
            off_idx = i - 1;
            found   = 0;
            fill([ttim(on_idx) ttim(on_idx) ttim(off_idx) ttim(off_idx)],[vline-vbox vline+vbox vline+vbox vline-vbox], [cfg.tcolor{c} '-']);
            hold on;
        end
        preentry = curentry;
    end
    if found == 1
        off_idx = i - 1;
        fill([ttim(on_idx) ttim(on_idx) ttim(off_idx) ttim(off_idx)],[vline-vbox vline+vbox vline+vbox vline-vbox], [cfg.tcolor{c} '-']);
        hold on;
    end
end
axis([cfg.time(1) cfg.time(end) 0 100])
set(gca, 'YTickLabel', '');
set(gca, 'YTick', []);

if strcmp(cfg.cor_mode, 'bonferroni')
    % Plot significance boxes for each contrast (Bonferroni corrected p)
    % ------------------------------------------------------------------
    ROIp(4) = subplot(4, 1, 4);
    title(['Bonferroni corrected (p = ' num2str(cfg.alpha) ')']);
    hold on;
    vbox = (100 / (size(cfg.contrasts,1) + 1)) / 5;
    for c = 1 : size(cfg.contrasts,1)
        vline = 100 - (100 / (size(cfg.contrasts,1) + 1)) * c;
        plot(cfg.time, ones(length(cfg.time),1)*vline, 'k', 'LineWidth', 2);
        
        preentry = NaN;
        found    = 0;
        for i = 1 : size(btmat,2)
            curentry = btmat(c,i);
            if curentry ~= 0 && curentry ~= preentry
                on_idx = i;
                found  = 1;
            elseif curentry == 0 && curentry ~= preentry && found == 1
                off_idx = i - 1;
                found   = 0;
                fill([ttim(on_idx) ttim(on_idx) ttim(off_idx) ttim(off_idx)],[vline-vbox vline+vbox vline+vbox vline-vbox], [cfg.tcolor{c} '-']);
                hold on;
            end
            preentry = curentry;
        end
        if found == 1
            off_idx = i - 1;
            fill([ttim(on_idx) ttim(on_idx) ttim(off_idx) ttim(off_idx)],[vline-vbox vline+vbox vline+vbox vline-vbox], [cfg.tcolor{c} '-']);
            hold on;
        end
    end
    axis([cfg.time(1) cfg.time(end) 0 100])
    set(gca, 'YTickLabel', '');
    set(gca, 'YTick', []);
    set(get(gca, 'XLabel'), 'String', cfg.xlabel);
    
elseif strcmp(cfg.cor_mode, 'fdr')
    
    % Plot significance boxes for each contrast (fdr corrected p)
    % ------------------------------------------------------------------
    ROIp(4) = subplot(4, 1, 4);
    title(['FDR corrected (p = ' num2str(cfg.alpha) ')']);
    hold on;
    vbox = (100 / (size(cfg.contrasts,1) + 1)) / 5;
    for c = 1 : size(cfg.contrasts,1)
        vline = 100 - (100 / (size(cfg.contrasts,1) + 1)) * c;
        plot(cfg.time, ones(length(cfg.time),1)*vline, 'k', 'LineWidth', 2);
        
        preentry = NaN;
        found    = 0;
        for i = 1 : size(ftmat,2)
            curentry = ftmat(c,i);
            if curentry ~= 0 && curentry ~= preentry
                on_idx = i;
                found  = 1;
            elseif curentry == 0 && curentry ~= preentry && found == 1
                off_idx = i - 1;
                found   = 0;
                fill([ttim(on_idx) ttim(on_idx) ttim(off_idx) ttim(off_idx)],[vline-vbox vline+vbox vline+vbox vline-vbox], [cfg.tcolor{c} '-']);
                hold on;
            end
            preentry = curentry;
        end
        if found == 1
            off_idx = i - 1;
            fill([ttim(on_idx) ttim(on_idx) ttim(off_idx) ttim(off_idx)],[vline-vbox vline+vbox vline+vbox vline-vbox], [cfg.tcolor{c} '-']);
            hold on;
        end
    end
    axis([cfg.time(1) cfg.time(end) 0 100])
    set(gca, 'YTickLabel', '');
    set(gca, 'YTick', []);
    set(get(gca, 'XLabel'), 'String', cfg.xlabel);
    
end


% output
stats = struct;
stats.utcrit  = utcrit;
stats.btcrit  = btcrit;
stats.fdrtcrit = fdrtcrit;
stats.tvals = tmat;
stats.pvals = pmat;
stats.time = ttim;


return;



% fdr() - compute false detection rate mask
%
% Usage:
%   >> [p_fdr, p_masked] = fdr( pvals, alpha);
%
% Inputs:
%   pvals - vector or array of p-values
%   alpha - threshold value (non-corrected). If no alpha is given
%           each p-value is used as its own alpha and FDR corrected
%           array is returned.
%
% Outputs:
%   p_fdr    - pvalue used for threshold (based on independence
%              or positive dependence of measurements)
%   p_masked - p-value thresholded. Same size as pvals.
%
% Author: Arnaud Delorme, SCCN, 2008-
%         Based on a function by Tom Nichols
%
% See also: eeglab()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: fdr.m,v $
% Revision 1.3  2010/01/19 20:58:20  arno
% fix problem with very discontinous values
%
% Revision 1.2  2009/05/31 02:22:10  arno
% Adding FDR and bootstrap to all STUDY functions
%
% Revision 1.1  2008/05/06 22:32:52  arno
% Initial revision
%

function [pID, p_masked] = fdr(pvals, q)

p = sort(pvals(:));
V = length(p);
I = (1:V)';

cVID = 1;
cVN = sum(1./(1:V));

if nargin < 2
    pID = ones(size(pvals));
    thresholds = exp(linspace(log(0.1),log(0.000001), 100));
    for index = 1:length(thresholds)
        [tmp p_masked] = fdr(pvals, thresholds(index));
        pID(p_masked) = thresholds(index);
    end;
else
    pID = p(max(find(p<=I/V*q/cVID))); % standard FDR
    %pN = p(max(find(p<=I/V*q/cVN)));  % non-parametric FDR (not used)
end;
if isempty(pID), pID = 0; end;

if nargout > 1
    p_masked = pvals<=I/V*q/cVID;
end;


% find significant effects
function [numSign signif sSign] = find_p_FDR(results, p, pp)


numSign = max(find(round(p*1e10) == round(results.p*1e10)));
if numSign ~= 0
    signif = pp(numSign);
    sSign  = '=';
else
    numSign = length(find(round(p*1e10) > round(results.p*1e10)));
    if numSign == 0
        signif = 0.05;
        sSign  = '>';
    else
        signif = pp(numSign);
        sSign  = '<';
    end
end

