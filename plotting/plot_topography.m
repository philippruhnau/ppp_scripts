function plot_topography(ALLEEG, cfg)

% plots a 2-D scalp topography, 
% CAVE: uses MODIFIED sphspline 0.11 package (A. Widmann)
%
% Mandatory Input:
%
% ALLEEG   - eeglab struct
% cfg.twin - time window for plotting
%
% Optional Input [default]:
%
% cfg.plot_mode - string, type of interpolation. 'sp' (scalp potential),
%                 'scd' (scalp current density), or 'lap' (surface
%                 Laplacian) ['sp']
% cfg.lambda    - smoothing [1e-07], see sphspline
% cfg.ylim      - y limits [-10 10]
% cfg.cmaptype  - colormap type [1]; see define_map.m
% cfg.steps     - color map steps [45]
% cfg.isolines  - vector indicating isoline limits and steps [-20:1:20]
% cfg.outfile   - fullfile save name
% cfg.res       - resolution of saved figure; [1200]
% cfg.colorbar  - 1 = yes, 0 = none; [1];

% Definitions:
if nargin < 1, help plot_topography; return; end

if ~isfield(cfg, 'steps'), cfg.steps = 45; end
if ~isfield(cfg, 'maptype'), cfg.maptype = 1; end
if ~isfield(cfg, 'plot_mode'), cfg.plot_mode = 'sp'; end
if ~isfield(cfg, 'lambda'), cfg.lambda = 1e-07; end
if ~isfield(cfg, 'isolines'), cfg.isolines = -20:1:20; end
if ~isfield(cfg, 'ylim'), cfg.ylim = [-10 10]; end
if ~isfield(cfg, 'res'), cfg.res = 300; end
if ~isfield(cfg, 'colorbar'), cfg.colorbar = 1; end

mycolor = define_map(cfg.cmaptype,cfg.steps);

% go plotting

for iCond = 1:length(cfg.type)
    EEG = ALLEEG(iCond);
    
    % change to fieldtrip format
    data_ga = eeglab2fieldtrip(EEG, 'timelockanalysis');
    data_ga.dimord = 'chan_time';
    %topography parameters,  calls different windows
    for iTime = 1 :size(cfg.twin,1)
        
      
      
      
        % select layout
    pcfg = [];
    pcfg.layout = 'EEG32.lay';%'EEG1010.lay';% 
    pcfg.parameter = 'avg';
    pcfg.fontsize = 16;
    pcfg.comment = 'no'; % better save time win in the file name then in the plot, it's nasty to get out later 
    pcfg.xlim = cfg.twin(iTime,:);
    figure; ft_topoplotER(pcfg, data_ga) 
    
    
    
        
        % saving
        if isfield(cfg, 'outfile')
            outfile = [cfg.outfile(1:end-4) '_' cfg.type{iCond} '_' num2str(cfg.twin(iTime,1)) '-' num2str(cfg.twin(iTime,2)) '_' cfg.plot_mode cfg.outfile(end-3:end)];
            save_figure(outfile, cfg.res, 1);
        end
    end
end



% old version with eeglab plugin, but ugly contour overlap
%         % call pop_plotsserpmap from sphspline 0.11
%         pop_plotsserpmap(EEG,...
%             'type', cfg.plot_mode,...
%             'proj', 'equiareal',...
%             'items', cfg.twin(:, iTime),...
%             'lambda', cfg.lambda,... %1e-7     'cmapsteps', cfg.steps,...
%             'colormap',  mycolor,...
%             'levelList',  cfg.isolines,...
%             'maplimits', [cfg.ylim(1) cfg.ylim(2)],...
%             'caption' , [cfg.type{iCond}]);
%         
%         h = get(gca);
%         % adjust the color steps in the contour
%         h.Children(1).LevelList = linspace(min(h.Children(1).LevelList), max(h.Children(1).LevelList), size(mycolor,1));
%         % adjust the level of elements
%         h.SortMethod = 'childorder';
%         
%         % remove title if not given
%         if ~isfield(cfg, 'title'),  h.Title.Visible = 'off'; end
%         
%         
%         % eliminate colorbar
%         if cfg.colorbar == 0,  colorbar('off'); end
%         
%         
% function save_figure(name, resolution)
% 
% % saves figures in postscipt or portable network graphic format
% %
% % Input:
% %
% % name       - name and place of to be saved file
% % resolution - picture resolution
% 
% disp(' '); disp(['Saving file: ' name '!!!']); disp(' ')
% 
% if ~isempty(strfind(name, 'png'))
%     eval(['print -dpng -r' num2str(resolution) ' ' name]);
% elseif ~isempty(strfind(name, 'eps'))
%       eval(['print -depsc2 -painters -r' num2str(resolution) ' ' name]);
% end