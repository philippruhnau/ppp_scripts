function plot_eeg(ALLEEG,cfg)

% function plot_eeg(ALLEEG,cfg)
% plot_eeg(ALLEEG,cfg) plots EEG data from eeglab structure
%
% Mandatory Input:
%
% ALLEEG   - EEG file(s)
% cfg.cond - Condition name(s), must match the number of EEG file(s),
%            for difference waves should be ordered in such a way that to
%            be subtracted conditions share the same column (2 by M)
%            example:
%            cfg.cond = {'dev', 'dev', 'dev'; % minuend
%                        'sta', 'con', 'sbd'} % subtrahend
% Optional Input [default] :
%
% cfg.plot      - single plot mode ('single'), array mode ('array'), channel
%                 view from the top ('head') or butterfly of selected channels
%                 ('butterfly') ['single']
% cfg.depict    - 'erp', 'dif' or 'combined' for plot ALLEEG data as single/difference
%                 waves or combine both (last not for 'butterfly') ['erp']
%
% cfg.xtime     - vector containing time points in epoch [min:1000/SR:max]
% cfg.xlim      - min and max of x-axis [min max]
% cfg.ylim      - min and max of y-axiy [-10 10]
% cfg.yticks    - y-ticks to show, [y-min:1:y-max]
% cfg.xlabel    - ['Time [ms]']
% cfg.ylabel    - ['Amplitude [\muV]']
% cfg.legend    - figure legend 1 by M cell array or 'none' [cfg.legend = cfg.cond]
% cfg.channels  - vector containing channels for plots [all (for which there
%                 are coordinates in eeg_channels)]. 
% cfg.fontsize  - fontsize [12]
%
% CAVE: the following three have to match the number of conditions (cfg.cond)!!!
% cfg.erpcolor  - cell containing colors for ERP plots [{'k-' 'k-' ...}]
% cfg.difcolor  - cell containing colors for difference waves [{'m--' 'm--' ...}]
% cfg.linewidth - vector containing individual linewidth [1 1 ...]
%
% cfg.grandmean - if set plots an extra channel-grand-mean in the butterfly
%                 mode (has additional cfg.gmlinewidth and cfg.gmcolor)
%
% cfg.ratio     - defines ration by which the size of channel pictures in 'head'
%                 plot mode is devided [2 - suites about 30 electrodes],
%                 first modify this instead of .chwidht and .chheight
% cfg.chwidth   - width of channel subplot in 'head'-plot mode [0.18]
% cfg.chheight  - height of channel subplot in 'head'-plot mode [0.1]
%
% cfg.marker    - x-coordinates of a to be highlighted area (e.g. statistics)
%
% cfg.outfile   - output is saved only if name is given here [empty];
%                 png and eps can be chosen (append to file name)
%                 adds channel names, 'butterfly' and condition name
%                 resp. '_number' ('array with many channels) to file
%                 name ('head' plot mode only produces one output)
% cfg.res       - resolution of output file [600] for png
%
% ------------------------------------------------------------------------
                                   
% copyright (c), 2010, P. Ruhnau, email: ruhnau@uni-leipzig.de, 2011-17-06
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
                                   
% definitions:
if nargin < 2, help plot_eeg; return; end
if ~isfield(ALLEEG, 'data'), fprintf('Error: ALLEEG either undefined or errornous! \n'); return; end
if ~isfield(cfg, 'cond'), fprintf('Error: cfg.cond needs to be specified! \n'); return; end
if size(ALLEEG,2) ~= numel(cfg.cond), fprintf('Error: Size of ALLEEG and cfg.cond are not matching! \n'), return; end

if ~isfield(cfg, 'xtime'),     cfg.xtime = ALLEEG(1).xmin*1000:1000/ALLEEG(1).srate:ALLEEG(1).xmax*1000; end
if ~isfield(cfg, 'xlim'),      cfg.xlim  = [cfg.xtime(1) cfg.xtime(end)]; end
if ~isfield(cfg, 'ylim'),      cfg.ylim  = [-10 10]; end
if ~isfield(cfg, 'yticks'),    cfg.yticks = cfg.ylim(1):1:cfg.ylim(2); end
if ~isfield(cfg, 'xlabel'),    cfg.xlabel = 'Time [ms]'; end
if ~isfield(cfg, 'ylabel'),    cfg.ylabel = 'Amplitude [\muV]'; end


if ~isfield(cfg, 'fontsize'),  cfg.fontsize = 12; end
if ~isfield(cfg, 'erpcolor'), cfg.erpcolor = repmat({'k-'},1,size(ALLEEG,2)); end
if ~isfield(cfg, 'difcolor'), cfg.difcolor = repmat({'m--'},1,size(ALLEEG,2)); end
if ~isfield(cfg, 'gmcolor'), cfg.gmcolor = repmat({'r-'},1,size(ALLEEG,2)); end
if ~isfield(cfg, 'linewidth'), cfg.linewidth = ones(1,size(ALLEEG,2)); end
if ~isfield(cfg, 'gmlinewidth'), cfg.gmlinewidth = cfg.linewidth.*1.5; end

if ~isfield(cfg, 'legend'),    cfg.legend = reshape(cfg.cond, 1,numel(cfg.cond)); end

if ~isfield(cfg, 'channels'),  cfg.channels = 1:ALLEEG(1).nbchan; end

if ~isfield(cfg, 'ratio'),     cfg.ratio    = 2; end
if ~isfield(cfg, 'chwidth'),   cfg.chwidth  = 0.1800/cfg.ratio; end
if ~isfield(cfg, 'chheight'),  cfg.chheight = 0.1000/cfg.ratio; end

if ~isfield(cfg, 'plot'),      cfg.plot = 'single'; end
if strcmp(cfg.plot, {'single', 'array', 'head','butterfly'}) == 0, error('No such plot mode!!! (Change cfg.plot)'); end % check if right plot mode
if ~isfield(cfg, 'depict'),    cfg.depict = 'erp'; end
if ~isfield(cfg, 'res'),       cfg.res = 600;      end


% -------------------------------------------------------------------------
% Start Plotting

if sum(strcmp(cfg.plot, {'single', 'butterfly'})) == 0
    figure;
end

% currently the positions of around 86 channels are available (10-10 system
set_channels = zeros(numel(ALLEEG),numel(cfg.channels));
for i = 1:numel(ALLEEG)
    [coor ch_names actCha cellInd] = eeg_channels(ALLEEG(i).chanlocs, cfg.channels);
    if numel(ch_names) < numel(actCha)
        set_channels(i,:) = cellInd(cellInd ~=0); % 0 indicates that channel (name/coordinates) is not in lookup_eeg_channels
    elseif  ~isnumeric(cfg.channels)
        set_channels(i,:) = cellInd(cellInd ~=0);
    end
end
cfg.channels = set_channels(1,:);

if size(cfg.channels,2) < size(cfg.channels,1), cfg.channels = cfg.channels'; end


for iChan = 1:size(cfg.channels,2)
    
    if strcmp(cfg.plot, 'array')
        if numel(cfg.channels) <= 4
            subplot(size(cfg.channels,2),1,iChan);
        elseif numel(cfg.channels) <= 12
            subplot(ceil(size(cfg.channels,2)/3),3,iChan);
        elseif numel(cfg.channels) <= 25
            subplot(ceil(size(cfg.channels,2)/5),5,iChan);
        elseif  numel(cfg.channels) >= 25
            posi = rem(iChan-1,25);
            
            if posi == 0 && iChan ~= 1
                figure;
            end
            subplot(5,5,posi+1);
            %             error('Noch Baustelle: Mehr als 25 Kanaele in einer Figure sind im Array nicht verstaendlich!')
        end
    elseif strcmp(cfg.plot, 'head')
        
        subplot('Position', [coor(iChan,1) coor(iChan,2) cfg.chwidth cfg.chheight]);
        
    elseif strcmp(cfg.plot, 'single')
        figure;
    elseif strcmp(cfg.plot, 'butterfly')
        if iChan <= numel(cfg.cond) && strcmp(cfg.depict, 'erp')
            figure;
        elseif iChan <= size(cfg.cond,2) && strcmp(cfg.depict, 'dif')
            figure;
        elseif strcmp(cfg.depict, 'combined')
            error('In Butterfly mode no combination of single and difference wave plotting possible!!! (Change cfg.depict)')
        end
    else
        error('Wrong plot mode! Change in cfg.plot!')
    end
    
    hold on;
    
    
    if isfield(cfg, 'marker')
        if strcmp(cfg.plot, {'butterfly'}) && strcmp(cfg.depict, 'erp') && iChan > numel(cfg.cond)
            % there is nothing to plot in butterfly mode for extra channels of
            % the loop, therefor this empty case
        elseif strcmp(cfg.plot, {'butterfly'}) && strcmp(cfg.depict, 'dif') && iChan > size(cfg.cond,2)
            % there is nothing to plot in butterfly(dif) mode for extra channels of
            % the loop, therefor this empty case
        else
            % get y-boards of markers
            if isfield(cfg, 'axes')
                if isfield(cfg.axes, 'lims')
                    yb = cfg.axes.lims(3:4);
                else
                    yb = cfg.ylim;
                end
            else
                yb = cfg.ylim;
            end
            
            for iM = 1:size(cfg.marker,1)
                fill([cfg.marker(iM,1) cfg.marker(iM,1) cfg.marker(iM,2) cfg.marker(iM,2)], [yb(1) yb(2) yb(2) yb(1)], [0.9 0.9 0.9], 'EdgeColor', 'none');
            end
        end
    end
    
    
    % Axes: 1. x; 2. y
    % Change y1 paramater of y-axis when taking a seperate stim-lock
    % Achtung: Gelten freilich auch als Linien fuer die Legende!!!!!!
    % --------------------------------------------------------------
    if ~isfield(cfg, 'axes')
        plot([ALLEEG(1).xmin*1000 ALLEEG(1).xmax*1000],[0 0], 'k-', 'LineWidth', 0.8) % x-Axis
        plot([0 0],cfg.ylim, 'k-', 'LineWidth', 0.8) % y-Axis
    end
    
    title(ALLEEG(1).chanlocs(cfg.channels(iChan)).labels)
    
    
    
    % Plotting specifications
    % -----------------------
    set(gca,...
        'FontSize'     , cfg.fontsize,...
        'Box'          , 'off'     , ...
        'TickDir'      , 'in'     , ...
        'TickLength'   , [.02 .02] , ...
        'XMinorTick'   , 'off'      , ...
        'YMinorTick'   , 'off'      , ...
        'YGrid'        , 'off'      , ...
        'YDir'         , 'reverse',...
        'XColor'       , [0 0 0], ...
        'YColor'       , [0 0 0], ...
        'XLim'         , cfg.xlim,...
        'YLim'         , cfg.ylim,...
        'XTick'        , cfg.xlim(1):100:cfg.xlim(2), ...
        'YTick'        , cfg.yticks,...
        'XAxisLocation', 'bottom',...
        'Layer'        , 'top',...
        'LineWidth'    , 1        );
    
    
    set(gcf,...
        'Color'            , [1 1 1],...
        'PaperPositionMode', 'auto');
    
    if isfield(cfg, 'axes')
        % more or less for advanced users, calls b.herrmann's plot_axes; if
        % you want to use this ask bh [or for contact pr]
        set(gca, 'Visible', 'off');
        cfg.axes.ylabel = cfg.ylabel;
        cfg.axes.xlabel = cfg.xlabel;
        cfg.axes.line_width = cfg.linewidth(1);
        cfg.axes.font_size = cfg.fontsize;
        plot_axes(cfg.axes);
    end
    
    % only use x- and y-labes if single/butterfly mode or less than 9
    % channels are displayed (otherwise too crowded)
    % -----------------------------------------------------------------
    if sum(strcmp(cfg.plot, {'single', 'butterfly'})) == 1 || numel(cfg.channels) <= 9
        xlabel(cfg.xlabel);
        ylabel(cfg.ylabel);
    elseif iChan < numel(cfg.channels)
        set(gca, 'YTick', [], 'XTick', [])
    end
    
    
    if strcmp(cfg.depict, 'erp')
        
        if ~strcmp(cfg.plot, 'butterfly')
            for iType = 1:numel(cfg.cond)
                % Plot ERPs
                % ---------
                
                ERP(iType) = plot(cfg.xtime, (mean(ALLEEG(iType).data(set_channels(iType,iChan),:,:),3))', cfg.erpcolor{iType}, 'LineWidth', cfg.linewidth(iType)); %#ok<AGROW>
                
            end
            
        elseif strcmp(cfg.plot, 'butterfly') && iChan <= numel(cfg.cond)
            iType = iChan;
            for chans = 1:size(cfg.channels,2)
                ERP(iType) = plot(cfg.xtime, (mean(ALLEEG(iType).data(set_channels(iType,chans),:,:),3))', cfg.erpcolor{iType}, 'LineWidth', cfg.linewidth(iType)); %#ok<AGROW>
            end
            if isfield(cfg, 'grandmean') % name ist haesslich BAUSTELLE; plots mean of all displayed channels
                GM(iType) = plot(cfg.xtime, (mean(mean(ALLEEG(iType).data(set_channels(iType,:),:,:),3),1))', cfg.gmcolor{iType}, 'LineWidth', cfg.gmlinewidth(iType)); %#ok<NASGU,AGROW>
            end
        end
        
    elseif strcmp(cfg.depict, 'dif')
        if ~strcmp(cfg.plot, 'butterfly')
            for iType = 1:size(cfg.cond,2)
                % Plot ERPs
                % ---------
                minuend = (iType-1) * 2 + 1;
                subtrahend = (iType-1) * 2 + 2;
                ERP(iType) = plot(cfg.xtime,...
                    (mean(ALLEEG(minuend).data(set_channels(minuend,iChan),:,:),3))' - (mean(ALLEEG(subtrahend).data(set_channels(subtrahend,iChan),:,:),3))' , cfg.difcolor{iType}, 'LineWidth', cfg.linewidth(iType)); %#ok<AGROW>
                
            end
        elseif strcmp(cfg.plot, 'butterfly') && iChan <= size(cfg.cond,2)
            iType = iChan;
            for chans = 1:size(cfg.channels,2)
                minuend = (iType-1) * 2 + 1;
                subtrahend = (iType-1) * 2 + 2;
                ERP(iType) = plot(cfg.xtime,...size(ALLEEG,2)
                    (mean(ALLEEG(minuend).data(set_channels(minuend,chans),:,:),3))' - (mean(ALLEEG(subtrahend).data(set_channels(subtrahend,chans),:,:),3))' , cfg.difcolor{iType}, 'LineWidth', cfg.linewidth(iType)); %#ok<AGROW>
                
            end
            if isfield(cfg, 'grandmean') % name ist haesslich BAUSTELLE; plots mean of all displayed channels
                minuend = (iType-1) * 2 + 1;
                subtrahend = (iType-1) * 2 + 2;
                ERP(iType) = plot(cfg.xtime,...
                    mean((mean(ALLEEG(minuend).data(set_channels(minuend,:),:,:),3))' - (mean(ALLEEG(subtrahend).data(set_channels(subtrahend,:),:,:),3))',2) ,...
                    cfg.gmcolor{iType}, 'LineWidth', cfg.gmlinewidth(iType)); %#ok<AGROW>
                
            end
        end
        
    elseif strcmp(cfg.depict, 'combined')
        
        for iType = 1:numel(cfg.cond)
            % Plot ERPs
            % ---------
            
            ERP(iType) = plot(cfg.xtime, (mean(ALLEEG(iType).data(set_channels(iType,iChan),:,:),3))', cfg.erpcolor{iType}, 'LineWidth', cfg.linewidth(iType));  %#ok<AGROW>
            if round(iType/2) == iType/2
                minuend = (iType/2-1) * 2 + 1;
                subtrahend = (iType/2-1) * 2 + 2;
                DIF(iType/2) = plot(cfg.xtime,...
                    (mean(ALLEEG(minuend).data(set_channels(minuend, iChan),:,:),3))' - ...
                    (mean(ALLEEG(subtrahend).data(set_channels(subtrahend, iChan),:,:),3))' ,...
                    cfg.difcolor{iType/2}, 'LineWidth', cfg.linewidth(iType));  %#ok<AGROW>
            end
            
        end
        
        
    end
    
    
    
    % Setting up a legend for single figures
    % --------------------------------------
    if strcmp(cfg.plot, 'single') && sum(strcmp(cfg.legend, 'none')) == 0
        if exist('DIF', 'var')
            if numel(cfg.legend) ~= numel(cfg.cond) + size(cfg.cond,2)
                cfg.legend{end+1} = 'difference';
                
            end
            ERP = [ERP DIF]; %#ok<AGROW>
        elseif strcmp(cfg.depict, 'dif') && numel(cfg.legend) ~= numel(cfg.cond)/2
            cfg.legend = repmat({'difference'}, 1, numel(cfg.cond)/2);
        end
        legend(ERP,cfg.legend,numel(cfg.legend), 'Location', 'NorthEast')
        xlabel(cfg.xlabel);
        ylabel(cfg.ylabel);
    end
    
    %Single figure save
    if isfield(cfg, 'outfile')
        if  strcmp(cfg.plot, {'single'}) || strcmp(cfg.plot, {'butterfly'}) && iChan<=numel(cfg.cond)
            if strcmp(cfg.plot, 'single')
                outfile = [cfg.outfile(1:end-4) '_' ALLEEG(1).chanlocs(cfg.channels(iChan)).labels cfg.outfile(end-3:end)];
            elseif  strcmp(cfg.plot, 'butterfly')
                outfile = [cfg.outfile(1:end-4) '_' cfg.cond{iChan}  cfg.outfile(end-3:end)];
            end
            
            save_figure(outfile, cfg.res);
            
        elseif (strcmp(cfg.plot, {'array'}) && numel(cfg.channels) > 25 )
            % here array plots are safed, when more than 25 channels,
            % unfortunately the legend gets lost this way (BAUSTELLE)
            if posi == 24 || iChan == size(cfg.channels,2)
                pC = sum(rem(0:iChan-1,25)==0);
                outfile = [cfg.outfile(1:end-4) '_n' num2str(pC) cfg.outfile(end-3:end)];
                
                save_figure(outfile, cfg.res)
            end
        end
    end
    
end

% Setting up a legend
% -------------------
if ~strcmp(cfg.plot, 'single') && sum(strcmp(cfg.legend, 'none')) == 0
    if exist('DIF', 'var')
        if numel(cfg.legend) ~= numel(cfg.cond) + size(cfg.cond,2)
            cfg.legend{end+1} = 'difference';
        end
        ERP = [ERP DIF];
    elseif strcmp(cfg.depict, 'dif') && numel(cfg.legend) ~= numel(cfg.cond)/2
        cfg.legend = repmat({'difference'}, 1, numel(cfg.cond)/2);
    end
    legend(ERP,cfg.legend,numel(cfg.legend), 'Location', 'NorthEastOutside')
    xlabel(cfg.xlabel);
    ylabel(cfg.ylabel);
end



% save
if isfield(cfg, 'outfile') && sum(strcmp(cfg.plot, {'single', 'butterfly'})) == 0
    save_figure(cfg.outfile, cfg.res);
end


%---------------------end of script------------------------------

% functions embedded (independence): eeg_channels and save_figure

function [coor n actCha cellInd] = eeg_channels(chaninfo, chan_sel)

% eeg_channels(chaninfo, chan_sel)
% looks up selected channel names/numbers  and coordinates for eeg-data
% Input:
% chaninfo - channel information in EEG.chanloc (eeglab)
% chan_sel - cell array of strings or vector of numbers with channel selection
%
% Output:
% coor    - channels coordinates
% n       - cell array of channel names concordant with existing names and
%           coordinates in this file (so far 86 [10-10 system])
% actCha  - selected channels names (whole self selection)
% indb    - channel indizes of selection in ALLEEG, nesecary if input is
%           cell array
% cellInd - indizes of concordant channels of chan_sel and channels
%           existent in this file, necesary if not matching
%
% ---------------------------------------------------
% copyright (c), 2010, P. Ruhnau, email: ruhnau@uni-leipzig.de, 2010-07-29


if iscell(chan_sel)
    % checks whether wanted channels are in the data
    actCha = upper(chan_sel);
    actCha_check = struct2cell(chaninfo);
    actCha_check = upper(squeeze(actCha_check(1,:,:)));
    [t cellIndA cellIndB] = intersect(actCha_check, actCha);
    
    for i = 1:numel(cellIndB)
        cellInd(cellIndB(i)) = cellIndA(i); %#ok<AGROW>
    end
    actCha = actCha(cellInd~=0);
else
    % checks whether wanted channels are in the data
    actCha = struct2cell(chaninfo);
    actCha_check = upper(squeeze(actCha(1,:,:)));
    actCha = upper(squeeze(actCha(1,:,chan_sel)));
    [t cellIndA cellIndB] = intersect(actCha_check, actCha);
    
    for i = 1:numel(cellIndB)
        cellInd(cellIndB(i)) = cellIndA(i); %#ok<AGROW>
    end
end


pos = [0.3811    0.8313;    0.4800    0.8487;    0.5789    0.8314;    0.2449    0.8527;    0.2919    0.7811;    0.3361    0.7710;...
    0.3828    0.7646;    0.4311    0.7613;    0.4800    0.7602;    0.5289    0.7613;    0.5772    0.7645;    0.6238    0.7710;...
    0.6681    0.7811;    0.7151    0.8527;    0.1564    0.7549;    0.2211    0.7029;    0.2826    0.6869;    0.3472    0.6779;...
    0.4132    0.6733;    0.4800    0.6718;    0.5468    0.6733;    0.6128    0.6779;    0.6774    0.6869;    0.7389    0.7029;...
    0.8036    0.7548;    0.0995    0.6316;    0.1757    0.6042;    0.2506    0.5931;    0.3266    0.5872;    0.4032    0.5843;...
    0.4800    0.5834;    0.5568    0.5843;    0.6334    0.5872;    0.7094    0.5931;    0.7843    0.6042;    0.8605    0.6316;...
    0.0800    0.4949;    0.1600    0.4949;    0.2400    0.4949;    0.3200    0.4949;    0.4000    0.4950;    0.4800    0.4950;...
    0.5600    0.4949;    0.6400    0.4949;    0.7200    0.4949;    0.8000    0.4949;    0.8800    0.4949;    0.0995    0.3582;...
    0.1756    0.3856;    0.2506    0.3968;    0.3266    0.4027;    0.4032    0.4056;    0.4800    0.4065;    0.5568    0.4056;...
    0.6334    0.4027;    0.7094    0.3968;    0.7844    0.3856;    0.8605    0.3582;    0.1564    0.2350;    0.2211    0.2870;...
    0.2826    0.3030;    0.3471    0.3120;    0.4132    0.3167;    0.4800    0.3181;    0.5468    0.3167;    0.6129    0.3120;...
    0.6774    0.3030;    0.7389    0.2870;    0.8036    0.2350;    0.2449    0.1371;    0.2919    0.2087;    0.3361    0.2189;...
    0.3829    0.2251;    0.4311    0.2286;    0.4800    0.2296;    0.5289    0.2286;    0.5771    0.2251;    0.6239    0.2189;...
    0.6681    0.2087;    0.7151    0.1371;    0.3811    0.1585;    0.4800    0.1411;    0.5789    0.1585;    0.3564    0.0744;...
    0.4800    0.0527;    0.6036    0.0744;    0.6627    0.9035;  0.8018    0.9035];

% original coordinates from fieldtrip
% pos = [-0.4962    1.5271;   -0.9438    1.2990;   -0.5458    1.1705;   -0.3269    0.8091;   -0.6590    0.8138;   -0.9879    0.8588;   -1.2990    0.9438;...
%     -1.5271    0.4962;   -1.1732    0.4503;   -0.7705    0.4097;   -0.3949    0.3949;   -0.4014         0;   -0.8029         0;   -1.2043         0;...
%     -1.6057         0;   -1.5271   -0.4962;   -1.1732   -0.4503;   -0.7705   -0.4097;   -0.3949   -0.3949;   -0.3269   -0.8091;   -0.6590   -0.8138;...
%     -0.9879   -0.8588;   -1.2990   -0.9438;   -1.5375   -1.2902;   -0.9438   -1.2990;   -0.5458   -1.1705;   -0.4962   -1.5271;         0   -2.0071;...
%     0   -1.6057;         0   -1.2043;         0   -0.8029;         0   -0.4014;         0    1.6057;    0.4962    1.5271;    0.9438    1.2990;...
%     0.5458    1.1705;         0    1.2043;         0    0.8029;    0.3269    0.8091;    0.6590    0.8138;    0.9879    0.8588;    1.2990    0.9438;...
%     1.5271    0.4962;    1.1732    0.4503;    0.7705    0.4097;    0.3949    0.3949;         0    0.4014;         0         0;    0.4014         0;...
%     0.8029         0;    1.2043         0;    1.6057         0;    1.5271   -0.4962;    1.1732   -0.4503;    0.7705   -0.4097;    0.3949   -0.3949;...
%     0.3269   -0.8091;    0.6590   -0.8138;    0.9879   -0.8588;    1.2990   -0.9438;    1.5375   -1.2902;    0.9438   -1.2990;    0.5458   -1.1705;...
%     0.4962   -1.5271;       0.4962    1.9285; 0.9924    1.9285];

% P9 and P10 could account for M1(A1) and M2(A2) in my usual setups, therby
% names changed to the latter
names = {'FP1'    'FPZ'    'FP2'    'AF9'    'AF7'    'AF5'    'AF3'    'AF1'    'AFZ'    'AF2'    'AF4'    'AF6',...
    'AF8'    'AF10'    'F9'    'F7'    'F5'    'F3'    'F1'    'FZ'    'F2'    'F4'    'F6'    'F8'    'F10',...
    'FT9'    'FT7'    'FC5'    'FC3'    'FC1'    'FCZ'    'FC2'    'FC4'    'FC6'    'FT8'    'FT10'    'T9',...
    'T7'    'C5'    'C3'    'C1'    'CZ'    'C2'    'C4'    'C6'    'T8'    'T10'    'TP9'    'TP7'    'CP5',...
    'CP3'    'CP1'    'CPZ'    'CP2'    'CP4'    'CP6'    'TP8'    'TP10'    'P9'    'P7'    'P5'    'P3',...
    'P1'    'PZ'    'P2'    'P4'    'P6'    'P8'    'P10'    'PO9'    'PO7'    'PO5'    'PO3'    'PO1',...
    'POZ'    'PO2'    'PO4'    'PO6'    'PO8'    'PO10'    'O1'    'OZ'    'O2'    'I1'    'IZ'    'I2',...
    'VEOG'   'HEOG'};


[n ind indb] = intersect(names, actCha);
index = zeros(max(indb),1);
index_check =zeros(max(ind),1);
for i = 1:numel(indb)
    index(indb(i)) = ind(i);
    index_check(ind(i)) = indb(i);
end

n = names(index(index>0));
coor = pos(index(index>0),:);

% check for same amount of input channels as output channels otherwise
% modify cellInd --> indizes of used channels in ALLEEG
if numel(index_check(index_check~=0)) ~= numel(actCha)
    cellInd = cellInd(sort(index_check(index_check ~=0)));
end

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
