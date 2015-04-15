function h = plot_errorbars(data, cfg)

% function h = plot_errorbars(cfg,data)
%
% plots error bars of different conditions
%
% mandatory input:
%
% data - either m by n matrix (condition x unit of observation) 
%        OR struct containing fields for the mean
%        (data.mean) and the variance measure (data.se)
%        if matrix, standard error is computed 
%
% optional input [default]:
%
% cfg.linewidth   - number [2]
% cfg.color       - color indicator or RGB triplet ['k']
% cfg.linestyle   - linestyle specifier ['-']
% cfg.marker      - marker specifier ['o']
% cfg.m_size      - marker size [8]
% cfg.m_edgecolor - marker edge color ['k']
% cfg.m_facecolor - marker fill color ['k']
% cfg.whisk_length  - error bar whisker length, between 0 and 1 [.1]
% cfg.newfig      - 1 for new figure window [1]

% 20150414 - new implementation, use plot function to create errorbars

% copyright (c), 2015, P. Ruhnau, email: mail(at)philipp-ruhnau.de, 2015-04-14
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

% defaults
if ~isfield(cfg, 'linewidth'), cfg.linewidth = 2; end
if ~isfield(cfg, 'color'), cfg.color = 'k'; end
if ~isfield(cfg, 'linestyle'), cfg.linestyle = '-'; end
if ~isfield(cfg, 'marker'), cfg.marker = 'o'; end
if ~isfield(cfg, 'm_edgecolor'), cfg.m_edgecolor = 'k'; end
if ~isfield(cfg, 'm_facecolor'), cfg.m_facecolor = 'k'; end
if ~isfield(cfg, 'm_size'), cfg.m_size = 8; end
if ~isfield(cfg, 'whisk_length'), cfg.whisk_length = .1; end
if ~isfield(cfg, 'newfig'), cfg.newfig = 1; end

if isstruct(data)
  meanData = data.mean;
  seData = data.se;
elseif isnumeric(data)
  % mean and standard error
  meanData = mean(data);
  seData = std(data)./sqrt(size(data,1));
else
  help plot_errorbars
  error('Wrong data format')
end

% make row vectors
meanData = meanData(:)';
seData = seData(:)';

%% start plotting
if cfg.newfig
 h= figure;
end
hold on;
% white background
set(gcf,...
  'Color'            , [1 1 1],...
  'PaperPositionMode', 'auto');

%% plot markers
plot(1:numel(meanData), meanData, ...
  cfg.marker, ...
  'MarkerSize', cfg.m_size,...
  'MarkerEdgeColor',cfg.m_edgecolor,...
  'MarkerFaceColor', cfg.m_facecolor)
%% plot line connecting markers
plot(1:numel(meanData), meanData, ...
     'LineStyle', cfg.linestyle,...
     'LineWidth', cfg.linewidth,...
     'Color', cfg.color);
%% plot error bar whiskers
seRange = [(meanData-seData)' (meanData+seData)'];
% first vertical lines
for i = 1:size(seRange,1)
  plot([i i], [seRange(i,:)],...
    'LineStyle', cfg.linestyle,...
     'LineWidth', cfg.linewidth,...
     'Color', cfg.color)
end

% now horizontal
wl = cfg.whisk_length;
for i = 1:size(seRange,1)
  %upper
  plot([i-wl i+wl], [seRange(i,1) seRange(i,1)],...
    'LineStyle', '-',...
    'LineWidth', cfg.linewidth,...
    'Color', cfg.color)
  %lower
  plot([i-wl i+wl], [seRange(i,2) seRange(i,2)],...
    'LineStyle', '-'  ,...
    'LineWidth', cfg.linewidth,...
    'Color', cfg.color)
end
