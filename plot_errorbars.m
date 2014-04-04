function plot_errorbars(cfg,data)

% function plot_errorbars(cfg,data)
% plots error bars of different conditions
%
% mandatory input:
%
% data - either m by n matrix or struct containing fields for the mean
%        (data.mean) and the variation measure (data.se)
%      
% optional input [default]:
%
% cfg.linewidth   - number [2]
% cfg.color       - color indicator or RGB triplet ['k']
% cfg.linestyle   - linestyle specifier ['-'] 
% cfg.marker      - marker specifier ['o']
% cfg.m_edgecolor - marker edge color ['k']
% cfg.m_facecolor - marker fill color ['k']
% cfg.ebstretch   - error bar stretc ratio [2]



% defaults
if ~isfield(cfg, 'linewidth'), cfg.linewidth = 2; end
if ~isfield(cfg, 'color'), cfg.color = 'k'; end
if ~isfield(cfg, 'linestyle'), cfg.linestyle = '-'; end
if ~isfield(cfg, 'marker'), cfg.marker = 'o'; end
if ~isfield(cfg, 'm_edgecolor'), cfg.m_edgecolor = 'k'; end
if ~isfield(cfg, 'm_facecolor'), cfg.m_facecolor = 'k'; end
if ~isfield(cfg, 'ebstretch'), cfg.ebstretch = 2; end


if isstruct(data)
    meanData = data.mean;
    seData = data.se;
elseif isnumeric(data)
    % mean and standard error
    meanData = mean(data);
    seData = std(data)./sqrt(size(data,1));
else
    error('Wrong data format')
end

figure;
hold on;
% white background
set(gcf,...
    'Color'            , [1 1 1],...
    'PaperPositionMode', 'auto');


% plot errorbar
errorbar(meanData, seData,...
    'Color', 'k',...
    'LineStyle' , '-',...
    'LineWidth',  cfg.linewidth ,...
    'Marker', cfg.marker,...
    'MarkerEdgeColor',cfg.m_edgecolor,...
    'MarkerFaceColor', cfg.m_facecolor)


% change size of errorbar whiskers
f=cfg.ebstretch; H = findobj('LDataSource','','Parent',gca);
for h = H'
    ch = get(h,'Children'); XD = get(ch(2),'XData');
    d  = max(diff(XD));
    XD([4:9:end, 7:9:end]) = XD([4:9:end, 7:9:end])-d*f;
    XD([5:9:end, 8:9:end]) = XD([5:9:end, 8:9:end])+d*f;
    set(ch(2),'XData',XD)
end

