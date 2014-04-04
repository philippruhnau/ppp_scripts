function cimec_singleplotTFR(cfg, freq)

% cimec_singleplotTFR(cfg, freq)
% plots a cingle time-freq representation using the contourf function
% (instead of imagsc), works similar to ft_singleplotTFR
%
% input:
% freq - struct, output of ft_freqanalysis of ft_freqgrandaverage
% cfg - struct, containing definitions, fields as follows [default]:
%   zparam   - string, plotting parameter ['powspctrm']
%   toilim   - limits of time of interest [whole epoch] 
%   foilim   - limits of frequency range of interest [all]
%   channel  - channels to plot (averaged) [all]
%   
%   zlim     - color map limits [absmax]
%   nlines   - number of contour lines [matlab default, what is it???]
%   colorbar - 1 = on, any other number = off [1]
%   fonsize  - fontsize for axes [14]
%   vline    - vector, vertical lines, e.g., stimulus onset [empty]
%   vline_style.color - vertical line color, must match n of vline [{'k'}]
%   vline_style.width - vertical line width, must match n of vline [3]

% version 20130816 - comments, help, and some defaults added, PR
% version 2013xxxx - initial implimentation NW      

if ~isfield(cfg, 'toilim'), toilim= freq.time([1 end]); else toilim=cfg.toilim; end
if ~isfield(cfg, 'foilim'), foilim = freq.freq([1 end]); else foilim=cfg.foilim; end
if ~isfield(cfg, 'colorbar'), plot_colorbar = 1; else  plot_colorbar = cfg.colorbar; end
if ~isfield(cfg, 'fontsize'), fontsize = 14; else fontsize = cfg.fontsize; end

if ~isempty(cfg.channel)
    chans=cfg.channel;
else
    chans=freq.label;
end

if isfield(cfg,'nlines')
    nlines=cfg.nlines;
else
    nlines=[];
end

%   make variable z parameter
if ~isfield(cfg, 'zparam'),      
    cfg.zparam='powspctrm';             
end

%%  substitute powspctrm with selected z-parameter

freq.powspctrm= freq.(cfg.zparam);

%% find datapoints
indt1=nearest(freq.time, toilim(1));
indt2=nearest(freq.time, toilim(2));

indf1=nearest(freq.freq, foilim(1));
indf2=nearest(freq.freq, foilim(2));

%% find channels

indchan=match_str(freq.label,chans);

%% modify struct for plotting
freq4P=freq;
freq4P.time=freq.time(indt1:indt2);
freq4P.freq=freq.freq(indf1:indf2);

%% avg over subjects if needed, in any case avg over channels
switch freq.dimord
    case 'subj_chan_freq_time'
        disp('Averaging over subject dimension!')
        freq4P.powspctrm = squeeze(mean(mean(freq.powspctrm(:,indchan,indf1:indf2,indt1:indt2),1),2));
    case 'chan_freq_time'   
        freq4P.powspctrm=squeeze(mean(freq.powspctrm(indchan,indf1:indf2,indt1:indt2),1));
end

clear freq

%% max abs or user defined
if ~isfield(cfg, 'zlim') % maxabs
    maxZ=max(abs([min(freq4P.powspctrm(:)) max(freq4P.powspctrm(:))]));
    maxZ = [-maxZ maxZ];
else
    maxZ = cfg.zlim;
end


%% do plotting
figure; 
if ~isempty(nlines)
    contourf(freq4P.time, freq4P.freq, freq4P.powspctrm, nlines)
else
    contourf(freq4P.time, freq4P.freq, freq4P.powspctrm)
end
shading flat


%% add vertical lines if wanted
if isfield(cfg, 'vline') % plot vertical lines
    hold on
    vl = cfg.vline;
    % defaults for linecolors and -width
    if isfield(cfg, 'vline_style')
        if isfield(cfg.vline_style, 'color'); vl_col = cfg.vline_style.color; end
        if isfield(cfg.vline_style, 'width'); vl_width = cfg.vline_style.width; end
    end
    if ~exist('vl_col', 'var'), vl_col = repmat({'k'},1,numel(vl)); end
    if ~exist('vl_width', 'var'), vl_width = repmat(3,1,numel(vl)); end
    
    for i = 1:numel(vl) % plot lines
        plot(repmat(vl(i),1,2),[max(freq4P.freq)+0.5 0.5], 'color', vl_col{i}, 'lineWidth', vl_width(i))
    end
end

%% plot colorbar
if plot_colorbar == 1
    colorbar
end
%% change color limits and fontsize
set(gca, 'Clim', maxZ, 'FontSize', fontsize)

