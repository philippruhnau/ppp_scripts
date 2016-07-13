function [latency, grandmean] = meeg_latencies(cfg)

% [latency, grandmean] = MEEG_LATENCIES(cfg)
% Finds peak maximum/minimum amplitude and respective latency
% CAVE: within sub conditions must be the same in all between sub groups
%
% Mandatory Input:
%
% cfg.data     - {channels x timepoints x subs x within conds} x between
%                subject condition, there may be different n in subject
%                groups (between)
% cfg.timewin  - latency range to look for grand-avg peak
% cfg.baseline - negative value for baseline in ms
% cfg.srate    - sampling rate
%
% Optional Input [default]:
%
% cfg.path     - Experiment path, [current directory]
% cfg.dir      - 'min' or 'max', ['max']
% cfg.method   - 'peak', 'jackknife', or 'jackind' ['peak'], see comments
%                for more info
% cfg.calc     - mean calculation type: 'none', 'rms', 'abs', ['none']
% cfg.timevar  - time delay +/- peak from grandaverage peak, around
%                which peak is detected in individual subjects [50 ms]
% cfg.wscond   - within subject condition name, [w1 w2 w3 w4...]
% cfg.bscond   - between subject condition name, [b1 b2 b3 b4...]
% cfg.stafile  - place of to-be-saved file, only saved if exists
%
% Output:
%
% latency      - latency and amplitude of single subjects (saved)
%                each cell contains one between subject condition
%                every two rows (ampl+lat) contain one within subj cond
% grandmean    - grand-average values (not saved)
%
% -------------------------------------------------------------------
% - jackknifing part see Miller et al., 2009, Psychophysiology
% - individual estimates jackknifing: Smulders, 2010, Psychophysiology
% keep in mind that outliers drastically influence this step,
% also if latency estimation is not possible (e.g. no peak) this methods
% creates arbitrary results (better use jackknifing and correct F-value)

% copyright (c) P. Ruhnau, e-mail: mail@philipp-ruhnau.de, 2010-10-26
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

% defaults
if nargin<1, help meeg_latencies, return, end
if ~isfield(cfg, 'data'), error('cfg.data needs to be defined!'), end
if ~isfield(cfg, 'path'), cfg.path = cd; end
if ~isfield(cfg, 'calc'), cfg.calc = 'none'; end
if ~isfield(cfg, 'method'), cfg.method = 'peak'; end
if ~isfield(cfg, 'dir'), cfg.dir = 'max'; end
if ~isfield(cfg, 'bscond'), for iB = 1:numel(cfg.data), cfg.bscond{iB} = ['b' num2str(iB)]; end, end
if ~isfield(cfg, 'wscond'), for iW = 1:size(cfg.data{1},4), cfg.wscond{iW} = ['w' num2str(iW)]; end, end
if ~isfield(cfg, 'timevar')
    timevar = round(50*cfg.srate/1000);
else
    timevar = round(cfg.timevar*cfg.srate/1000);
end


% ms to points
twin = ceil((cfg.timewin - cfg.baseline)*cfg.srate/1000);

% run thru between subject conditions
for iB = 1:numel(cfg.data)
    %         [latency{iB}] = deal(zeros(size(cfg.data{iB},3),size(cfg.data{iB},4)*2));
    
    % grand-avg computation
    if strcmp('none', cfg.calc)
        data = squeeze(mean(cfg.data{iB},1));
    elseif strcmp('rms', cfg.calc)
        data = squeeze(sqrt(mean(cfg.data{iB}.^2,1)));
    end
    
    % grandavg peak
    if strcmp(cfg.dir, 'min')
        direction = '--------Calculating MINIMUM peak------------';
        % calculate value and index
        [gmval, gmind] = min(mean(data(twin(1):twin(2),:,:),2));
    elseif strcmp(cfg.dir, 'max')
        direction = '--------Calculating MAXIMUM peak------------';
        % calculate value and index
        [gmval, gmind] = max(mean(data(twin(1):twin(2),:,:),2));
    end
    
    % Index is used for timewindow in single subjects
    % -----------------------------------------------
    gmind = squeeze(gmind+twin(1));
    twin_ind = [gmind-timevar gmind+timevar];
    gmlat = gmind*1000/cfg.srate+cfg.baseline;
    grandmean{iB} = [gmlat squeeze(gmval)];
    
    for iW = 1:size(data,3)
        
        if strcmp(cfg.method, 'peak')
            
            if strcmp(cfg.dir, 'min')
                % calculate value and index
                [val ind] = min(data(twin_ind(iW,1):twin_ind(iW,2),:,iW));
            elseif strcmp(cfg.dir, 'max')
                % calculate value and index
                [val ind] = max(data(twin_ind(iW,1):twin_ind(iW,2),:,iW));
            end
            
            % point to ms
            lat = (ind + twin_ind(iW,1))*1000/cfg.srate + cfg.baseline;
            % final matrix containing amplitudes and latencies
            latency{iB}(:,(1:2)+2*(iW-1)) = [val' lat'];
            
        elseif strcmp(cfg.method, 'jackknife') || strcmp(cfg.method, 'jackind')
            
            % computing averages of N-minus-current
            % -------------------------------
            jmean = zeros(size(data));
            for sub = 1:size(data,2)
                n = 1:size(data,2) ~= sub;
                jmean(:,sub,:) = mean(data(:,n,:),2);
            end
            
            if strcmp(cfg.dir, 'min')
                [val, ind] = min(jmean(twin_ind(iW,1):twin_ind(iW,2),:,iW));
            elseif strcmp(cfg.dir, 'max')
                [val, ind] = max(jmean(twin_ind(iW,1):twin_ind(iW,2),:,iW));
            end
            % point to ms
            lat = (ind + twin_ind(iW,1))*1000/cfg.srate + cfg.baseline;
            % final matrix
            latency{iB}(:,(1:2)+2*(iW-1)) = [val' lat'];
            
        end
    end
    
    clear data
    
end




disp(direction)

if strcmp(cfg.method, 'jackknife')
    disp('You are currently computing jackknife latency estimates!')
    disp('Be aware that F values in ANOVAs have to be corrected (Fc = F/(n-1)^2)')
    disp('See: Ulrich & Miller, 2001, Psychophysiology')
end

% Using method by Smulders, 2010, Psychophysiology, to retrieve
% individual 'peaks'
if strcmp(cfg.method, 'jackind')
    for iB = 1:numel(latency)
        for iW = 1:size(latency{iB},2)/2
            ind_lat = latency{iB}(:,iW*2);
            n = size(ind_lat,1);
            ind_lat_mean = repmat((n*mean(ind_lat)),n,1);
            ind_lat_corr = ind_lat_mean - ((n-1) * ind_lat);
            latency{iB}(:,iW*2) = ind_lat_corr;
            clear ind_lat n ind_lat_mean ind_lat_corr
        end
    end
    disp('Estimating individal peaks from subavarage scores as described by:')
    disp('Smulders, 2010, Psychophysiology')
end

% save data condition by condition
% --------------------------------
if isfield(cfg, 'stafile')
    
    writeFile = fopen([cfg.stafile '.txt'], 'w+');
    fprintf(writeFile, '%s \t %s \t', 'group', 'sub');
    saveForm = [];
    for iW = 1:size(latency{iB},2)/2
        fprintf(writeFile, '%s \t',  [cfg.wscond{iW} '-ampl'], [cfg.wscond{iW} '-lat']);
        saveForm = [saveForm '\t %2.3f \t %3.0f '];
    end
    
    for iB = 1:numel(latency)
        
        for sub = 1:size(latency{iB},1)
            fprintf(writeFile, ['\n %s \t %02d' saveForm], cfg.bscond{iB} , sub, latency{iB}(sub,:));
        end
        
    end
end

fclose('all');