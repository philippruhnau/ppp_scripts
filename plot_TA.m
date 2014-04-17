function plot_TA(data, sR, cfg)

% plot_TA(data, samplingRate, cfg) plots time-amplitude image
%
% mandatory input:
%
% data   - m by n array of datapoints (e.g., channels by datapoints)
%
% optional input [defaults]:
%
% sR     - sampling rate (used to compute x-axis)
% cfg.baseline  - baseline start-window in ms [0], negative value assumed
% cfg.ylim      - y-axis limits [maxabs]
% cfg.xtime     - timepoints for the x-axis [by default computed from data,
%                 sR and cfg.baseline]
% cfg.marker    - m by 2 array for highlighted areas in ms
% cfg.vline     - x-values for vertical lines [none]; can be further
%                 specified in regard to color and width for each
%                 individual line using cfg.vline_style.color/width
% cfg.color     - cell array of colors per line [{'k'} times channels]
% cfg.linewidth - linewidth [1 times channels]
% cfg.linestyle - linestyle [{'-'} times channel]
% cfg.reverse   - if 1 reverses y-axis [0]
% cfg.newfig    - if 1 new figure window opens
%

% copyright (c), 2011, P. Ruhnau, email: mail(at)philipp-ruhnau.de, 2011-08-03
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
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
%

%% definitions
if nargin < 1, help plot_TA; return; end
if ~exist('sR', 'var'), sR = 1000; end
if nargin < 3,                  cfg = []; end
if ~isfield(cfg, 'ylim'),  maxabs = max(abs(data(:))); cfg.ylim = [-maxabs maxabs]; end
if ~isfield(cfg, 'baseline'),    cfg.baseline = 0; end
if ~isfield(cfg, 'color'),      cfg.color(1:size(data,1)) = {'k'}; end
if ~isfield(cfg, 'linewidth'),  cfg.linewidth(1:size(data,1)) = 1; end
if ~isfield(cfg, 'linestyle'),  cfg.linestyle(1:size(data,1)) = {'-'}; end
if ~isfield(cfg, 'reverse'),    cfg.reverse = 0; end
if ~isfield(cfg, 'newfig'), newfig = 1; else newfig = cfg.newfig; end

if ~isfield(cfg, 'xtime'),
    xtime = -abs(cfg.baseline):1000/sR:ceil(size(data,2)*1000/sR)-abs(cfg.baseline)-1;
else
    xtime = cfg.xtime;
end

%% plot definitions

if newfig
    figure;
end
set(gca,...
    'Box'          , 'off'     , ...
    'XColor'       , [0 0 0], ...
    'YColor'       , [0 0 0], ...
    'Layer'        , 'top');
set(gcf,...
    'Color'            , [1 1 1],...
    'PaperPositionMode', 'auto');
if cfg.reverse == 1, set(gca, 'YDir'         , 'reverse'); end

hold on

%% actual plotting

% grey markers
if isfield(cfg, 'marker')
    yb = cfg.ylim;
    for iM = 1:size(cfg.marker,1)
        fill([cfg.marker(iM,1) cfg.marker(iM,1) cfg.marker(iM,2) cfg.marker(iM,2)], [yb(1) yb(2) yb(2) yb(1)], [0.9 0.9 0.9], 'EdgeColor', 'none');
    end
end

% vertical lines
if isfield(cfg, 'vline')
    vl = cfg.vline;
    % defaults for linecolors and -width
    if isfield(cfg, 'vline_style')
        if isfield(cfg.vline_style, 'color'); vl_col = cfg.vline_style.color; end
        if isfield(cfg.vline_style, 'width'); vl_width = cfg.vline_style.width; end
    end
    if ~exist('vl_col', 'var'), vl_col = repmat({'k'},1,numel(vl)); end
    if ~exist('vl_width', 'var'), vl_width = repmat(2,1,numel(vl)); end
    
    for i = 1:numel(vl) % plot lines
        plot(repmat(vl(i),1,2),[cfg.ylim], 'color', vl_col{i}, 'lineWidth', vl_width(i))
    end
end

% lines
for chans = 1:size(data,1)
    ERP(chans) = plot(xtime, data(chans,:), 'Color', cfg.color{chans}, 'LineWidth', cfg.linewidth(chans), 'LineStyle', cfg.linestyle{chans}); %#ok<AGROW>
end


axis([xtime(1) xtime(end) cfg.ylim])


