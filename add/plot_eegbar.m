function [twdata sedata singsubs] = plot_eegbar(ALLEEG,cfg)

% eeg_timeBar(ALLEEG,cfg) plots bar graph with standard error of the mean
% of specified time window(s)
%
% needs eeg_channels.m from pr_matlab
%
% mandatory Input:
%
% cfg.comp - array indicating relatedness e.g.: [1 1 1 2 2 2] indicates
%            that the first three and the last three files belong together
%            and are plotted together
%
%   AND
%
% ALLEEG   - EEG file(s)
% cfg.twin - time windows, have to be given for each(!) dataset,
%            e.g. [40 70; 90 130; 200 240; 40 70; 90 130; 200 240]
%
%   OR
%
% cfg.data.tw/se - to be plotted value + standard error (bypasses
%                  calculation via ALLEEG + cfg.twin)
%
%
% optional Input [default]:
%
% cfg.legend     - legend for bars [{'cond'}], 'none' for no legend
% cfg.fontsize   - font size [16]
% cfg.ylim       - y-axis limits, [-5 5]
% cfg.ylabel     - [{'Amplitude [\muV]'}]
% cfg.xlim       - x-axis limits, [no default]
% cfg.xlabel     - [{'Conditions'}]
% cfg.ebstr      - errorbar stretch ratio [1]
% cfg.channels   - channel selection [all]
% cfg.chan_mode  - compute mean of channels ('mean') or plot single
%                  channels ('sing'), ['mean']
% cfg.color      - defines color of the bars as a colormap, e.g.
%                  [1 0 0; 0 1 0; 0 0 1] is red, green and blue [default]
%                  if cfg.comp has only one index all bars have the same
%                  color
% cfg.title      - title, []
% cfg.reverse    - if exists, y-axis is reversed
% cfg.width      - bar width, [1]
% cfg.outfile    - fullfile save name (if empty nothing saved) --> see line
%                  243, hast to be commented in!
% cfg.res        - resolution of saved file
% cfg.singsubs    - if eeglab input, only has to exist, then individual
%                  means will be computed from the data. otherwise M by N
%                  array of condition by individual subject values. will be
%                  plotted as stars in the bargraph
%
% ------------------------------------------------------------------------
% copyright (c), 2010, Stefan Illek, Philipp Ruhnau, email: ruhnau@uni-leipzig.de, 2010-12-08


if nargin < 2, help plot_eegbar; return; end
if ~isfield(cfg,'fontsize'), cfg.fontsize = 16; end
if ~isfield(cfg, 'ylabel') , cfg.ylabel = 'Amplitude [\muV]'; end
if ~isfield(cfg, 'xlabel'), cfg.xlabel = 'Conditions'; end
if ~isfield(cfg, 'legend'), cfg.legend = repmat({'cond'}, 1, numel(unique(cfg.comp))); end
if ~isfield(cfg, 'ylim'), cfg.ylim = [-5 5]; end
if ~isfield(cfg, 'ebstr'), cfg.ebstr = 1; end
if ~isfield(cfg, 'color'), cfg.color = [1 0 0; 0 1 0 ;0 0 1]; end
if ~isfield(cfg, 'title'), cfg.title = []; end
if ~isfield(cfg, 'res'), cfg.res = 300; end
if ~isfield(cfg, 'width'), cfg.width = 1; end
if ~isfield(cfg, 'linew'), cfg.linew = 1; end


% number of bars in each group
nComp = hist(cfg.comp, numel(unique(cfg.comp)));


%% the following paragraph is only needed to compute data for bars from eeglab struct input

if ~isfield(cfg, 'data')
    for icount = 1:numel(ALLEEG)
        nSub(icount) = size(ALLEEG(icount).data,3);
    end

    % definitions
    if ~isfield(cfg, 'chan_mode'), cfg.chan_mode = 'mean'; end % default compute mean over channel input
    if strcmp(cfg.chan_mode, 'mean'),
        twdata    = zeros(numel(unique(cfg.comp)), max(nComp));
    else
        twdata    = zeros(numel(unique(cfg.comp)), max(nComp)*numel(cfg.channels));
    end
    sedata    = zeros(size(twdata));
    singsubs   = zeros(numel(unique(cfg.comp)), max(nComp),max(nSub));
    poinArray = ceil((cfg.twin/1000 - ALLEEG(1).xmin) * ALLEEG(1).srate);
    chanArray = repmat({[]},numel(ALLEEG),1);

    for iSet = 1:numel(ALLEEG)
        if ~isfield(cfg, 'channels')
            chanArray{iSet,:} = 1:ALLEEG(iSet).nbchan;
        elseif ~isnumeric(cfg.channels)
            [t, t, t, chanNr] = eeg_channels(ALLEEG(iSet).chanlocs, cfg.channels);
            chanArray{iSet,:} = chanNr(chanNr~=0);
        else
            chanArray{iSet,:} = cfg.channels;
        end

        % Computing average and SEM
        if strcmp(cfg.chan_mode, 'mean')
            % single subjects
            mean_sub = squeeze(mean(mean(ALLEEG(iSet).data(chanArray{iSet},poinArray(iSet,1):poinArray(iSet,2),:),2),1));
            singsubs(cfg.comp(iSet), rem(iSet-1,nComp(cfg.comp(iSet)))+1, 1:numel(mean_sub)) = mean_sub;

            twdata(cfg.comp(iSet), rem(iSet-1,nComp(cfg.comp(iSet)))+1 ) = mean(mean(mean(ALLEEG(iSet).data(chanArray{iSet},poinArray(iSet,1):poinArray(iSet,2),:),2),1),3);
            sedata(cfg.comp(iSet), rem(iSet-1,nComp(cfg.comp(iSet)))+1 ) = std(squeeze(mean(mean(ALLEEG(iSet).data(chanArray{iSet},poinArray(iSet,1):poinArray(iSet,2),:),1),2)))...
                ./sqrt(size(ALLEEG(iSet).data,3));
        elseif strcmp(cfg.chan_mode, 'sing')
            xlines = (1 + numel(cfg.channels) * rem(iSet-1,nComp(cfg.comp(iSet)))) : numel(cfg.channels) * (rem(iSet-1,nComp(cfg.comp(iSet)))+1);


            twdata(cfg.comp(iSet),  xlines) = mean(mean(ALLEEG(iSet).data(chanArray{iSet},poinArray(iSet,1):poinArray(iSet,2),:),2),3);
            sedata(cfg.comp(iSet), xlines ) = std(squeeze(mean(ALLEEG(iSet).data(chanArray{iSet},poinArray(iSet,1):poinArray(iSet,2),:),2)),0,2)...
                ./sqrt(size(ALLEEG(iSet).data,3));
        else
            disp('Wrong mode in cfg.chan_mode!!! Please check!'), return;
        end
        cfg.data.se = 1;
    end
else
    twdata = cfg.data.tw;
    if isfield(cfg.data, 'se')
    sedata = cfg.data.se;
    else
        sedata = zeros(size(twdata));
    end
    % sort after cfg.comp
    [groups, t, grp_indx] = unique(cfg.comp);

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

end

%% figure definitions


figure;
hold on;

set(gcf,...
    'Color'            , [1 1 1],...
    'PaperPositionMode', 'auto');

set(gca,...
    'FontSize'     , cfg.fontsize,...
    'Box'          , 'off'     , ...
    'TickDir'      , 'in'     , ...
    'TickLength'   , [.02 .02] , ...
    'XTick'        , 0:1:numel(unique(cfg.comp)+1), ...
    'XMinorTick'   , 'off'      , ...
    'YMinorTick'   , 'off'      , ...
    'YGrid'        , 'off'      , ...
    'XColor'       , [.1 .1 .1], ... % at some point i decided to take a dark gray instead of black, don't know why
    'YColor'       , [.1 .1 .1], ...
    'YLim'         , cfg.ylim,...
    'XAxisLocation', 'bottom',...
    'Layer'        , 'top',...
    'LineWidth'    , cfg.linew   );


% x axis limits
if isfield(cfg, 'xlim')
    set(gca, 'XLim', cfg.xlim)
end

% plot title
title([cfg.title])

% reverse y-axis
if isfield(cfg, 'reverse')
    set(gca,...
        'YDir'         , 'reverse');
end

%% plot bars

if numel(unique(cfg.comp)) == 1 % if only one bar-group (e.g. cfg.comp =[1 1 1];)
    % schummeln, not nice but no other idea to get even single comps in one
    % bar group, BAUSTELLE
    % adding zeros as second bar group, which is not shown
    b = bar([twdata; zeros(1,numel(twdata))], cfg.width, 'LineWidth' , cfg.linew, 'ShowBaseLine', 'off');
    set(gca, 'XLim' , [0 numel(unique(cfg.comp))+1]);

else
    b = bar(twdata, cfg.width, 'LineWidth' , cfg.linew,'ShowBaseLine', 'off');
end

% Labels and legend
xlabel(cfg.xlabel);
ylabel(cfg.ylabel);
if ~strcmp(cfg.legend, 'none')
    legend(b,cfg.legend)
end

%% plot errorbars
if isfield(cfg.data, 'se')
    % get coordinates of bars for errorbar plotting
    if numel(unique(cfg.comp)) == 1 % if only one bar-group (e.g. cfg.comp =[1 1 1];)
        kiddies = get(b,'Children');
        for iL = 1:numel(b)
            xC(:,:,iL) = get(kiddies{iL},'Xdata');
        end
        xCo = squeeze(mean(xC));
        xCo(2,:) = [];
    elseif mean(nComp) == 1 && strcmp(cfg.chan_mode, 'mean')% if only one bar in each group
        kiddies = get(b,'Children');
        xC(:,:) = get(kiddies,'Xdata');
        xCo = squeeze(mean(xC));
    else % for more than one bar group
        xC = zeros(4, numel(nComp), numel(b));
        kiddies = get(b,'Children');
        for iL = 1:numel(b)
            xC(:,:,iL) = get(kiddies{iL},'Xdata');
        end

        xCo = squeeze(mean(xC));
    end

    % plot errorbars
    errorbar(xCo, twdata, sedata, '+k', 'LineWidth', cfg.linew, 'Color', [.1 .1 .1])

    % change size of errorbar whiskers
    f=cfg.ebstr; H = findobj('LDataSource','','Parent',gca);
    for h = H'
        ch = get(h,'Children'); XD = get(ch(2),'XData');
        d  = max(diff(XD));
        XD([4:9:end, 7:9:end]) = XD([4:9:end, 7:9:end])-d*f;
        XD([5:9:end, 8:9:end]) = XD([5:9:end, 8:9:end])+d*f;
        set(ch(2),'XData',XD)
    end

end
%% something else and saving

% colormap
set(gcf,'Colormap', cfg.color)

if isfield(cfg, 'singsubs')
    % CAVE: single sub plotting only with EEG struct input - BAUSTELLE
    for a = 1:size(twdata,1)
        for b = 1:size(twdata,2)
            plot(xCo(a,b),squeeze(singsubs(a,b,:))','k*')
        end
    end
end

% comment in  all the following lines if you want to use this functionality
% if isfield(cfg, 'outfile')
%    save_figure(cfg.outfile, cfg.res);
% end
%
%-----------------end of script-------------------------------
%
% % added save_figure function (independence)
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
%     eval(['print -depsc2 -painters -r' num2str(resolution) ' ' name]);
% else
%     disp('WARNING: No format given, nothing is saved!!!!')
% end