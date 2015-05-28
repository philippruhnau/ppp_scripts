function EEG = eeg_trigchange(EEG, position, relation) %old_trig, new_trig, position)

% eeg_change_trigger(EEG, old_trig, new_trig, postition)
% changes triggers in EEGLAB files
% Input:
% EEG      - data file
% plus either field 2 or 3
% Field 2) position
% use second field to change a trigger at a position (offset) before/after 
% a specified trigger (position.old_trig)
% position.old_trig - find this trigger
% position.new_trig - new trigger name
% position.offset   - offset of old_trigger to a specific (to be changed) 
%                     trigger (1 means change the trigger AFTER old_trig, 
%                     -1 means change the trigger BEFORE old_trig, 0 means 
%                     change old_trig)
%
% Field 3) relation
% use third field to change a trigger at a position (offset) before/after a 
% specified trigger (relation.old_trig), but only if it is
% relation.rel_trig (e.g., useful when one wants to use trials with a correct
% response)
%
% relation.old_trig - find this trigger
% relation.new_trig - new trigger name
% relation.offset   - offset of old_trigger to a specific (to be changed) 
%                     trigger (1 means change the trigger AFTER old_trig, 
%                     -1 means change the trigger BEFORE old_trig, 0 means 
%                     change old_trig)
% relation.rel_trig - only change trigger at offset if it is this one
%
% Output:
%
% EEG      - changed EEG struct
%
% former version was eeg_change_trigger (deprecated)
%

% ------------------------------------------------------------------------
% P. Ruhnau, email: mail@philipp-ruhnau.de, 2012-07-03
%
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


if nargin < 3 
old_trig = position.old_trig;
new_trig = position.new_trig;
offset   = position.offset;
else % if there is a third input, relation mode (#2 ) is assumed
old_trig = relation.old_trig;
new_trig = relation.new_trig;
offset   = relation.offset;
rel_trig = relation.rel_trig;
end

% define loop size (cannot look for trigger after/before the end/beginning of the array)
if offset < 0
    loopsize = 1-offset :size(EEG.event,2) + offset;
else 
    loopsize = 1+offset :size(EEG.event,2) - offset;
end

% define counter of changes
count = 0;

for i = loopsize
    
    if ~exist('rel_trig', 'var')
        % if old_trig is found change trigger at offset position to new_trig
        if strcmp(EEG.event(i-offset).type, old_trig)
           EEG.event(i).type = new_trig;
           count = count+1;
        end
    else
        % if old_trig is found change trigger at offset position to
        % new_trig, but only if it is rel_trig
        if strcmp(EEG.event(i-offset).type, old_trig) && strcmp(EEG.event(i).type, rel_trig)
           EEG.event(i).type = new_trig;
           count = count+1;
        end
    end
    
    
end

disp('')
disp(['Number of changed triggers: ' num2str(count) ' -----'])
disp('')

