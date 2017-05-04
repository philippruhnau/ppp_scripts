function [trl] = ft_trialfun_tacs(cfg)

% FT_TRIALFUN_tacs
%
% this trialfun aligns non-overlapping epochs to either peaks or throughs
% in a TACS stimulation dataset or 
% cuts out consecutive non-overlapping epochs from any dataset (nostim)
%
% input:
% cfg.datafile   = pointer to MEG data file
% cfg.headerfile = per default same as cfg.datafile (for NEUROMAG fine), 
%                  otherwise pointer to MEG file header
%
% cfg.trialdef.eventtype  = string, channel to be used for alignment
%                          (default: 'MEG0742' - central gradiometer)
% cfg.trialdef.eventvalue = 'peak', 'trough', or 'nostim'; default: 'peak'
% cfg.threshold           = cutoff value for the peak/trough extraction, 
%                           default: estimated from the data (median)
%
%

% defaults
cfg.headerfile = ft_getopt(cfg, 'headerfile', cfg.datafile);
cfg.trialdef = ft_getopt(cfg, 'trialdef', []); % create trialdef if not present
cfg.trialdef.eventtype  = ft_getopt(cfg.trialdef, 'eventtype', 'MEG0742');
cfg.trialdef.eventvalue =  ft_getopt(cfg.trialdef , 'eventvalue', 'peak');


% read the header and determine the channel number corresponding with the EMG
hdr         = ft_read_header(cfg.headerfile, 'checkmaxfilter', 0);
chanindx    = find(strcmp(cfg.trialdef.eventtype, hdr.label));

if length(chanindx)>1
  error('only one MEG channel supported');
end

% read all data of the MEG channel, assume continuous file format
begsample = 1;
endsample = hdr.nSamples*hdr.nTrials;
meg       = ft_read_data(cfg.datafile, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx, 'checkmaxfilter', 0);



% find all the local peaks/troughs
if strcmp(cfg.trialdef.eventvalue, 'peak')
  % if no threshold is predefined do it data driven
  cfg.threshold  = ft_getopt(cfg, 'threshold', median(meg(meg > mean(meg(:)))));
  % get peaks
  [peaks,allIdx]=findpeaks(meg,'MINPEAKHEIGHT',cfg.threshold);
elseif strcmp(cfg.trialdef.eventvalue, 'trough')
   % if no threshold is predefined do it data driven
  cfg.threshold  = ft_getopt(cfg, 'threshold', median(abs(meg(meg < mean(meg(:))))));
  % get troughs
  [troughs,allIdx] = findpeaks(-meg,'MINPEAKHEIGHT',cfg.threshold);
elseif strcmp(cfg.trialdef.eventvalue, 'nostim') % if no stimulation take all samples
  allIdx = 1:length(meg);
end

% pick only non-overlapping epochs
% epoch onset interval in samples
EOI = hdr.Fs*sum([cfg.trialdef.prestim,cfg.trialdef.poststim]);

% reduce original idices to area that can host prestim and poststim time
allIdx = allIdx(allIdx > hdr.Fs*cfg.trialdef.prestim+1 & allIdx < hdr.nSamples - hdr.Fs*cfg.trialdef.poststim);

% now check successively if the next index is further away then the
% specified epoch length and take the first that is
i = 1; % new index counter
ii = 1; % old index counter
idx = allIdx(i);

% now loop as long as indeces in data 
while ii < numel(allIdx)
  if idx(i) + EOI < allIdx(ii)
    idx = [idx; allIdx(ii)];
    i = i + 1;
  else
    ii = ii + 1;
  end
end


% build trl
trl(:,1) = idx' - hdr.Fs*cfg.trialdef.prestim;
trl(:,2) = idx' + hdr.Fs*cfg.trialdef.poststim;
trl(:,3) = -(hdr.Fs*cfg.trialdef.prestim);


