function data_selection = get_fif_data(FIF, channels, group)


% function get_fif_data(FIF, channels, output, group)
%
% selects data of specified channels (ordered as the input) from FIF
% struct (MNE, NEUROMAG)
% may average over specified channel groups
%
% mandatory input:
%
% FIF             - struct from MNE
% channels.type   - 'mag' or 'grd'
%
% optional input [defaults]:
%
% channels.region - tc   - temporal cortices
%	                one  - one region
%	                two  - two regions [default]
%	                four - four regions
%	                six  - six regions
%	                poft - parietal, occipital, frontal, temporal - neuromag arrangement
%	                ind  - define your individual selection in cfg.my_selection
%                   see documentation of fiff_sensor_rois (b.herrmann, 2010)
% group           - vector from 1 to N indicating to be averaged channels,
%                   default: no averaging
%

% copyright (c), 2011, P. Ruhnau, email: mail@philipp-ruhnau.de, 2011-08-03
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

if nargin < 2, help get_fif_data; return; end
if ~isfield(channels, 'region'), channels.region = 'two'; end


cha.roi_selection = channels.region;
cha.plot_on = 0;
roi = fiff_sensor_rois(cha);
roi_nr = roi(:,2);
idx = (1:306)';


if strcmp(channels.type, 'mag')
    ch_idx = intersect(idx(roi_nr ~= 0), idx(rem(1:306,3)==0))';
elseif strcmp(channels.type, 'grd')
    ch_idx = intersect(idx(roi_nr ~= 0),idx(rem(1:306,3)~=0))';
end


if ~exist('group', 'var')
    
    data_selection  = FIF.evoked.epochs(ch_idx,:);
    
else % when mean of channel groups is desired
    selection = FIF.evoked.epochs(ch_idx,:);
    data_selection = zeros(numel(unique(group)),size(selection,2));
    for i = 1: numel(unique(group))
        data_selection(i,:) = mean(selection((group == i)', :),1);
    end
end

