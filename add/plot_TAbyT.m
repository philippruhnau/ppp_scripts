function plot_TAbyT(data,cfg)

% function plot_TAbyT(data,cfg)
% plots single trials or frequencies in time x amplitude using imagesc
%
% Mandatory Input:
% data         - m by n matrix (e.g., trials by timepoints)
%
% either the first two or the second needs to be present
% cfg.sr       - sampling rate (used for x-axis calculation)
% cfg.baseline - baseline (used for x-axis calculation)
% OR
% cfg.xtime    - vector of timepoints [calculated from data-length, sr and baseline]
%
%
% Optional [defaults]:
% cfg.clim     - color limits [maxmin]
% cfg.yaxis    - vector of y axis points [default: 1:size(data,1)
% cfg.smooth   - numeric, smoothing iterations (interpolation)
% cfg.vline    - x-values for vertical lines [none]; can be further
%                specified in regard to color and width (see lines 58-71)
%                using cfg.vline_style.color/width
% cfg.colorbar - define (any value) if colorbar plotting intended 
% cfg.yreverse - set to false, if increasing y-axis values are desired 
%

% P.Ruhnau, Email: philipp_ruhnau@yahoo.de, 2012-05-08
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
% version 20130808 - smoothing procedure changed, iterpolation
                                          
if ~isfield(cfg, 'clim'); cfg.clim = [min(min(data)) max(max(data))]; end

if ~isfield(cfg, 'xtime'),
    sR = cfg.sr;
    bl = cfg.baseline;
    cfg.xtime = -abs(bl):1000/sR:ceil(size(data,2)*1000/sR)-abs(bl)-1;
end
% if no caption for y axis, take number (of, e.g., trials)
if ~isfield(cfg, 'yaxis'), cfg.yaxis = 1:size(data,1); end
% if no value here, have y-axis direction normal (increasing)
if ~isfield(cfg, 'yreverse'), cfg.yreverse = true; end

figure;
% general plot definitions
set(gca,...
    'Box'          , 'off'     , ...
    'XColor'       , [0 0 0], ...
    'YColor'       , [0 0 0], ...
    'FontSize',         14,...
    'Layer'        , 'top');

set(gcf,...
    'Color'            , [1 1 1],...
    'PaperPositionMode', 'auto');


% smoothing
if isfield(cfg, 'smooth')
    %% do smoothing now with interpolation
    plotData = interp2(data,cfg.smooth);
    
else
    plotData = data;
end

% plotting the data
imagesc(cfg.xtime,cfg.yaxis,plotData, [cfg.clim])
hold on;

% have Y-axis normal (increasing values, default)
if cfg.yreverse == true
set(gca, 'YDir', 'normal')
end

if isfield(cfg, 'vline') % plot vertical lines
    vl = cfg.vline;
    % defaults for linecolors and -width
    if isfield(cfg, 'vline_style')
        if isfield(cfg.vline_style, 'color'); vl_col = cfg.vline_style.color; end
        if isfield(cfg.vline_style, 'width'); vl_width = cfg.vline_style.width; end
    end
    if ~exist('vl_col', 'var'), vl_col = repmat({'k'},1,numel(vl)); end
    if ~exist('vl_width', 'var'), vl_width = repmat(3,1,numel(vl)); end
    
    % initialize color (for white lines, workaround, no clue what the
    % problem is) - otherwise white lines are exported as dark blue (to
    % .eps files only) -- BAUSTELLE
     plot(repmat(vl(1),1,2),[max(cfg.yaxis)+0.5 0.5], 'color', [.9 .9 .9], 'lineWidth', vl_width(1)*9/10)
     
    for i = 1:numel(vl) % plot lines
        plot(repmat(vl(i),1,2),[max(cfg.yaxis)+0.5 0.5], 'color', vl_col{i}, 'lineWidth', vl_width(i))
    end
end


if isfield(cfg, 'colorbar') 
    if cfg.colorbar == 1
    colorbar
    end
end