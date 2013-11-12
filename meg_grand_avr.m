function [data cfg] = meg_grand_avr(cfg)

% function [data] = meg_grand_avr(cfg)
% computes grand average over subjects (fif files)
%
% Input:
% cfg.infiles - cell array of to be 'averaged' fiffs
% cfg.outfile - save cfg struct there; if empty nothing saved; cfg contains
%               some information about data (time line, sampling rate, comment)
%
% Output:
% data        - matrix containing data N by M by L
% cfg.xtime       - vector containing timepoints
% cfg.comment     - average name
% cfg.sfreq       - sampling rate

% (c) copyright P.Ruhnau, Email: philipp.ruhnau@unitn.it, 2011-09-09
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

if nargin < 1
    help meg_grand_avr
end

if ~isfield(cfg, 'infiles')
    error('Please specifiy input file names!')
end

if isfield(cfg, 'sensor')
    
    if strcmp(cfg.sensor, 'mag')
        ch_idx = rem(1:306,3)==0';
    elseif strcmp(cfg.sensor, 'grd')
        ch_idx = rem(1:306,3)~=0';
    else
        error('Sensor type unknown to the function!')
    end
    
    for names = 1:numel(cfg.infiles)
        fif  = fiff_read_evoked_all(cfg.infiles{names});
        data(:,:,names) = fif.evoked.epochs(ch_idx,:);
    end
    
    
    
else
    
    
    for names = 1:numel(cfg.infiles)
        fif  = fiff_read_evoked_all(cfg.infiles{names});
        data(:,:,names) = fif.evoked.epochs;
    end
    
end


cfg.data  = data;
cfg.xtime = fif.evoked.first * 1000/fif.info.sfreq : 1000/fif.info.sfreq : fif.evoked.last * 1000/fif.info.sfreq;
cfg.comment = fif.evoked.comment;
cfg.sfreq = fif.info.sfreq;

if isfield(cfg, 'outfile')
    outfile = cfg.outfile;
    cfg = rmfield(cfg, 'outfile'); %#ok<NASGU>
    save([outfile '.mat'], '-struct', 'cfg')
    disp(' '); disp(['Saving ' outfile '.mat!']); disp(' ')
end