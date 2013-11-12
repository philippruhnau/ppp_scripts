function trans_mat = comp_trans_mat(size_data, nMeans)

% function trans_mat = comp_trans_mat(size_data, nMeans)
% creates a transformation matrix that can be used to transform
% data with a specific size (size_data) such that the average over
% nMeans points is calculated

% (c) copyright 2013 P.Ruhnau, Email: philipp.ruhnau@unitn.it
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

A = eye(size_data,size_data);

minus_idx = floor((nMeans - 1)/2);
plus_idx = floor((nMeans)/2);
meanArray = 0:nMeans-1;

% indx = [];
for indy = 1+minus_idx:size(A,1)-plus_idx 
%     indx = find(A(indy,:),1);
    A(indy,meanArray+indy-minus_idx) = 1/nMeans;
end

% begining and end
for i = 1:minus_idx %begin
    new_nMeans = numel(1:i+plus_idx);
    A(i,1:i+plus_idx)= 1/(new_nMeans);
end
end_idxs = size(A,2)-plus_idx+1:size(A,2);
for i = 1:numel(end_idxs) % end
    new_nMeans = numel(end_idxs(i)-minus_idx:size(A,2));
    A(end_idxs(i),end_idxs(i)-minus_idx:size(A,2))= 1/(new_nMeans);
end

trans_mat = A;
