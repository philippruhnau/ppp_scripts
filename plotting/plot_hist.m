function h = plot_hist(data, cfg)

% PLOT_HIST(data,cfg)
% plots (overlapping) histogram(s)
%
% mandatory input:
%
% data - m by n matrix containing to be plotted data, each column gets
%        their own histogramm (so n hist on top of each other, this is only
%        useful for 2 histograms or so)
%
% optional input [default]:
%
% cfg.nbin        - number of histogram bins [10]
% cfg.color       - color indicator ('k'/'b' etc.) or RGB triplet [0 0 1]
% cfg.alpha       - face alpha of histogram group [0.5 1];
% cfg.edge_color  - bar edge color [matlab default]
% cfg.newfig      - 1 for new figure window [1]
% ------------------------------------------------------------------------- 

% 20160323 - new implementation

% copyright (c), 2016, P. Ruhnau, email: mail(at)philipp-ruhnau.de, 2016-03-18
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

%% defaults
if nargin < 2, cfg = struct; end
if ~isfield(cfg, 'alpha'), cfg.alpha = linspace(.5, 1, size(data,2)); end 
if ~isfield(cfg, 'newfig'), cfg.newfig = 1; end
if ~isfield(cfg, 'nbin'), cfg.nbin = 10; end

% convert color input to rgb triplets if not already
if ~isfield(cfg, 'color'), 
  % default is blue (old matlab)
  cfg.color = repmat([0 0 1],size(data,2),1);
elseif iscell(cfg.color) % if colormap as input
  % replace color field with rgb triplets
  tc = cfg.color;
  cfg = rmfield(cfg, 'color');
  for i = 1:numel(tc)
    % this is pretty cool
    cfg.color(i,:) = bitget(find('krgybmcw' == tc{i})-1 ,1:3);
  end
end

%% start plotting
if cfg.newfig
 h = figure;
end

hold on;
% white background
set(gcf,...
  'Color'            , [1 1 1],...
  'PaperPositionMode', 'auto');

%% histogram(s)

for i = 1:size(data,2)
  hist(data(:,i), cfg.nbin);  
end

%% change color aspects 
% find the histograms
h = findobj(gca,'Type','patch');

for i = 1:size(data,2)
  h(i).FaceAlpha = cfg.alpha(i);
  h(i).FaceColor = cfg.color(i,:);
  if isfield(cfg, 'edge_color')
    h(i).EdgeColor = cfg.edge_color(i,:);
  end
end

