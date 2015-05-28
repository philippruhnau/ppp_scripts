function [vert ratio] = compare_label_size(labels)

% meant to lookup mumber of vertices coming from structural scan
% corresponding to decreased number in MNE
%
% Input:
% 
% labels - full file names of labels to compare
%
% Output:
%
% vert  - number of vertices in labels
% ratio - ratio of nuber in a vs. b




vert = zeros(numel(labels),1);

for iL = 1:numel(labels) 
[v t tt ttt ttt]=textread(labels{iL}, '%d %f %f %f %f', 'headerlines', 2);
vert(iL) = numel(v);
end



comp = nchoosek(1:numel(vert),2);

ratio = zeros(size(comp,1),1);

for iC = 1:size(comp,1)
ratio(iC) = vert(comp(iC,1))/vert(comp(iC,2))*100;
end