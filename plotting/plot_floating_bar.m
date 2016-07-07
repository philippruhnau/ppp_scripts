function plot_floating_bar(data, cfg)

% PLOT_FLOATING_BAR(data, cfg)
% plots horizontal bar graphs with offset from y-axis (can be used to plot
% different time lines)
%
% mandatory input:
% data - n x 2 matrix with x1 and x2 (start and end x-coordinates of bar)
%
% optional input [default]:
% cfg.newfig    = set to 1 for new figure [1];
% cfg.color     = color of the individual bars in rgb triplets (matrix) or 
%                 matlab color letters in a cell array
% cfg.edgecolor = edge color ['none']
% cfg.ypos      = n by 2 y-axis upper and lower edges of the bars []

% copyright (c), 2016, P. Ruhnau, email: mail(at)philipp-ruhnau.de
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

% vers 20160706 - initial implementation

%% defaults
if nargin < 1, help plot_floating_bar; return; end
if nargin < 2,                  cfg = []; end
if ~isfield(cfg, 'newfig'), newfig = 1; else newfig = cfg.newfig; end
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
if isfield(cfg, 'ypos'), ydat = cfg.ypos; else ydat = []; end


if newfig
  figure;
end

hold on

%% get data and plot

if isempty(ydat)
  % create y coordinates based on rows
  ydat = [(1:size(data,1))-0.8; (1:size(data,1))-0.2]';
end

% plot row by row
for iB = 1:size(data,1)
  xdat = data(iB, :);
  yb = ydat(iB,:);
    fill([xdat(1) xdat(1) xdat(2) xdat(2)], [yb(1) yb(2) yb(2) yb(1)], colors(iB,:), 'EdgeColor', 'none');
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


