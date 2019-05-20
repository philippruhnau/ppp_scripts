function plot_TA(data, cfg)

% PLOT_TA(data, cfg) plots time-amplitude image
%
% mandatory input:
%
% data   - m by n array of datapoints (e.g., channels by datapoints)
%
% optional input [defaults]:
%
% cfg.ylim       - y-axis limits [maxabs]
% cfg.xaxis      - points for the x-axis [by default 1:size(data,2)]
% cfg.highlight  - m by 2 array for highlighted areas in ms
% cfg.vline      - x-values for vertical lines [none]; can be further
%                  specified in regard to color and width for each
%                  individual line using cfg.vline_style.color/width
% cfg.error_area - array same size of data containing variance measure to
%                  be plotted as shaded area around lines
% cfg.error_edge - set to 1 if you want edges around the area [0] sets
%                  dashed lines to where the error areas overlap (not
%                  visible with transparancy but essential when saving as
%                  vector graphic, eps)
% cfg.color      - cell array of colors per line (like {'k' 'c' 'y'}, 
%                  or colormap (m by 3 matrix) [[0 0 0] = black for all]
% cfg.linewidth  - linewidth [1 times channels]
% cfg.linestyle  - linestyle [{'-'} times channel]
% cfg.reverse    - if 1 reverses y-axis [0]
% cfg.newfig     - if 1 new figure window opens
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

% vers 20140629 - added smooth error bar area plotting (cfg.error_area)
% vers 20140626 - removed baseline and sR, now only xtime input (or points
% 1:length(data))

%% definitions
if nargin < 1, help plot_TA; return; end
if nargin < 2,                  cfg = []; end
if isfield(cfg, 'xtime'), cfg.xaxis = cfg.xtime; warning('cfg.xtime field is deprecated and replaced by cfg.xaxis'); end
if ~isfield(cfg, 'ylim'),  maxabs = max(abs(data(:))); cfg.ylim = [-maxabs maxabs]; end
if ~isfield(cfg, 'linewidth'),  cfg.linewidth(1:size(data,1)) = 1; end
if ~isfield(cfg, 'linestyle'),  cfg.linestyle(1:size(data,1)) = {'-'}; end
if ~isfield(cfg, 'reverse'),    cfg.reverse = 0; end
if ~isfield(cfg, 'newfig'), newfig = 1; else newfig = cfg.newfig; end
if ~isfield(cfg, 'xaxis'),
  xtime = 1:size(data,2);
else
  xtime = cfg.xaxis;
end

% convert color input to rgb triplets if not already
if ~isfield(cfg, 'color'),
  colors = repmat([0 0 0],size(data,1),1);
elseif iscell(cfg.color) % if colormap as input
  for i = 1:numel(cfg.color)
    % this is pretty cool
    colors(i,:) = bitget(find('krgybmcw'==cfg.color{i})-1,1:3);
  end
else
  colors = cfg.color;
end


%% plot definitions

if newfig
  figure;
end

hold on

%% actual plotting

%% grey highlights (far background...)
if isfield(cfg, 'highlight')
  yb = cfg.ylim;
  for iM = 1:size(cfg.highlight,1)
    fill([cfg.highlight(iM,1) cfg.highlight(iM,1) cfg.highlight(iM,2) cfg.highlight(iM,2)], [yb(1) yb(2) yb(2) yb(1)], [0.9 0.9 0.9], 'EdgeColor', 'none');
  end
end

%% standard error
if isfield(cfg, 'error_area')
  for iEr = 1:size(cfg.error_area, 1)
    se = cfg.error_area(iEr,:);
    se_col = colors(iEr,:);
    
    % create y edge of poligon
    % take higher edge first and then add lower edge flipped (cause it
    % takes successive points)
    eb_area = [data(iEr,:)+se fliplr(data(iEr,:)-se)]';
    % create x-vals in same order
    xvals = [xtime fliplr(xtime)]';
    
    % capture NaNs (not ideal because this draws 'over' the NaN area,
    % better to draw independent lines w error shades
    nanidx = isnan(eb_area);
    eb_area(nanidx) = [];
    xvals(nanidx) = [];
    
    % now fill areas around final curve (dunno, but patch seems to do the
    % same)
%               fill(xvals, eb_area, se_col, 'EdgeColor', 'none', 'FaceAlpha', .2)
    patch(xvals, eb_area, 1, 'FaceColor', se_col, 'EdgeColor', 'none', 'FaceAlpha', .2)
    
    if isfield(cfg, 'error_edge') && cfg.error_edge
      % Make nice edges around the patch. a little smaller and brighter than
      % main lines
      % inspired by Andreas Trier Poulsen (function mseb)
      plot(xtime,data(iEr,:)+se,'-','color',se_col+(1-se_col)*0.5);
      plot(xtime,data(iEr,:)-se,'-','color',se_col+(1-se_col)*0.5);
    end
  end
  
  if isfield(cfg, 'error_edge') && cfg.error_edge
    % plot edges again for eps plotting to get dashed lines in the overlap...
    % again inspired by Adreas Trier Poulsen
    for iEr = 1:size(cfg.error_area, 1)
      se = cfg.error_area(iEr,:);
      se_col = colors(iEr,:);
      plot(xtime,data(iEr,:)+se,'--','color',se_col+(1-se_col)*0.5);
      plot(xtime,data(iEr,:)-se,'--','color',se_col+(1-se_col)*0.5);
    end
  end
end

%% data lines (need to be plotted last to be 'on top' of errorbars)
for chans = 1:size(data,1)
  ERP(chans) = plot(xtime, data(chans,:), 'Color', colors(chans,:), 'LineWidth', cfg.linewidth(chans), 'LineStyle', cfg.linestyle{chans}); %#ok<AGROW>
end

%% vertical lines
if isfield(cfg, 'vline')
  vl = cfg.vline;
  % defaults for linecolors and -width
  if isfield(cfg, 'vline_style')
    if isfield(cfg.vline_style, 'color'); vl_col = cfg.vline_style.color; end
    if isfield(cfg.vline_style, 'width'); vl_width = cfg.vline_style.width; end
  end
  if ~exist('vl_col', 'var'), vl_col = repmat([0 0 0],numel(vl),1); end
  if ~exist('vl_width', 'var'), vl_width = repmat(2,1,numel(vl)); end
  
  for i = 1:numel(vl) % plot lines
    plot(repmat(vl(i),1,2),[cfg.ylim], 'color', vl_col(i,:), 'lineWidth', vl_width(i))
  end
end
%% default adjustments
set(gca,...
  'Box'          , 'off'     , ...
  'XColor'       , [0 0 0], ...
  'YColor'       , [0 0 0], ...
  'Layer'        , 'top');
set(gcf,...
  'Color'            , [1 1 1],...
  'PaperPositionMode', 'auto');

if cfg.reverse == 1, set(gca, 'YDir'         , 'reverse'); end


%% adjust axis if possible
if ~any(isnan(cfg.ylim)) && diff(cfg.ylim) ~= 0
  axis([xtime(1) xtime(end) cfg.ylim])
end


