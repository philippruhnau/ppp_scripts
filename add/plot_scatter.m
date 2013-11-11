function plot_scatter(data, cfg)

% plot_scatter(data, cfg) plots a scatter plot with multiple options
%
% mandatory input:
% data - m by n matrix, m - individuals (y), n - conditions (x)
%
% optional input [default]:
% cfg.color     - cell array defining color per data-column [{'k' 'k' ...}]
% cfg.style     - cell array defining marker per data-column [{'*' '*' ...}]
% cfg.reverse   - if 1 reverses y-axis [0]
% cfg.link      - set 1 if line between markers is desired [0]
% cfg.linewidth - vector - linewidth between markers [1 1 ...]
% cfg.linestyle - cell array - linestyle [{'-' '-' ...}]
% cfg.linecolor - cell array - linecolor [{'k' 'k' ...}]
%
% 112123123412345123456123456712345678123456789
% P. Ruhnau - ruhnau@uni-leipzig.de, 2012-07-05


if ~isfield(cfg, 'color'),      cfg.color(1:size(data,2)) = {'k'}; end
if ~isfield(cfg, 'style'),      cfg.style(1:size(data,2)) = {'*'}; end
if ~isfield(cfg, 'link'), cfg.link = 0; end
if ~isfield(cfg, 'linewidth'),  cfg.linewidth(1:size(data,1)) = 1; end
if ~isfield(cfg, 'linestyle'),  cfg.linestyle(1:size(data,1)) = {'-'}; end
if ~isfield(cfg, 'linecolor'),  cfg.linecolor(1:size(data,1)) = {'k'}; end
if ~isfield(cfg, 'reverse'),    cfg.reverse = 0; end


% general figure definitions
figure;
set(gca,...
    'Box'          , 'off'     , ...
    'XColor'       , [0 0 0], ...
    'YColor'       , [0 0 0], ...
    'Layer'        , 'top');
set(gcf,...
    'Color'            , [1 1 1],... %white background
    'PaperPositionMode', 'auto');

if cfg.reverse == 1, set(gca, 'YDir'         , 'reverse'); end

hold on

for iCond = 1:size(data,2) 
plot(ones(size(data,1),1)+iCond-1,data(:,iCond), cfg.style{iCond}, 'color', cfg.color{iCond})
end


if cfg.link == 1 % connect points with black line
    for iLine = 1:size(data,1)
    plot((1:size(data,2))',data(iLine,:), 'color',  cfg.linecolor{iLine}, 'linestyle', cfg.linestyle{iLine})
    end
end