function [fid] = write_reject(step, cfg, EEG, events, rel_trig, tcount, subject)
% puts out a file with the name, count and total-count of the rejected trials
% 
% Input:
% step     - 1 opens the file;
%            2 writes relevant information in it
% cfg      - contains cfg-struct:
%            cfg.path   - path name (str)
%            cfg.thresh - threshold (num)
%            cfg.filter - filter name (str)
%            cfg.ref    - reference (str)
%            cfg.addrej - optional string, appended to file name
% EEG      - EEG file containing epoch info and rejection info
% events   - N by 1 matrix of cells, contains eventtypes (names)
% rel_trig - indizes of relevant trigger(s)
% tcount   - N by 1 matrix containing the index of the trigger from 'events'
%            in each epoch, needed for total count
% subject  - string of subject number or name
%
% Output:
% fid      - file for step 2
% 
% file-output-example:
%
% Sub	Trig	Count	Total	
% 01 	 obr 	 026 	 0960
% 01 	 sta 	 022 	 0720
% 02 	 obr 	 049 	 0960
%
% 




if step == 1
    % open file for rejection count
    rejFile = [num2str(cfg.thresh) '_' cfg.filter '_' cfg.ref];
    if isfield(cfg, 'addrej'), rejFile = [rejFile '_' cfg.addrej]; end
    fid = fopen(fullfile(cfg.path, 'rej' , [rejFile '.txt']), 'a+');
    fprintf(fid,'\n%3s \t %8s \t %4s \t %5s', 'Sub', 'Trig', 'Count', 'Total');
    
elseif step == 2
    
   rejTrigArray = {EEG.epoch(EEG.reject.rejthresh).eventtype};
      
    for iTrigger = 1:numel(rel_trig)
        fprintf(cfg.fid, '\n%3s \t %8s \t %04d \t %05d',...
            subject,...             %subject
            events{rel_trig(iTrigger)}, ...singleAllTrig{iTrigger},...               %trigger
            sum(strcmp(rejTrigArray,events{rel_trig(iTrigger)})),...    %n rejected of this trigger
            sum(ismember(tcount,iTrigger)));         %n total of this trigger
    end
    
end