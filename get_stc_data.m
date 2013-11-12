function data_selection = get_stc_data(STCF, label, vertices, abs_vals) 

% function data_selection = get_stc_data(STCF, label, vertices, abs_vals)
%
% computes averages in a specified region of interest (ROI) which is givin
% either via an MNE label or specified as vertex numbers
%
% input:
% STCF     - MNE stc structure
% label    - MNE label file containing the ROI information
% vertices - vector containing ROI vertex numbers
% abs_vals - set to 1 if output shall contain absolute values
%
% output:
% data_selection - m by n matrix of activity from ROI
%

%
% copyright (c), 2011, P. Ruhnau, email: ruhnau@uni-leipzig.de, 2011-08-03
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


if nargin < 4, abs_vals = 0; end

if nargin < 3 || isempty(vertices)

[label_vertices, ~, ~, ~, ~] = textread(label, '%d %f %f %f %f', 'headerlines', 2);


[~, ~, idx_stc] = intersect(label_vertices, STCF.vertices);
else
    idx_stc = vertices;
end

if abs_vals ~= 1
    data_selection = mean(STCF.data(idx_stc,:),1);
else
    disp('Computing absolute values')
    data_selection = abs(mean(STCF.data(idx_stc,:),1));
end



