function [DATA] = EEGLAB2Fieldtrip(cfg)
% 
% [DATA] = EEGLAB2Fieldtrip(cfg) formats epoched .set data from eeglab to fieldtrip
% format. When a destination folder is given these data are saved. 
%
%
% required inputs:
%
% cfg.Path        -   file path, input files must be epoched, artifact free and may
%                     contain trials of various conditions
% cfg.Subjects    -   cell, subjects to process
% cfg.Chanlocs    -   path and name of electrode location file
% cfg.EvMat       -   N x 1 cell of trigger value(s)/name(s), to divide trials of certain conditions
%
% optional inputs:
%
% cfg.CondName    -   string, name of condition in filename
% cfg.AddName     -   use for additional name-part AFTER condName (e.g.
%                     filter aspects or reference)
% cfg.InFolder    -   folder to load the file from; if left empty run this
%                     script in the folder containing the files
% cfg.OutFolder   -   folder to store the results; if empty nothing is
%                     stored
% cfg.nepochlim   -   if is not empty, trials are epoched to [t_start t_end]
%
% output:
% DATA            -   fieldtrip formated data

% --------------------------------------------------
% copyright: Christian Keitel & Philipp Ruhnau, 2010
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


if ~isfield(cfg, 'CondName'),  cfg.CondName  = ''; else cfg.CondName  = ['_' cfg.CondName];end
if ~isfield(cfg, 'AddName'),   cfg.AddName   = ''; else cfg.AddName   = ['_' cfg.AddName]; end
if ~isfield(cfg, 'InFolder'),  cfg.InFolder  = ''; end
if isfield(cfg, 'OutFolder'),  PathOut = fullfile(cfg.Path, cfg.OutFolder); end


PathIn = fullfile(cfg.Path, cfg.InFolder);


for iSub = 1:size(cfg.Subjects,1);
    clear DATA;
    
    FileName=[cfg.Subjects{iSub} cfg.CondName cfg.AddName];
    disp(' '); disp(FileName);
    % load data
    EEG = pop_loadset([FileName '.set'],PathIn);
    % load chan locations
    %     EEG.chanlocs = pop_chanedit(EEG.chanlocs,'load',{cfg.Chanlocs,'filetype','besa (elp)'});
    if ~isfield(EEG, 'chanlocs')
    EEG = pop_chanedit(EEG,  'lookup', fullfile(cfg.Chanlocs));
    end
    % seperate conditions
    for iCond = 1:size(cfg.EvMat,1)
        TEMP = pop_selectevent(EEG,'type',cfg.EvMat(iCond,:),'deleteevents','on','deleteepochs','on');
        
        if isfield(cfg, 'nepochlim')
            disp('Shortening epochs! Do you want that????')
            TEMP = pop_select(TEMP,'time',cfg.nepochlim);
        end
        
        % move channel info, epochs, timepoints, and samplingrate to DATA (fieldtrip format) structure
        for iChan = 1:TEMP.nbchan, DATA.label{iChan,1} = TEMP.chanlocs(1,iChan).labels; end
        for iTrial = 1:TEMP.trials, DATA.trial{1,iTrial} = TEMP.data(:,:,iTrial); end
        DATA.time = mat2cell(repmat(TEMP.times/1000,TEMP.trials,1),ones(TEMP.trials,1),TEMP.pnts)';
        DATA.fsample = TEMP.srate;
        DATA.cfg = struct(); % find a way to implement proper struct!
        
        % trial trigger timing (begining, end, trigger-offset) information from original un-epoched(!) data 
        DATA.cfg.trl = repmat(zeros,TEMP.trials,3);
        trg = 0; % counter for relevant trigger
        blSize = EEG.xmin * EEG.srate; % baseline in points
        epMax  = EEG.xmax * EEG.srate; % epoch end in points
        for iTrg = 1:size(TEMP.event,2)
            if strcmp(TEMP.event(iTrg).type, cfg.EvMat(iCond)) == 1
                trg = trg +1;
                curLat = TEMP.urevent(TEMP.event(iTrg).urevent).latency;
                DATA.cfg.trl(trg,:) = [curLat+blSize curLat+epMax blSize];
            end
        end
        
        DATA.hdr = struct();
        
        if isfield(cfg, 'OutFolder'), save(fullfile(PathOut, FileName),'-struct','DATA'); end
        
        clear TEMP;
    end
    clear EEG;
end
