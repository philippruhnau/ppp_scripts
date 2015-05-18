function [twdata, sedata, singsubs] = plot_bargraph(cfg)

% PLOT_BARGRAPH(cfg) plots bar graph with standard error of the mean
% of specified time window(s) using either eeglab or preset input data
%
% mandatory Input:
%
% cfg.comp - grouping vector e.g.: [1 1 1 2 2 2] indicates
%            that the first three and the last three values
%            belong together and are plotted as a group
% 
% cfg.data.mean - vector of to be plotted mean values
% cfg.data.se   - to be plotted standard error (same size as mean), set to
%                 NaN if no plotting desired
%
% optional Input [default]:
%
% cfg.legend     - legend for bars ['none']
% cfg.fontsize   - font size [16]
% cfg.width      - bar width, [.9]
% cfg.linewidth  - edge line width [1]
% cfg.ylim       - y-axis limits, [absmax]
% cfg.xlim       - x-axis limits, [depends on data]
% cfg.ylabel     - ''
% cfg.xlabel     - ''
% cfg.eblength   - errorbar length [.1]
% cfg.color      - defines color of the bars as a colormap, e.g.
%                  [1 0 0; 0 1 0; 0 0 1] is red, green and blue;
%                  [default matlab color map]
% cfg.newfig     - 1 to open a new figure [1]
% cfg.reverse    - if exists, y-axis is reversed
% cfg.singsubs   - m by n array of condition by individual subject values. 
%                  will be plotted as stars in the bargraph
% ------------------------------------------------------------------------

% vers 20150425 - rebuild error bar plotting according to matlab figure
%                 handling. using the plot function instead of errorbar
% vers 20110801 - renamed plot_bargraph (formerly plot_eegbar)

% copyright (c), 2010, Philipp Ruhnau, e-mail: mail@philipp-ruhnau.de, 2011-08-04
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
if nargin < 1, help plot_bargraph; return; end
if nargin >1 
  error('!eeglab struct no longer supported, only taking cfg structure. check the help!');
end
if numel(cfg.comp) ~= numel(cfg.data.mean) 
  error('Grouping vector and data have a different number of elements')
end

if ~isfield(cfg,'fontsize'), cfg.fontsize = 16; end
if ~isfield(cfg, 'ylabel') , cfg.ylabel = ''; end
if ~isfield(cfg, 'xlabel'), cfg.xlabel = ''; end
if ~isfield(cfg, 'legend'), cfg.legend = 'none'; end
if ~isfield(cfg, 'eblength'), cfg.eblength = .1; end
if ~isfield(cfg, 'width'), cfg.width = .9; end
if ~isfield(cfg, 'linewidth'), cfg.linewidth = 1; end
if ~isfield(cfg, 'newfig'), cfg.newfig = 1; end

%% assign and reshape the data

twdata = cfg.data.mean;
sedata = cfg.data.se;

% sort after cfg.comp
[groups, ~, grp_indx] = unique(cfg.comp);

for iGroup = 1:numel(groups)
  tw_resort(iGroup,:) = twdata(grp_indx==iGroup)';
  se_resort(iGroup,:) = sedata(grp_indx==iGroup)';
end
twdata = tw_resort;
sedata = se_resort;

if isfield(cfg, 'singsubs')
  for iGroup = 1:numel(groups)
    for iSub = 1:size(cfg.singsubs,1)
      singsubs(iGroup,:,iSub) = cfg.singsubs(iSub,grp_indx==iGroup);
    end
  end
end

%% figure definitions

if cfg.newfig
  figure;
end
hold on;

% general settings
set(gcf,...
    'Color'            , [1 1 1],...
    'PaperPositionMode', 'auto');

% y-axis limit
if ~isfield(cfg, 'ylim'), 
  cfg.ylim = [-max(max(abs(twdata))) max(max(abs(twdata)))]; 
  set(gca, 'YLim', cfg.ylim)
end

set(gca,...
    'FontSize'     , cfg.fontsize,...
    'Box'          , 'off');

% x axis limits
if isfield(cfg, 'xlim')
    set(gca, 'XLim', cfg.xlim)
end
% reverse y-axis
if isfield(cfg, 'reverse')
    set(gca, 'YDir', 'reverse');
end

%% plot bars

if numel(unique(cfg.comp)) == 1 % if only one bar-group (e.g. cfg.comp =[1 1 1];)
    % not nice but no other idea to get even single comps in one
    % bar group, 
    % adding zeros as second bar group, which is not shown
    b = bar([twdata; zeros(1,numel(twdata))], cfg.width, 'LineWidth' , cfg.linewidth, 'ShowBaseLine', 'off');
    set(gca, 'XLim' , [0 numel(unique(cfg.comp))+1]);
    
else
    b = bar(twdata, cfg.width, 'LineWidth' , cfg.linewidth,'ShowBaseLine', 'off');
end

% labels and legend
xlabel(cfg.xlabel);
ylabel(cfg.ylabel);
if ~strcmp(cfg.legend, 'none')
    legend(b,cfg.legend)
end

%% plot errorbars 
% if any se value is NaN, no errorbar plotting (even though this is not flexible BAUSTELLE)
if ~any(isnan(sedata(:))) 
  for iB = 1:numel(b)

    % positions of bars
    xpos = b(iB).XData + b(iB).XOffset;
    % error range
    seRange = [(twdata(:,iB)-sedata(:,iB)) (twdata(:,iB)+sedata(:,iB))];
    % first plot vertical lines
    for i = 1:size(seRange,1)
      plot([xpos(i) xpos(i)], [seRange(i,:)],...
        'LineWidth', 1,...
        'Color', 'k')
    end
    % now horizontal
    wl = cfg.eblength/2; % length of whisker
    for i = 1:size(seRange,1)
      %upper
      plot([xpos(i)-wl xpos(i)+wl], [seRange(i,1) seRange(i,1)],...
        'LineWidth', 1,...
        'Color', 'k')
      %lower
      plot([xpos(i)-wl xpos(i)+wl], [seRange(i,2) seRange(i,2)],...
        'LineWidth', 1,...
        'Color', 'k')
    end
    
  end
  
end
%% something else 

% colormap
if ~isfield(cfg, 'color')
  set(gcf,'Colormap', 'default')
else
  set(gcf,'Colormap', cfg.color)
end

%% stars for single subjects

if isfield(cfg, 'singsubs')
    % catch case where there is only one bar per condition (i.e. flip to
    % fit ploting
    while size(singsubs(:,:,1)) ~= size(xCo) 
       xCo = reshape(xCo, size(singsubs(:,:,1)));
    end
    % loop tru
    for a = 1:size(xCo,1)
        for b = 1:size(xCo,2)
            plot(xCo(a,b),squeeze(singsubs(a,b,:))','k*')
        end
    end
end

