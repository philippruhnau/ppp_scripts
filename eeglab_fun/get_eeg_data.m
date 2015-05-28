function data_selection = get_eeg_data(EEG, channels, output, group)


% function data_selection = get_eeg_data(EEG, channels, output, group)
%
% selects data of specified channels (ordered as the input) from EEGLAB
% structure
%
% can average over subjects
% can average over specified channel groups
%
% mandatory input:
%
% EEG       - struct from EEGLAB (grand-avg data)
% channels  - channel selection, either numeric or cell of strings
%
% optional input:
%
% output    - either 'sub' for subjects or 'gm'  for grand-mean
%             default: 'gm'
% group     - vector from 1 to N indicating to be averaged channels,
%             default: no averaging
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copyright (c), 2011, P. Ruhnau, email: mail@philipp-ruhnau.de, 2011-08
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

if nargin < 1, help get_eeg_data; return; end
if ~exist('channels', 'var'),  error('Variable ''channels'' is needed'); end
if nargin < 3, output ='gm'; end

set_channels = zeros(1,numel(channels));

[t ch_names actCha cellInd] = eeg_channels(EEG.chanlocs, channels);
if numel(ch_names) < numel(actCha)
    set_channels(:) = cellInd(cellInd ~=0); % 0 indicates that channel (name/coordinates) is not in eeg_channels
elseif  ~isnumeric(channels)
    set_channels(:) = cellInd(cellInd ~=0);
end


if ~exist('group', 'var')
    if strcmp(output, 'gm')
        data_selection = mean(EEG.data(set_channels,:,:),3);
    elseif strcmp(output, 'sub')
        data_selection = EEG.data(set_channels,:,:);
    end
else % when mean of channel groups is desired
    
    selection = EEG.data(set_channels,:,:);
    if strcmp(output, 'gm')
        data_selection = zeros(numel(unique(group)),size(selection,2));
        for i = 1: numel(unique(group))
            data_selection(i,:,:) = mean(mean(selection((group == i)', :,:),1),3);
        end
    elseif strcmp(output, 'sub')
        data_selection = zeros(numel(unique(group)),size(selection,2), size(selection,3));
        for i = 1: numel(unique(group))
            data_selection(i,:,:) = mean(selection((group == i)', :,:),1);
        end
    end
    
end
