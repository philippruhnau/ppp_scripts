function data_selection = get_stc_data(STCF, label, vertices, abs_vals) 

% function get_stc_data
%
% computes averages in a specified region of interest (ROI) which is givin
% either via an MNE label or specified as vertex numbers
%
% input:
%
%
% copyright (c), 2011, P. Ruhnau, email: ruhnau@uni-leipzig.de, 2011-08-03

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



