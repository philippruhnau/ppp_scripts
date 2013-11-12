function [EEG] = eeg_decell(EEG, latency)

% function [EEG] = eeg_decell(EEG, latency)
% Converts epoch information (from cell to string/double)
% erases nondesired trigger information within single epochs (also from
% EEG.event fields)
% 
% optional input
% latency - latency of trigger that should remain in epoch (default: 0)

% (c) copyright P.Ruhnau, e-mail: philipp.ruhnau@unitn.it, 2012
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

% version: 2010-06-30 - initial implementation PR
% version: 2012-06-26 - now also modifies EEG.event; PR
 
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