
function [coor n actCha cellInd] = eeg_channels(chaninfo, chan_sel)

% eeg_channels(chaninfo, chan_sel)
% looks up selected channel names/numbers  and coordinates for eeg-data
% Input:
% chaninfo - channel information in EEG.chanloc (eeglab), optional
% chan_sel - string or vector of numbers with channel selection
%
% Output:
% coor    - channels coordinates
% n       - cell array of channel names concordant with existing names and
%           coordinates in this file (so far 86 [10-10 system])
% actCha  - selected channels names (whole self selection)
% cellInd - indizes of concordant channels of chan_sel and channels
%           existent in this file, necesary if not matching
%

% ---------------------------------------------------
% copyright (c), 2010, P. Ruhnau, email: ruhnau@uni-leipzig.de, 2010-07-29
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

if nargin < 1, help eeg_channels; return, end

if ~isempty(chaninfo)
    actCha_check = struct2cell(chaninfo);
    actCha_check = upper(squeeze(actCha_check(1,:,:))); 
else
    actCha_check = {'FP1'    'FPZ'    'FP2'    'AF9'    'AF7'    'AF5'    'AF3'    'AF1'    'AFZ'    'AF2'    'AF4'    'AF6',...
    'AF8'    'AF10'    'F9'    'F7'    'F5'    'F3'    'F1'    'FZ'    'F2'    'F4'    'F6'    'F8'    'F10',...
    'FT9'    'FT7'    'FC5'    'FC3'    'FC1'    'FCZ'    'FC2'    'FC4'    'FC6'    'FT8'    'FT10'    'T9',...
    'T7'    'C5'    'C3'    'C1'    'CZ'    'C2'    'C4'    'C6'    'T8'    'T10'    'TP9'    'TP7'    'CP5',...
    'CP3'    'CP1'    'CPZ'    'CP2'    'CP4'    'CP6'    'TP8'    'TP10'    'P9'    'P7'    'P5'    'P3',...
    'P1'    'PZ'    'P2'    'P4'    'P6'    'P8'    'P10'    'PO9'    'PO7'    'PO5'    'PO3'    'PO1',...
    'POZ'    'PO2'    'PO4'    'PO6'    'PO8'    'PO10'    'O1'    'OZ'    'O2'    'I1'    'IZ'    'I2',...
    'VEOG'   'HEOG'};
    
end

if iscell(chan_sel)
    % checks whether wanted channels are in the data
    actCha = upper(chan_sel);
    [t cellIndA, cellIndB] = intersect(actCha_check, actCha);
    for i = 1:numel(cellIndB)
        cellInd(cellIndB(i)) = cellIndA(i); %#ok<AGROW>
    end
    actCha = actCha(cellInd~=0);
else
    % checks whether wanted channels are in the data
    actCha = upper(actCha_check(:,chan_sel));
    [t cellIndA, cellIndB] = intersect(actCha_check, actCha);
    for i = 1:numel(cellIndB)
        cellInd(cellIndB(i)) = cellIndA(i); %#ok<AGROW>
    end
end


pos = [0.3811    0.8313;    0.4800    0.8487;    0.5789    0.8314;    0.2449    0.8527;    0.2919    0.7811;    0.3361    0.7710;...
    0.3828    0.7646;    0.4311    0.7613;    0.4800    0.7602;    0.5289    0.7613;    0.5772    0.7645;    0.6238    0.7710;...
    0.6681    0.7811;    0.7151    0.8527;    0.1564    0.7549;    0.2211    0.7029;    0.2826    0.6869;    0.3472    0.6779;...
    0.4132    0.6733;    0.4800    0.6718;    0.5468    0.6733;    0.6128    0.6779;    0.6774    0.6869;    0.7389    0.7029;...
    0.8036    0.7548;    0.0995    0.6316;    0.1757    0.6042;    0.2506    0.5931;    0.3266    0.5872;    0.4032    0.5843;...
    0.4800    0.5834;    0.5568    0.5843;    0.6334    0.5872;    0.7094    0.5931;    0.7843    0.6042;    0.8605    0.6316;...
    0.0800    0.4949;    0.1600    0.4949;    0.2400    0.4949;    0.3200    0.4949;    0.4000    0.4950;    0.4800    0.4950;...
    0.5600    0.4949;    0.6400    0.4949;    0.7200    0.4949;    0.8000    0.4949;    0.8800    0.4949;    0.0995    0.3582;...
    0.1756    0.3856;    0.2506    0.3968;    0.3266    0.4027;    0.4032    0.4056;    0.4800    0.4065;    0.5568    0.4056;...
    0.6334    0.4027;    0.7094    0.3968;    0.7844    0.3856;    0.8605    0.3582;    0.1564    0.2350;    0.2211    0.2870;...
    0.2826    0.3030;    0.3471    0.3120;    0.4132    0.3167;    0.4800    0.3181;    0.5468    0.3167;    0.6129    0.3120;...
    0.6774    0.3030;    0.7389    0.2870;    0.8036    0.2350;    0.2449    0.1371;    0.2919    0.2087;    0.3361    0.2189;...
    0.3829    0.2251;    0.4311    0.2286;    0.4800    0.2296;    0.5289    0.2286;    0.5771    0.2251;    0.6239    0.2189;...
    0.6681    0.2087;    0.7151    0.1371;    0.3811    0.1585;    0.4800    0.1411;    0.5789    0.1585;    0.3564    0.0744;...
    0.4800    0.0527;    0.6036    0.0744;    0.6627    0.9035;  0.8018    0.9035; 0.1464    0.1000; 0.8136    0.1000];

% original coordinates from fieldtrip
% pos = [-0.4962    1.5271;   -0.9438    1.2990;   -0.5458    1.1705;   -0.3269    0.8091;   -0.6590    0.8138;   -0.9879    0.8588;   -1.2990    0.9438;...
%     -1.5271    0.4962;   -1.1732    0.4503;   -0.7705    0.4097;   -0.3949    0.3949;   -0.4014         0;   -0.8029         0;   -1.2043         0;...
%     -1.6057         0;   -1.5271   -0.4962;   -1.1732   -0.4503;   -0.7705   -0.4097;   -0.3949   -0.3949;   -0.3269   -0.8091;   -0.6590   -0.8138;...
%     -0.9879   -0.8588;   -1.2990   -0.9438;   -1.5375   -1.2902;   -0.9438   -1.2990;   -0.5458   -1.1705;   -0.4962   -1.5271;         0   -2.0071;...
%     0   -1.6057;         0   -1.2043;         0   -0.8029;         0   -0.4014;         0    1.6057;    0.4962    1.5271;    0.9438    1.2990;...
%     0.5458    1.1705;         0    1.2043;         0    0.8029;    0.3269    0.8091;    0.6590    0.8138;    0.9879    0.8588;    1.2990    0.9438;...
%     1.5271    0.4962;    1.1732    0.4503;    0.7705    0.4097;    0.3949    0.3949;         0    0.4014;         0         0;    0.4014         0;...
%     0.8029         0;    1.2043         0;    1.6057         0;    1.5271   -0.4962;    1.1732   -0.4503;    0.7705   -0.4097;    0.3949   -0.3949;...
%     0.3269   -0.8091;    0.6590   -0.8138;    0.9879   -0.8588;    1.2990   -0.9438;    1.5375   -1.2902;    0.9438   -1.2990;    0.5458   -1.1705;...
%     0.4962   -1.5271;       0.4962    1.9285; 0.9924    1.9285];

% M1 and M2 added at the end (change below if A1/A2)
names = {'FP1'    'FPZ'    'FP2'    'AF9'    'AF7'    'AF5'    'AF3'    'AF1'    'AFZ'    'AF2'    'AF4'    'AF6',...
    'AF8'    'AF10'    'F9'    'F7'    'F5'    'F3'    'F1'    'FZ'    'F2'    'F4'    'F6'    'F8'    'F10',...
    'FT9'    'FT7'    'FC5'    'FC3'    'FC1'    'FCZ'    'FC2'    'FC4'    'FC6'    'FT8'    'FT10'    'T9',...
    'T7'    'C5'    'C3'    'C1'    'CZ'    'C2'    'C4'    'C6'    'T8'    'T10'    'TP9'    'TP7'    'CP5',...
    'CP3'    'CP1'    'CPZ'    'CP2'    'CP4'    'CP6'    'TP8'    'TP10'    'P9'    'P7'    'P5'    'P3',...
    'P1'    'PZ'    'P2'    'P4'    'P6'    'P8'    'P10'    'PO9'    'PO7'    'PO5'    'PO3'    'PO1',...
    'POZ'    'PO2'    'PO4'    'PO6'    'PO8'    'PO10'    'O1'    'OZ'    'O2'    'I1'    'IZ'    'I2',...
    'VEOG'   'HEOG' 'M1' 'M2'};


[t ind,indb] = intersect(names, actCha);
index = zeros(max(indb),1);
index_check =zeros(max(ind),1);
for i = 1:numel(indb)
    index(indb(i)) = ind(i);
    index_check(ind(i)) = indb(i);
end

n = names(index(index>0));
coor = pos(index(index>0),:);

% check for same amount of input channels as output channels otherwise
% modify cellInd --> indizes of used channels in ALLEEG
if numel(index_check(index_check~=0)) ~= numel(actCha)
    cellInd = cellInd(sort(index_check(index_check ~=0)));
end

