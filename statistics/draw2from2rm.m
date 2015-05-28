function [newSam] = draw2from2rm(origSam,idx_perm)

% draw2from2rm(origSam,idx_perm) reorders individual measurements (2)
% for permutation tests
% can also be used for more than 2 measurements
%
% Input:
% origSam  - original sample, either n(subs) by m(measurments) numeric
%            array, or n by m cell array (e.g., if trials of subjects are
%            entering individually)
% idx_perm - current permutation index (max n^k; n = measurements; k = subjects)
%
% Output:
% neSam    - new sample (either numeric or cell, similar to input)


% number of subjects and measurements
n_sub = size(origSam,1);
n_rep = size(origSam,2);

% permutations with rep
rowIdx = perms(1:n_rep);
nIdx = PermsRep(1:n_rep,n_sub);

% current order
curIndx =  rowIdx(nIdx(idx_perm,:),:);

% draw new sampling from original
if iscell(origSam)
newSam = cell(n_sub,n_rep);
for i = 1:size(curIndx,1)
    newSam(i,:) = origSam(i,curIndx(i,:));
end
elseif isnumeric(origSam)
    newSam = zeros(n_sub,n_rep);
    for i = 1:size(curIndx,1)
        newSam(i,:) = origSam(i,curIndx(i,:));
    end
end


function res = PermsRep(v,k)
%  PERMSREP Permutations with replacement.
%
%  PermsRep(v, k) lists all possible ways to permute k elements out of
%  the vector v, with replacement.

if nargin<1 || isempty(v)
    error('v must be non-empty')
else
    n = length(v);
end

if nargin<2 || isempty(k)
    k = n;
end

v = v(:).'; %Ensure v is a row vector
for i = k:-1:1
    tmp = repmat(v,n^(k-i),n^(i-1));
    res(:,i) = tmp(:);
end
