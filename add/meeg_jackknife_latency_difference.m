function latency = meeg_jackknife_latency_difference(cfg)

% latency = meeg_jackknife_latency_difference(cfg)
%
% Input, e.g. (defaults):
%	cfg.data       = []; % channels x time x con x subj
%	cfg.time       = [-100 : 400];
%	cfg.type       = 'rms'; % 'rms' or 'abs' or 'none'
%	cfg.timelim    = [100 200]; % times in and out, used to find peak
%	cfg.tvariance  = 50; % in ms, time variance used for finding the individual peaks
%	cfg.frequency  = 1000; % sampling frequency of the data
%	cfg.baseline   = 100; % time window of the baseline
%	cfg.polarity   = 1; % 1 - find maximum, -1 - find minimum
%
% Output:
%	latency.overall    - grand latency over subjects for each condition
%	latency.combs      - all possible combinations of two-paired tests
%	latency.diff       - latency differences for all possible combinations of two-paired tests
%	latency.sta_error  - standard error for each of the combinations
%	latency.tststa     - t-value for each of the combinations
%	latency.p_val      - p-value for each of the combinations
%
% -------------------------------------------------------------------------------------------
% This programm uses the jackknife approach described by Miller et al. (1998) Psychophysiology, 35:99-115
% and reviewed by Miller et al. (2009), Psychophysiology, 46:300-312
% It compares two conditions
% copyright (c) 2010, Björn Herrmann, Email: bherrmann@cbs.mpg.de, 2010-01-24

% Load defaults if appropriate
% ----------------------------
fs = filesep;
if ~isfield(cfg, 'data'),      fprintf('Error: cfg.data needs to be defined.\n'); return; end
if size(cfg.data,3) < 2,       fprintf('Error: At least two conditions are needed in cfg.data.\n'); return; end
if ~isfield(cfg, 'type'),      cfg.type      = 'rms'; end
if ~isfield(cfg, 'time'),      cfg.time      = [1:size(cfg.data,3)]; end
if ~isfield(cfg, 'timelim'),   cfg.timelim   = [100 200]; end
if ~isfield(cfg, 'tvariance'), cfg.tvariance = 50; end
if ~isfield(cfg, 'frequency'), cfg.frequency = 1000; end
if ~isfield(cfg, 'baseline'),  cfg.baseline  = 100; end
if ~isfield(cfg, 'polarity'),  cfg.polarity  = 1; end


N  = size(cfg.data,4); % number of subjects
df = N - 1; % degrees of freedom


% Get average for the channels
% ----------------------------
for c = 1 : size(cfg.data,3)
	if strcmp(cfg.type, 'none')
		D(:,c,:) = mean(cfg.data(:,:,c,:), 1);
	elseif strcmp(cfg.type, 'abs')
		D(:,:,:) = mean(abs(cfg.data(:,:,c,:)), 1);
	elseif strcmp(cfg.type, 'rms')
		D(:,c,:) = sqrt(mean(cfg.data(:,:,c,:) .^ 2, 1));
	end
end


% Get time range to look for the peak
% -----------------------------------
tin  = (cfg.baseline / (1000 / cfg.frequency)) + (cfg.timelim(1) / (1000 / cfg.frequency)) + 1;
tout = (cfg.baseline / (1000 / cfg.frequency)) + (cfg.timelim(2) / (1000 / cfg.frequency)) + 1;
tvar = round(cfg.tvariance / (1000 / cfg.frequency));

% Get peak maximum/minimum in defined time window of time course (grand avr)
% --------------------------------------------------------------------------
Dm = mean(D,3);
for c = 1 : size(Dm,2)
	if cfg.polarity == 1
		[t peak_idx] = max(Dm(tin:tout,c));
	elseif cfg.polarity == -1
		[t peak_idx] = min(Dm(tin:tout,c));
	end
	
	% Get latency in ms over subjects
	% -------------------------------
	cpeak(c) = tin + peak_idx - 1;
	latency.overall(c) = ((cpeak(c) - 1) * (1000 / cfg.frequency)) - cfg.baseline;
end


% Get possible two-paired combinations
% ------------------------------------
latency.combs = nchoosek([1:size(cfg.data,3)],2);


% Do all possible two-paired combinations
% ---------------------------------------
for i = 1 : size(latency.combs,1)
	% Get overall latency difference
	% ------------------------------
	latency.diff(i,1) = latency.overall(latency.combs(i,1)) - latency.overall(latency.combs(i,2));

	% Get latency difference for all subsets
	% --------------------------------------
	latdif = [];
	for s = 1 : N
		tlim1 = [cpeak(latency.combs(i,1)) - tvar, cpeak(latency.combs(i,1)) + tvar];
		tlim2 = [cpeak(latency.combs(i,2)) - tvar, cpeak(latency.combs(i,2)) + tvar];
			
		% Get data for each subset
		% ------------------------
		wsubs = [1:N] ~= s;
		Di = mean(D(:,:,wsubs),3);

		% Get peak maximum/minimum at peak +- tvariance
		% ---------------------------------------------
		if cfg.polarity == 1
			[t peak_idx(1)] = max(Di(tlim1(1):tlim1(2), latency.combs(i,1)));
			[t peak_idx(2)] = max(Di(tlim2(1):tlim2(2), latency.combs(i,2)));
		elseif cfg.polarity == -1
			[t peak_idx(1)] = min(Di(tlim1(1):tlim1(2), latency.combs(i,1)));
			[t peak_idx(2)] = min(Di(tlim2(1):tlim2(2), latency.combs(i,2)));
		end
	
		% Get latency in ms for the subset
		% --------------------------------
		latdif(s) = ((((tlim1(1) + peak_idx(1) - 1) - 1) * (1000 / cfg.frequency)) - cfg.baseline) - ((((tlim2(1) + peak_idx(2) - 1) - 1) * (1000 / cfg.frequency)) - cfg.baseline);
	end
	
	% Compute standard error
	% ----------------------
	latency.sta_error(i,1) = sqrt((N-1)/N * sum((latdif - mean(latdif)).^2));
	latency.tstats(i,1)    = latency.diff(i,1) / latency.sta_error(i,1);
	latency.p_val(i,1)     = 1 - tcdf(abs(latency.tstats(i,1)),df);
end

return;
