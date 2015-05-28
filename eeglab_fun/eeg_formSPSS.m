% eeg_formSPSS(cfg) puts out a preformatted file for SPSS
%
% For grandaverage files that need to be transformed into a matrix that can be easily fitted into SPSS.
% Between subject factors are sorted in rows and get a variable coding the steps numerically. Within
% subject factors get seperate rows, variablenames on top of each row.
%
% CAVE : files have to be named in such manner:
% expShortName_betweenSubjectFactor_withinSubjectFactor_filter_baseline_reference.set
% (of course each part may be blank, except expShortName)
% and have to be placed in grand-avg\ folder
%
% CAVE2 : electrodes are WITHIN subject factor, the output here is in
% rows (ergo as BETWEEN factor)! Handling easy in SPSS via filters or restructuring.
%
% Input arguments:
%
% eeg_formSPSS(cfg)
% 
% mandatory:
% ---------
% 
% cfg.name : experiment short name
% cfg.path : experiment path name, default : current directory
% cfg.twin : N by 2 matrix [190 210; 250 300]
%
%
% optional:
% --------
% cfg.btwSub   : cell of btween subject factors {'a', 'c'}; default: empty;
% cfg.witSub   : cell of within subject factors {'hil', 'lol'}; default: empty;
% cfg.filter   : string, filter name; default: empty;
% cfg.bl       : string, baseline name; default: empty;
% cfg.ref      : string containing reference; default: empty;
% cfg.chan     : vector containing relevant channels, or 'all', default 'all';
% cfg.saveName : name of to be saved file, if empty nothing is saved
%

% 12341234123412341234123412341234123412341234123412341324134134
% Copyright (c) 2010, Philipp Ruhnau, email: ruhnau@uni-leipzig.de, 2010-07-06


function [COND] = eeg_formSPSS(cfg)



% defaults and formats
if nargin < 1, help eeg_formSPSS; return; end
if ~isfield(cfg, 'name'),  error('Short name of experiment would be a great help!'); end
if ~isfield(cfg, 'twin'), error('No windows defined!'); end
if ~isfield(cfg, 'path'),   pathName = cd;     else  pathName = cfg.path; end
if ~isfield(cfg, 'filter'), filtName = '';     else  filtName = [ '_' cfg.filter]; end
if ~isfield(cfg, 'bl'), blName = '';        else  blName = ['_' cfg.bl]; end
if ~isfield(cfg, 'btwSub'), bSub = {''};       else  for i = 1:numel(cfg.btwSub), bSub{i} = {['_' cfg.btwSub{i}]}; end, end
if ~isfield(cfg, 'witSub'), wSub = {''};	   else for i = 1:numel(cfg.witSub), wSub{i} = {['_' cfg.witSub{i}]}; end, end
if ~isfield(cfg, 'ref'), refName = '';        else  refName = ['_' cfg.ref]; end



for ibS = 1:length(cfg.btwSub)
    for iwS = 1:length(cfg.witSub)

        % load ERP data
        % -------------
        EEG = pop_loadset( 'filename', strcat(cfg.name, bSub{ibS}, wSub{iwS}, filtName, blName, refName,'.set'),...
            'filepath', fullfile(pathName, 'grand-avg'));
        EEG = eeg_checkset( EEG );

        % define channel selection
        % ------------------------
        if ~isfield(cfg, 'channels'); chanArray = 1:EEG.nbchan; 
        elseif ~isnumeric(cfg.channels)
        [~, ~, ~, chanNr] = eeg_channels(EEG.chanlocs, cfg.channels);
        chanArray = chanNr;
        else
           chanArray = cfg.channels; 
        end

        % Calculate datapoints out of latency
        % -----------------------------------
        poinArray = ceil((cfg.twin/1000 - EEG.xmin) * EEG.srate);

        for iPoin = 1:size(poinArray, 1)
            %data average
            if numel(chanArray) > 1
                COND{ibS,iwS}.data(:,:,iPoin) = (squeeze(mean(EEG.data(chanArray,poinArray(iPoin,1):poinArray(iPoin,2),:),2)))';
            else
                COND{ibS,iwS}.data(:,:,iPoin) = (squeeze(mean(EEG.data(chanArray,poinArray(iPoin,1):poinArray(iPoin,2),:),2)));
            end
            COND{ibS,iwS}.name{iPoin} = strcat(cfg.name, bSub{ibS}{1}, wSub{iwS}{1});
            COND{ibS,iwS}.latency{iPoin} = strcat(num2str(cfg.twin(iPoin,1),'%03d'), '-', num2str(cfg.twin(iPoin,2)));
            COND{ibS,iwS}.nave = size(COND{ibS,iwS}(1).data,1);
        end
        clear EEG
    end
end


% Computing merged struct
% -----------------------

COND{ibS+1, iwS+1}.name = 'statistical matrix';
COND{end}.mat = [];
COND{end}.indx = [];
COND{end}.format = [];

% Defining numeric labels
% -----------------------
bSLabel = []; subjNr = []; el = [];


for ibSLabel = 1:numel(cfg.btwSub) % labeling the between subject conditions (min 1 of course)
    disp(['------- Please check: Value for ' cfg.btwSub{ibSLabel} ' is ' num2str(ibSLabel) '! ----------'])
    el =  [el; reshape(repmat(chanArray,COND{ibSLabel,1}.nave,1),COND{ibSLabel,1}.nave*numel(chanArray),1)]; % Electrode label numbers
    bSLabel = [bSLabel; repmat(ones(COND{ibSLabel,1}.nave,1),size(chanArray,2),1) + ibSLabel-1];
    subjNr = [subjNr; (repmat((1:COND{ibSLabel,1}.nave), 1,size(chanArray,2))')] ;% Subject numbers
end


betMat = []; 
% Loop thru data and collect all conditions in one matrix
for ibS = 1: numel(cfg.btwSub)
    witMat = [];
    for iwS = 1 : numel(cfg.witSub)
        witMat = [witMat, reshape(COND{ibS,iwS}.data,COND{ibS,iwS}.nave*numel(cfg.channels),size(cfg.twin,1))];
    end
    betMat = [betMat; witMat];
end
    
 
% complete matrix containing btwSubject label, subjNr, electrodeNr and
% data
COND{end}.mat = [bSLabel subjNr el betMat];

% Names and format for within subj factors and timewindows, only for the
% data, not first three rows
for iwS = 1 : numel(cfg.witSub)
    for iPoin = 1 : size(poinArray, 1)
        
        COND{end}.format = [COND{end}.format '%05.4f\t']; % saving format for fprintf
        t4 = [cfg.witSub{iwS} '_' COND{ibS,iwS}.latency{iPoin} '\t'];
        COND{end}.indx = [COND{end}.indx, t4];
    end
end



controlbar(COND{end}.mat, numel(cfg.btwSub), numel(cfg.witSub), size(cfg.twin,1))




%% Saving
%% ------
if isfield(cfg, 'saveName')
    fid = fopen([cfg.saveName '.mat'], 'w+');
    disp(['!!! Saving ' cfg.saveName '.mat !!!']);
    fprintf(fid, '%s\t%s\t%s\t', 'condition', 'subject', 'electrode');
    fprintf(fid, COND{end}.indx');
    fprintf(fid,['\n%2d\t%2d\t%2d\t' COND{end}.format],  COND{end}.mat');
    fclose(fid);
end

% 
% data = COND{end}.mat
% btwGroups = numel(cfg.btwSub);
% witGroups = numel(cfg.witSub);
% windows = size(cfg.twin,1);

function controlbar(data, btwGroups, witGroups, windows, caption)
% shows mean amplitude bars for data input, averaged over CHANNELS!


for c = 1:btwGroups, barStr{c} = [];end

data_start = 3; % first 3 rows in data are index variables


for iB = 1:btwGroups
    for iT = 1:windows
        bar_indx = [];
        for iW = 1:witGroups
            bar_indx(iW) = iT + windows*(iW-1);
        end
        
        if isempty(barStr{iB})
            barStr{iB} = [barStr{iB} 'mean(data(data(:,1) == ' num2str(iB) ', [', num2str(bar_indx+data_start), ']))'];
        else % starts at second step
            barStr{iB} = strcat(barStr{iB}, strcat('; mean(data(data(:,1) == ', num2str(iB), ',',...
                '[', num2str(bar_indx+data_start), ']))'));
        end
    end
end


% mean(data(data(:,1) == 1,4:5)); mean(data(data(:,1) ==1,6:7)); mean(data(data(:,1) ==1,8:9))

if size(barStr,2) == 1
    for iPlot = 1 : size(barStr,2)
        figure
        eval(['bar([' barStr{iPlot} '])'])
        hold on
        set(gca, 'FontSize', 15)
        xlabel('Numbers are time-windows, singel bars within factor steps')
        ylabel('Amplitude [\muV]')
        if nargin > 4, title([caption 'condition ' num2str(iPlot)]);
        else title(['Between Subject Condition ' num2str(iPlot)]); end
    end
elseif size(barStr,2) > 4
    figure;
    for iPlot = 1 : size(barStr,2)
        subplot(1,size(barStr,2),iPlot);
        eval(['bar([' barStr{iPlot} '])'])
        hold on
        set(gca, 'FontSize', 15)
        xlabel('Numbers are time-windows, singel bars within factor steps')
        ylabel('Amplitude [\muV]')
        if nargin > 4, title([caption 'condition ' num2str(iPlot)]);
        else title(['Between Subject Condition ' num2str(iPlot)]); end
    end
else
    figure;
    for iPlot = 1 : size(barStr,2)
        subplot(ceil(size(barStr,2)/2),2,iPlot);
        eval(['bar([' barStr{iPlot} '])'])
        hold on
        set(gca, 'FontSize', 15)
        xlabel('Numbers are time-windows, singel bars within factor steps')
        ylabel('Amplitude in [\muV]')
        if nargin > 4, title([caption 'condition ' num2str(iPlot)]);
        else title(['Between Subject Condition ' num2str(iPlot)]); end
    end
end
