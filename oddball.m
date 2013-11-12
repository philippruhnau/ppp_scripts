function fin_mat = oddball(cfg,sub,block)

% function oddball(cfg,sub,block) 
% creates a N by 2 matrix of a randomized sequence containing the input 
% cfg.trains multiplied by cfg.ntrains (handy for oddball sequence with 
% controlled global probability and number of standards before each 
% deviant, see example in the file)
%
% the state of the randomization can be fixed by sub and block (optional) 
% to yield the same randomization for the same subject (and/or block)
%
% mandatory input:
% 
% cfg.trains  - M by 2 by N matrix, first row contains stimuli, second
%               triggers (this is interchangable), N trains in the 3rd 
%               dimension. trains have to have the same size (M by 2), use 
%               NaNs as spaceholders (cleared at the end of the script)
% cfg.ntrains - multiplier of cfg.trains
%
% optional input [defaults]:
% 
% cfg.start   - M by 2 matrix of first M stimuli and triggers [empty]
% sub         - scalar, subject number [empty]
% block       - scalar, block number [1]
% sub and block are used to fix randomization state
%
% output:
%
% fin_mat     - M by 2 matrix, first line stimulus type, second triggers
%


% Example:
% % start sounds (0 = standard sound) with trigger in second row
% % cfg.start = [0  0  0  0  0  0  0  0  0  0;...
% %             11 11 11 11 11 11 11 11 11 11]';
% % all possible trains for a 20% oddball with at least 2 standards before
% % each deviant (3,4,5,6,7 tones in a train) and a mean of 5 tones per 
% % train; NaNs get erased from the continuous sequence
% % cfg.trains =   cat(3,[0 0 1 NaN NaN NaN NaN; 8 2 3 NaN NaN NaN NaN]',...
% %                      [0 0 0   1 NaN NaN NaN; 8 2 2   4 NaN NaN NaN]',...
% %                      [0 0 0   0   1 NaN NaN; 8 2 2   2   5 NaN NaN]',...
% %                      [0 0 0   0   0   1 NaN; 8 2 2   2   2   6 NaN]',...
% %                      [0 0 0   0   0   0   1; 8 2 2   2   2   2   7]');
% % cfg.ntrains = 12;
% %
% % output:
% %
% % fin_mat =
% %      0    11
% %      0    11
% %      0    11
% %      0    11
% %      0    11
% %      0    11
% %      0    11
% %      0    11
% %      0    11
% %      0    11
% %      0     8
% %      0     2
% %      0     2
% %      1     4
% %      0     8
% %      0     2
% %      0     2
% %      0     2
% %      1     6
% %      0     8
% %      0     2
% %      0     2
% %      0     2
% %      0     2
% %      0     2
% %      1     7
% %      0     8
% %      0     2
% %      0     2
% %      1     4
% %      0     8
% %      0     2
% % % % ...
%
                       
% (c) copyright P.Ruhnau, Email: philipp.ruhnau@unitn.it, 2012-01-03
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
                       
% defaults
if ~isfield(cfg, 'start'), cfg.start = []; end
if nargin == 2, block = 1; end
if nargin == 3 && isempty(sub), sub=1; end

% matrices for all patterns
mat  = repmat(cfg.trains,[1 1 cfg.ntrains]);

if exist('sub', 'var')
    % fix randstate
    rand('state', (sub - 1) + block);
end

% permute
rand_idx = randperm(size(mat,3));
rand_mat_3D = mat(:,:,rand_idx);

% first trains and 3D to 2D
rand_mat = cfg.start;
for i = 1:size(rand_mat_3D,3)
rand_mat = [rand_mat; rand_mat_3D(:,:,i)];
end


% find and remove nans
nan_idx = ~isnan(rand_mat(:,1));
fin_mat = rand_mat(nan_idx,:);



