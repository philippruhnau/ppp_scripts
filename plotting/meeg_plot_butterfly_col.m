function meeg_plot_butterfly_col(cfg)


% meeg_plot_butterfly(cfg)
%
% Input:
%	cfg.data	- data matrix: channels x time
%	cfg.limits	- [xmin xmax ymin ymax]; % e.g. [-200 500 -1e-12 1e-12]
%	cfg.xlabel	- label x-axis
%	cfg.ylabel	- label y-axis
%	cfg.caption	- some text
%	cfg.outfile	- save plot % optional
%	cfg.res		- figure resolution for saving
%   cfg.rois    - vektor indicating ROIs, default 1 ROI
%   cfg.col     - {'k-'}; ROI colors
%
% -----------------------------------------------------------------
% copyright (c) 2009, Bj�rn Herrmann, 2009-12-03


% Load defaults if appropriate
% ----------------------------
fs = filesep;
if ~isfield(cfg, 'data'),       fprintf('Error: Data vector needs to be defined.\n'); return; end
if ~isfield(cfg, 'limits'),     cfg.limits  = [1, size(cfg.data,2), max(abs(cfg.data(:)))*-1, max(abs(cfg.data(:)))]; end
if ~isfield(cfg, 'xlabel'),     cfg.xlabel  = 'Time [ms]'; end
if ~isfield(cfg, 'ylabel'),     cfg.ylabel  = 'Amplitude'; end
if ~isfield(cfg, 'caption'),	cfg.caption = ''; end
if ~isfield(cfg, 'res'),    	cfg.res     = 300; end
if ~isfield(cfg, 'rois'),       cfg.rois    = ones(size(cfg.data,1),1); end
if ~isfield(cfg, 'col'),        cfg.col     = {'k-'}; end
if ~isfield(cfg, 'axes'),       cfg.axes    = 0;    end
if ~isfield(cfg, 'axis'),       cfg.axis    = cfg.limits; end
if ~isfield(cfg, 'linewidth'),  cfg.linewidth = 2; end
font_size = 24;


figure;
set(gca, 'FontSize', font_size);
set(gcf, 'Color', [1 1 1]); 
xtime = cfg.limits(1):(abs(cfg.limits(1) - cfg.limits(2)) / (size(cfg.data,2)-1)):cfg.limits(2);
hold on;

if cfg.axes == 1
plot([cfg.xtime(1) cfg.xtime(end)], [0 0], 'k-', 'LineWidth', 0.5) % x-Axis
plot([0 0],cfg.lim_y, 'k-', 'LineWidth', 0.5) % y-Axis
end

for i = 1 : size(cfg.data,1)
	plot(xtime, cfg.data(i,:), cfg.col{cfg.rois(i)}, 'linewidth', cfg.linewidth);
% 	hold on;
end
xlim([cfg.limits(1:2)]);
ylim([cfg.limits(3:4)]);
xlabel(cfg.xlabel);
ylabel(cfg.ylabel);
axis([cfg.axis])
title(cfg.caption);
grid off;

% Save figure
% -----------
% if isfield(cfg, 'outfile')		
%     
% 	save_figure(cfg.outfile, cfg.res);
% end

function save_figure(name, resolution)

% saves figures in postscipt or portable network graphic format
%
% Input:
%
% name       - name and place of to be saved file
% resolution - picture resolution

disp(' '); disp(['Saving file: ' name '!!!']); disp(' ')

if ~isempty(strfind(name, 'png'))
    eval(['print -dpng -r' num2str(resolution) ' ' name]);
elseif ~isempty(strfind(name, 'eps'))
    eval(['print -depsc2 -painters -r' num2str(resolution) ' ' name]);
else
    disp('WARNING: No format given, nothing is saved!!!!')
end



