function h = plot_TAbyT(data,cfg)

% function plot_TAbyT(data,cfg)
% plots single trials or frequencies in a time x amplitude plot using imagesc
%
% Mandatory Input:
% data         - m by n matrix (e.g., trials by timepoints)
%
%
% Optional [defaults]:
% cfg.xaxis    - vector of timepoints [1:size(data,2)]
% cfg.newfig   - if true opens new figure [true]
% cfg.clim     - color limits [maxmin]
% cfg.yaxis    - vector of y axis points [default: 1:size(data,1)]
% cfg.n_ytick  - number of ticks desired on y-axis. the start and end need
%                to be in the array (thus only taking equidistant arrays,
%                e.g., 2:2:14 can create 2, 3, 4, and 7 equidistant ticks)
% cfg.smooth   - numeric, smoothing iterations (interpolation)
% cfg.vline    - x-values for vertical lines [none]; can be further
%                specified in regard to color and width
%                using cfg.vline_style.color
%                and   cfg.vline_style.width
% cfg.colorbar - define (any value) if colorbar plotting intended
% cfg.fontsize - numeric, fontsize [14]
% cfg.yreverse - set to false, if increasing y-axis values are desired
% cfg.mask     - m by n matrix (same as data) used to mask, e.g.,
%                non-significant values, translates to the alpha level in
%                matlab (0 = completely transparent; 1 = no transparency)
% cfg.mask_int - 'nearest', 'linear', or 'spline' - way of interpolating
%                the mask field ['nearest']
%

% (c) P.Ruhnau, Email: mail(at)philipp-ruhnau.de, 2012
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

% version 20150205 - non-linear axes now possible
% version 20131202 - mask parameter added (transparency)
% version 20130808 - smoothing procedure changed, interpolation

%% definitions
if nargin < 2, cfg = []; end
% defaults
if ~isfield(cfg, 'newfig'); cfg.newfig = 1; end
if ~isfield(cfg, 'clim'); cfg.clim = [min(min(data)) max(max(data))]; end
% check whether caxis increases, otherwise crash
if ~isfield(cfg, 'xaxis'), cfg.xaxis = 1:size(data, 2); end
if isfield(cfg, 'xtime'), cfg.xaxis = cfg.xtime; warning('cfg.xtime field is deprecated and replaced by cfg.xaxis'); end
% if no caption for y axis, take number (of, e.g., trials)
if ~isfield(cfg, 'yaxis'), cfg.yaxis = 1:size(data,1); end
% if no value here, have y-axis direction normal (increasing)
if ~isfield(cfg, 'yreverse'), cfg.yreverse = true; end
% convert logicals to doubles (just in case)
if isfield(cfg, 'mask'), cfg.mask = double(cfg.mask); end
if isfield(cfg, 'fontsize'), fsize = cfg.fontsize; else fsize = 14; end
% check whether caxis increases, otherwise crash

% default number of tics
if ~isfield(cfg, 'n_ytick'),
  p_tick = find(mod(numel(cfg.yaxis)-1, 1:numel(cfg.yaxis))==0);
  % pick largest, smaller then 10 if possible
  if any(p_tick > 2 & p_tick < 10)
    ntick = p_tick(p_tick > 2 & p_tick<10);
    ntick = ntick(end);
  else % otherwise take the smallest
    ntick = p_tick(1);
  end
  
  % we estimated clearances not the ticks! plus 1
  cfg.n_ytick = ntick+1;
else
  % check whether the input works
  if mod(numel(cfg.yaxis)-1, cfg.n_ytick-1) ~= 0
    warning('your desired tick number doesn''t work with this function. adapting number of y-ticks')
    
    p_tick = find(mod(numel(cfg.yaxis)-1, 1:numel(cfg.yaxis))==0);
    
    cfg.n_ytick = p_tick(nearest(p_tick, cfg.n_ytick))+1;
    
    disp(['Adapting your y-tick number to ' num2str( cfg.n_ytick )])
  end
end



if cfg.newfig == 1
  h = figure;
else
  h = gcf;
end


%% smoothing
if isfield(cfg, 'smooth')
  % do smoothing now with interpolation
  plotData = interp2(data,cfg.smooth);
  if isfield(cfg, 'mask') % smooth also mask field if present
    if isfield(cfg, 'mask_int')
      maskData = interp2(cfg.mask,cfg.smooth, cfg.mask_int);
    else
      maskData = interp2(cfg.mask,cfg.smooth, 'nearest');
    end
  end
else
  plotData = data;
  if isfield(cfg, 'mask')
    maskData = cfg.mask;
  end
end

%% check whether y-axis is linear, if not adapt y-tick-labels
if any(round(diff(diff(cfg.yaxis)).*1e6)./1e6) % watch it in case you go small!
  % plotting the data without yaxis input (just uses bins)
  imagesc(cfg.xaxis,[],plotData);
  hold on;
  % set the color limit 
  caxis([cfg.clim])
  % get size of y-axis
  ySize = get(gca, 'YLim');
  % set equidistant points according to n_tick and y-axis size
  yTicks = ySize(1):diff(ySize)/(cfg.n_ytick-1):ySize(2);
  yTickLabels = cfg.yaxis(1:((numel(cfg.yaxis)-1)/(cfg.n_ytick-1)):end);
  % now first set tick position then tick label
  set(gca, 'Ytick', yTicks)
  set(gca,'YTickLabel',yTickLabels)
  
else % for linearly spaced y-axis just do this
  % plot data with yaxis input
  imagesc(cfg.xaxis,cfg.yaxis,plotData)
  hold on;
  % set the color limit 
  caxis([cfg.clim])
end

%% masking
if isfield(cfg, 'mask')
  % set alpha according to mask field
  alpha(maskData);
end

%% have Y-axis normal (increasing values, default)
if cfg.yreverse == true
  set(gca, 'YDir', 'normal')
end

%% vertical lines
if isfield(cfg, 'vline') % plot vertical lines
  vl = cfg.vline;
  % defaults for linecolors and -width
  if isfield(cfg, 'vline_style')
    if isfield(cfg.vline_style, 'color'); vl_col = cfg.vline_style.color; end
    if isfield(cfg.vline_style, 'width'); vl_width = cfg.vline_style.width; end
  end
  if ~exist('vl_col', 'var'), vl_col = repmat({'k'},1,numel(vl)); end
  if ~exist('vl_width', 'var'), vl_width = repmat(3,1,numel(vl)); end
  
  % find y limits and max (to correct) for lines
  y = ylim;
  ymax = max(abs(y));
  % initialize color (for white lines, workaround, no clue what the
  % problem is) - otherwise white lines are exported as dark blue (to
  % .eps files only) -- BAUSTELLE
  plot(repmat(vl(1),1,2),[y(1)-ymax/10 y(2)+ymax/10], 'color', [.9 .9 .9], 'lineWidth', vl_width(1)*9/10)
  
  for i = 1:numel(vl) % plot lines
    plot(repmat(vl(i),1,2),[y(1)-ymax/10 y(2)+ymax/10], 'color', vl_col{i}, 'lineWidth', vl_width(i))
  end
end

%% general plot definitions
set(gca,...
  'Box'          , 'on'     , ...
  'XColor'       , [0 0 0], ...
  'YColor'       , [0 0 0], ...
  'FontSize',         fsize,...
  'Layer'        , 'top');

set(gcf,...
  'Color'            , [1 1 1],...
  'PaperPositionMode', 'auto');

%% colorbar
if isfield(cfg, 'colorbar')
  if cfg.colorbar == 1
    colorbar
  end
end
