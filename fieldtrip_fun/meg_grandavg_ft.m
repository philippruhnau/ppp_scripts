function [data_ga] = meg_grandavg_ft(cfg)
% function meg_grandavg_ft(cfg)
% grandaverages fieldtrip structs across subjects
%
% input (for now):
%
% cfg.fnames   - cell of strings, file names to be averaged
% cfg.outfile  - string, where to save the grand average [if empty nothing saved]
% cfg.datatype - defines the type of data for now: 'erf', 'pow', 'fourier',
%                'fourier_pbi', or 'zscore'
% cfg.cond     - cell array of condition triggers (:,1) and names (:,2)
%                (e.g. {[11 12], 'ud'... % undetected
%                       [41 42], 'dd'}; % detected)
% cfg.combinegrads - true if neuromag sensor data and combination of planar
%                    gradiometers is desired [true]
% cfg.preproc     - options according to ft_preprocessing (filtering and
%                   such)
% cfg.fixchannels - 0 or 1 [0] usind obob_fixchannels 
% cfg.latency     - select a latency of the input data
% 
%
% output:
%
% data_ga      - grandaverage struct with fields for each condition (second
%                column in cfg.cond)

% startup

%% defaults
if ~isfield(cfg, 'fnames'), error('cfg.fnames is obligatory'); else fnames = cfg.fnames; end
if ~isfield(cfg, 'combinegrads'), combinegrads = true; else combinegrads = cfg.combinegrads; end
if ~isfield(cfg, 'fixchannels'), fixchannels = false; else fixchannels =  cfg.fixchannels; end
if ~isfield(cfg, 'preproc'), preproc = []; else preproc = cfg.preproc; end
if ~isfield(cfg, 'latency'), latency = []; else latency = cfg.latency; end
if ~isfield(cfg, 'outfile'), outfile = []; else outfile = cfg.outfile; end

%% from input [defaults]
ind = ['_' cfg.datatype];% 'pow'; 'fourier'; 'erf'; 'pbi'; 'zscore'

if isfield(cfg, 'cond')
    cond = cfg.cond;
else % pr defaults
    cond = {[11 12], 'ud';... %undetected
        [41 42], 'dd';...%detected
        [51 52], 'ca'}; % catch
end

%% from input
if strcmp(ind, '_pow')
    parameter = 'powspctrm';
elseif strcmp(ind, '_fourier')
    parameter = 'fourierspctrm';
elseif strcmp (ind, '_fourier_pbi');
    parameter = 'pbi';
elseif strcmp (ind, '_zscore');
    parameter = 'zval';
elseif strcmp(ind, '_erf')
    parameter = 'trial';
else
    error('unknownData:meg_gavg', ['cfg.datatype is either undefined or contains wrong datatype \nsupported options are: '...
        '''erf'', ''pow'', ''fourier'', ''fourier_pbi'', or ''zscore'' '])
end


%% load subs, planar gradient, and extract conditions
data = cell(1,numel(fnames));
for iSub = 1:numel(fnames)
  
  %% load file
    disp('=------------------=')
    disp(['Loading: ' fnames{iSub}])
    disp('=------------------=')
    data{iSub} = load(fnames{iSub});
    
    %% some optional preprocessing steps
    % preprocessing if wanted
    if ~isempty(preproc)
      cfg_fi = preproc;
      data{iSub} = ft_preprocessing(cfg_fi, data{iSub});
    end
   
    % select time window
    if ~isempty(latency)
      cfg = [];
      cfg.latency = latency;
      data{iSub} = ft_selectdata(cfg, data{iSub});
    end
    
    % fix removed channels if wanted, might be necessary for combinegrads
    if fixchannels
      data{iSub}.hdr.label = data{iSub}.grad.label;
      data{iSub} = obob_fixchannels([], data{iSub});
    end
    
    % make matrix out of cell array for easier handling
    if iscell(data{iSub}.trial) 
      cfg_tl = [];
      cfg_tl.keeptrials = 'yes';
      cfg_tl.vartrllength  = 2; % just in case the trials have different length, keep it all
      data{iSub} = ft_timelockanalysis(cfg_tl, data{iSub});
    end
    
    %% do the averaging
    % phase bifurcation and zscore are already averaged across trials
    % (resp. difference measures), thus, only sub-averaging and combining
    % grads per condition when these two are NOT present
    if ~any(isfield(data{iSub}, {'pbi' 'zval'}))
        for iCond = 1:size(cond,1)
            indx = ismember(data{iSub}.trialinfo(:,1), cond{iCond,1});
            temp = data{iSub}.(parameter)(indx,:,:,:); % collect trials
            if numel(size(temp)) > 2 % reduce to 2/3 dimensions if not already done
                temp = squeeze(mean(temp,1)); % average
            end
            data{iSub}.(cond{iCond,2})  = temp;
            clear temp
        end
        % now do avg over all stimuli (should have been done already for pbi
        % and zscore)
        data{iSub}.(parameter) = squeeze(mean(data{iSub}.(parameter),1));
        
        
        % remove trial field if present (otherwise combineplanar might crash,
        % assuming single trial data) this holds for erf data
        if isfield(data{iSub}, 'trial')
            data{iSub}.avg =  data{iSub}.trial;
            data{iSub} = rmfield(data{iSub}, 'trial');
        end % if
        
        %% dimensions have changed
        if strcmp(ind, '_erf')
            data{iSub}.dimord = 'chan_time';
        else % so far all other options are in freq-space (keep in mind!)
            data{iSub}.dimord = 'chan_freq_time';
        end % if
        
        if combinegrads
            %% combine grads
            % has to be done for each field independently (see below)
            
            % save temporary structure for later field combining before combining
            % (keep grad and labelfield intact)
            temp = data{iSub};
             
            % combineplanar removes all 'non-fitting' fields, thus keep
            % them
            temp_orig = data{iSub};
            
            % now for average (avg, powspctrm, fourierspctrm)
            cfg = [];
            if isfield(data{iSub}, 'fourierspctrm')
                cfg.combinemethod = 'svd'; % for complex data change combination method
            end % if
            data{iSub} = ft_combineplanar(cfg,data{iSub});
            
            %catch if freq or erf data (which field to fill in next step
            if isfield(data{iSub}, 'avg')
                avg_par = 'avg'; % erfs are put in avg field
            elseif isfield(data{iSub}, 'powspctrm')
                avg_par = 'powspctrm'; % all others are
            elseif isfield(data{iSub}, 'fourierspctrm')
                avg_par = 'fourierspctrm'; % all others are
            end % if
            
            % now combine grads for each other field
            for iCond = 1:size(cond,1)
                % fill each field seperatedly in avg field
                temp.(avg_par) = temp_orig.(cond{iCond,2});
                % combine
                cfg = [];
                if isfield(data{iSub}, 'fourierspctrm')
                    cfg.combinemethod = 'svd'; % for complex data change combination method
                end % if
                temp1  = ft_combineplanar(cfg, temp);
                % put back in original
                data{iSub}.(cond{iCond,2}) = temp1.(avg_par);
                clear temp1
            end % for
        end % if
        clear temp
    end % if
end % for


%% do the grandaverage
cfg = [];
cfg.keepindividual = 'yes';
if isfield(data{iSub}, 'avg') % change
    % the parameter from trial to avg!!! (otherwise grandaveraging below
    % fails) this is because fieldtrip guys are simply no erf guys and the
    % usage is inconsistent between tf and erf data!
    parameter = 'avg';
end
if ~any(isfield(data{iSub}, {'pbi' 'zval'})) % phase bifurcation and zscore are already averaged across trials (resp. difference measures)
    cfg.parameter = [{parameter} cond(:,2)'];
elseif isfield(data{iSub}, 'zval')
    cfg.parameter = [{parameter} {'pval'}];
else
    cfg.parameter = parameter;
end
% now do specific averaging
if strcmp(ind, '_erf')
    % take the first parameter as basis (should be all trials)
    data_ga = ft_timelockgrandaverage(cfg, data{:});
    if numel(cfg.parameter) >1
        paramArray = cfg.parameter;
        for i = 2:numel(paramArray)
            % average other parameters (ft_timelockgrandaverage does not
            % support averaging different parameters, dah...)
            cfg.parameter = paramArray{i};
            data_temp = ft_timelockgrandaverage(cfg, data{:});
            data_ga.(cfg.parameter) =    data_temp.individual;
        end
    end
else
    data_ga = ft_freqgrandaverage(cfg, data{:});
end

% remove cfg, cause single subs in there somewhere...
data_ga = rmfield(data_ga, 'cfg');

%% save
if ~isempty(outfile)
  disp(['Saving: ' outfile])
  save(outfile, '-struct', 'data_ga')
end

