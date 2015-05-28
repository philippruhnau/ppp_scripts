function [newSample1 newSample2] = draw2from2(sample1,sample2)

% draw2from2(sample1,sample2) selects 2 new random samples from all items 
% of 2 sample inputs with 
% N(newSample1) = N(sample1) and
% N(newSample2) = N(sample2)
% usefull when performing permutation tests in BETWEEN subject designs.


sample1 = sample1(:);
sample2 = sample2(:);

N1 = numel(sample1);
N2 = numel(sample2);

overallSample = [sample1; sample2];
N = numel(overallSample);

randIdx = randperm(N);
selectIdx = randIdx(1:N1);

newSample1 = overallSample(selectIdx);
overallSample(selectIdx) = [];
newSample2 = overallSample;

