function [EEG] = eeg_decell(EEG, latency)
% Converts epoch information (from cell to string/double)
% erases nondesired trigger information within single epochs (now also from
% EEG.event fields)
% 
% optional input
% latency - latency of trigger that should remain in epoch (default: 0)
% version: 2010-06-30; PR
% now also modifies EEG.event
% version: 2012-06-26; PR
 
if nargin < 2
    latency = 0;
end

cha_eve = [];
for iEpoch= 1:size(EEG.epoch,2)
    % in case EEG.epoch is a cell and 2 event types in epoch (in fact the
    % second requires the latter
    if iscell(EEG.epoch(iEpoch).eventtype) && numel(EEG.epoch(iEpoch).eventtype) > 1
        for iCode = 1:size(EEG.epoch(iEpoch).eventlatency,2) 
            % find event at desired latency and to be removed event(s)
            rmCode = [];
            if EEG.epoch(iEpoch).eventlatency{iCode} == latency
                changeCode = iCode;
            elseif EEG.epoch(iEpoch).eventlatency{iCode} ~= latency
                rmCode = [rmCode iCode];
            end
        end
        % collect indizes of events to remove at the end
        cha_eve = [cha_eve; EEG.epoch(iEpoch).event(rmCode)'];

        % change EEG epoch
        EEG.epoch(iEpoch).event = EEG.epoch(iEpoch).event(changeCode);
        EEG.epoch(iEpoch).eventlatency = EEG.epoch(iEpoch).eventlatency{changeCode};
        EEG.epoch(iEpoch).eventtype = EEG.epoch(iEpoch).eventtype{changeCode};
        EEG.epoch(iEpoch).eventurevent = EEG.epoch(iEpoch).eventurevent{changeCode};
        
    elseif iscell(EEG.epoch(iEpoch).eventtype) % if EEG.epoch is cell but only one event type
        EEG.epoch(iEpoch).event = EEG.epoch(iEpoch).event(1);
        EEG.epoch(iEpoch).eventlatency = EEG.epoch(iEpoch).eventlatency{1};
        EEG.epoch(iEpoch).eventtype = EEG.epoch(iEpoch).eventtype{1};
        EEG.epoch(iEpoch).eventurevent = EEG.epoch(iEpoch).eventurevent{1};
%     else % I have no idea, what this option was for, it changes nothing
%         EEG.epoch(iEpoch).event = EEG.epoch(iEpoch).event(1:end);
%         EEG.epoch(iEpoch).eventlatency = EEG.epoch(iEpoch).eventlatency(1:end);
%         EEG.epoch(iEpoch).eventtype = EEG.epoch(iEpoch).eventtype(1:end);
%         EEG.epoch(iEpoch).eventurevent = EEG.epoch(iEpoch).eventurevent(1:end);
    end
end

% remove events that are not at point zero in epochs from event struct 
for i = flipud(cha_eve)
   EEG.event(i) = [];
end