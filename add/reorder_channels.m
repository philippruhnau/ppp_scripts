function data = cimec_reorder_channels(data)


% data = cimec_reorder_channels(data)
%
% checks if channels in the data are in the default (Neuromag) order,
% if not, labels and data are reordered
% if non-meg channels are present in the data they are moved to the end of
% the label list and the data
%
% if data are ordered as default, nothing happens
%
% input:
%
% data    - fieldtrip struct containing either raw data trials, ERF or 
%           time-frequency data; output of ft_preprocessing, 
%           ft_timelockanalysis, or ft_freqanalysis (power) 
%
% output:
%
% data - data struct with reordered labels and trials/powspctrm fields
%        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copyright (c), 2013, P. Ruhnau, philipp_ruhnau@yahoo.de, 2013-02-12
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

% ver 20130713 - data can contain non-meg channels (e.g., trigger channels)
%                added combined gradiometer check (removed check based on 
%                number of channels) 

% capture meg channels (if, e.g., trigger channels are present)
meg_idx = cellfun(@(x)  ~isempty(regexp(x, 'MEG', 'once')), data.label);
% idx of non meg channels
non_meg_idx = find(meg_idx ==0);

% check for combined grads?
is_cmb = any(cellfun(@(x)  ~isempty(regexp(x, '+', 'once')), data.label));

if ~is_cmb % this function should be applied before combining the gradiometers
    disp('Assuming standard 306 channel Neuromag layout')
    % standard NEUROMAG channel order
    standard_label = {'MEG0113'    'MEG0112'    'MEG0111'    'MEG0122'    'MEG0123'    'MEG0121'    'MEG0132'    'MEG0133'    'MEG0131'    'MEG0143'    'MEG0142'    'MEG0141'    'MEG0213'    'MEG0212'...
        'MEG0211'    'MEG0222'    'MEG0223'    'MEG0221'    'MEG0232'    'MEG0233'    'MEG0231'    'MEG0243'    'MEG0242'    'MEG0241'    'MEG0313'    'MEG0312'    'MEG0311'    'MEG0322'...
        'MEG0323'    'MEG0321'    'MEG0333'    'MEG0332'    'MEG0331'    'MEG0343'    'MEG0342'    'MEG0341'    'MEG0413'    'MEG0412'    'MEG0411'    'MEG0422'    'MEG0423'    'MEG0421'...
        'MEG0432'    'MEG0433'    'MEG0431'    'MEG0443'    'MEG0442'    'MEG0441'    'MEG0513'    'MEG0512'    'MEG0511'    'MEG0523'    'MEG0522'    'MEG0521'    'MEG0532'    'MEG0533'...
        'MEG0531'    'MEG0542'    'MEG0543'    'MEG0541'    'MEG0613'    'MEG0612'    'MEG0611'    'MEG0622'    'MEG0623'    'MEG0621'    'MEG0633'    'MEG0632'    'MEG0631'    'MEG0642'...
        'MEG0643'    'MEG0641'    'MEG0713'    'MEG0712'    'MEG0711'    'MEG0723'    'MEG0722'    'MEG0721'    'MEG0733'    'MEG0732'    'MEG0731'    'MEG0743'    'MEG0742'    'MEG0741'...
        'MEG0813'    'MEG0812'    'MEG0811'    'MEG0822'    'MEG0823'    'MEG0821'    'MEG0913'    'MEG0912'    'MEG0911'    'MEG0923'    'MEG0922'    'MEG0921'    'MEG0932'    'MEG0933'...
        'MEG0931'    'MEG0942'    'MEG0943'    'MEG0941'    'MEG1013'    'MEG1012'    'MEG1011'    'MEG1023'    'MEG1022'    'MEG1021'    'MEG1032'    'MEG1033'    'MEG1031'    'MEG1043'...
        'MEG1042'    'MEG1041'    'MEG1112'    'MEG1113'    'MEG1111'    'MEG1123'    'MEG1122'    'MEG1121'    'MEG1133'    'MEG1132'    'MEG1131'    'MEG1142'    'MEG1143'    'MEG1141'...
        'MEG1213'    'MEG1212'    'MEG1211'    'MEG1223'    'MEG1222'    'MEG1221'    'MEG1232'    'MEG1233'    'MEG1231'    'MEG1243'    'MEG1242'    'MEG1241'    'MEG1312'    'MEG1313'...
        'MEG1311'    'MEG1323'    'MEG1322'    'MEG1321'    'MEG1333'    'MEG1332'    'MEG1331'    'MEG1342'    'MEG1343'    'MEG1341'    'MEG1412'    'MEG1413'    'MEG1411'    'MEG1423'...
        'MEG1422'    'MEG1421'    'MEG1433'    'MEG1432'    'MEG1431'    'MEG1442'    'MEG1443'    'MEG1441'    'MEG1512'    'MEG1513'    'MEG1511'    'MEG1522'    'MEG1523'    'MEG1521'...
        'MEG1533'    'MEG1532'    'MEG1531'    'MEG1543'    'MEG1542'    'MEG1541'    'MEG1613'    'MEG1612'    'MEG1611'    'MEG1622'    'MEG1623'    'MEG1621'    'MEG1632'    'MEG1633'...
        'MEG1631'    'MEG1643'    'MEG1642'    'MEG1641'    'MEG1713'    'MEG1712'    'MEG1711'    'MEG1722'    'MEG1723'    'MEG1721'    'MEG1732'    'MEG1733'    'MEG1731'    'MEG1743'...
        'MEG1742'    'MEG1741'    'MEG1813'    'MEG1812'    'MEG1811'    'MEG1822'    'MEG1823'    'MEG1821'    'MEG1832'    'MEG1833'    'MEG1831'    'MEG1843'    'MEG1842'    'MEG1841'...
        'MEG1912'    'MEG1913'    'MEG1911'    'MEG1923'    'MEG1922'    'MEG1921'    'MEG1932'    'MEG1933'    'MEG1931'    'MEG1943'    'MEG1942'    'MEG1941'    'MEG2013'    'MEG2012'...
        'MEG2011'    'MEG2023'    'MEG2022'    'MEG2021'    'MEG2032'    'MEG2033'    'MEG2031'    'MEG2042'    'MEG2043'    'MEG2041'    'MEG2113'    'MEG2112'    'MEG2111'    'MEG2122'...
        'MEG2123'    'MEG2121'    'MEG2133'    'MEG2132'    'MEG2131'    'MEG2143'    'MEG2142'    'MEG2141'    'MEG2212'    'MEG2213'    'MEG2211'    'MEG2223'    'MEG2222'    'MEG2221'...
        'MEG2233'    'MEG2232'    'MEG2231'    'MEG2242'    'MEG2243'    'MEG2241'    'MEG2312'    'MEG2313'    'MEG2311'    'MEG2323'    'MEG2322'    'MEG2321'    'MEG2332'    'MEG2333'...
        'MEG2331'    'MEG2343'    'MEG2342'    'MEG2341'    'MEG2412'    'MEG2413'    'MEG2411'    'MEG2423'    'MEG2422'    'MEG2421'    'MEG2433'    'MEG2432'    'MEG2431'    'MEG2442'...
        'MEG2443'    'MEG2441'    'MEG2512'    'MEG2513'    'MEG2511'    'MEG2522'    'MEG2523'    'MEG2521'    'MEG2533'    'MEG2532'    'MEG2531'    'MEG2543'    'MEG2542'    'MEG2541'...
        'MEG2612'    'MEG2613'    'MEG2611'    'MEG2623'    'MEG2622'    'MEG2621'    'MEG2633'    'MEG2632'    'MEG2631'    'MEG2642'    'MEG2643'    'MEG2641'}';
else
    error('cimec:reorder_channels:wrong_channum','Wrong channel type in the data. \nData input should contain all 3 Neuromag sensortypes (i.e magentometers, X and Y gradiometers).\nDid you combine the gradiometers?')
end % if

% compare standard and current label order
[t,a_idx,re_idx] = intersect(standard_label,data.label, 'stable');

% Matlab versions earlier than 2012 don't have a 'stable' option for intersect, therefore reordering is needed
% we check if a_idx is sorted (if so, the stable option did work, if not reorder)
if ~issorted(a_idx)
    % undo the sorting
    [t, a_map] = sort(a_idx); 
    re_idx = re_idx(a_map);
end % if

%if sorted correctly get out
if issorted(re_idx) 
    disp('Channels are in right order, data untouched.')
    return
end % if

% append non-meg channels to the end of the reordered index vector
re_idx = [re_idx; non_meg_idx];

% reordering
if isfield(data, 'trial') % ERFs
    if iscell(data.trial) % raw data
        disp('Data contains single trial raw data. Reordering now.')
        for i = 1:numel(data.trial)
            data.trial{i} = data.trial{i}(re_idx,:);
        end % for
    else % result of ft_timelockanalysis
        disp('Data contains ERF data. Reordering now.')
        switch data.dimord
            case 'rpt_chan_time'
                data.trial = data.trial(:,re_idx,:);
            case 'chan_time'
                data.trial = data.trial(re_idx,:);
        end %switch
    end % if
elseif isfield(data, 'powspctrm') % tf data
    disp('Data contains time-frequency data. Reordering now.')
    switch data.dimord
        case 'rpt_chan_freq_time'
            data.powspctrm = data.powspctrm(:,re_idx,:,:);
        case 'chan_freq_time'
            data.powspctrm = data.powspctrm(re_idx,:,:);
    end % switch
else
    error('cimec:reorder_channels:unknown_dataformat','Input data type unknown. \nFunction can currently only deal with raw data trials, erfs or time-frequency data.\n(Results of ft_preprocessing, ft_timelockanalysis, or ft_frequanalysis)')
end % if
data.label = data.label(re_idx);

end % function