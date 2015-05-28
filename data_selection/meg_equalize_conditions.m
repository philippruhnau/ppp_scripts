function data = meg_equalize_conditions(cfg, data)

% function data = meg_equalize_conditions(cfg, data)
% equalizes the n of triggers in different conditions by randomly removing
% trials from conditions with more trials
% 
% input:
% data - fieldtrip data structure after preprocessing (containing trials)
%        OR 
% cfg.fname = string pointing to the filename
%
% cfg.trigger - cell array, each cell contains triggers belonging to one
%               condition. e.g., {[1 2] [7] [5 8 9]}
% cfg.trigcol - trigger column within data.trialinfo (default = 1)
% 

% copyright (c), 2014, P. Ruhnau, email: mail (at) philipp-ruhnau.de
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

% 20140220 - initial implimentation 

%% defaults
if ~isfield(cfg, 'trigcol'), cfg.trigcol = 1; end

%% load if necessary
if isfield(cfg, 'fname') && nargin < 2 
    disp(['Loading: ' cfg.fname])
    data = load(cfg.fname);
elseif isempty(data)
    error('PReqCond:emptyData', 'Empty dataset, please provide either a full filename or a dataset')
end

%% find and select
% first collect indizes + n of indizes
for iCond = 1:numel(cfg.trigger)
    % get only trials of specific condition
    indx{iCond} = find(ismember(data.trialinfo(:,cfg.trigcol), cfg.trigger{iCond}));
    % catch n of trials to equalize 
    nIdx(iCond) = length(indx{iCond});
end

% find smallest n 
n_fin = min(nIdx);
% and and reduce larger ones (randomly)
indx = cellfun(@(x) sort(randsample(x,n_fin)), indx, 'UniformOutput', false);
% put conditions back together
indx = cell2mat(indx);

%% find all the other triggers in the data (we don't want to remove them)
oIndx = find(~ismember(data.trialinfo(:,cfg.trigcol), cell2mat(cfg.trigger)));

%% put together final trial indices
finIndx = sort([indx(:); oIndx]);

%% check and display result
if numel(finIndx) == numel(data.trialinfo(:,cfg.trigcol))
    disp('Equal amount of triggers in all conditions - nothing changed!')
else
    disp(['Reducing input conditions to ' num2str(n_fin) ' trials' ]) 
end

%% select
tcfg = [];
tcfg.trials = finIndx;
% data = ft_redefinetrial(tcfg, data);
data = ft_selectdata(tcfg, data); %check whether this reorders sensors!

