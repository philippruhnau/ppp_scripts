function [pID, pN, tID, tN] = FDR(p, q, df)

% False Discovery Rate
%
% FORMAT [pID, pN, tID, tN] = FDR(p, q, df)
% 
% [Input]
% p   - vector of p-values
% q   - False Discovery Rate level
% df  - degrees of freedom
%
% [Output]
% pID - p-value threshold based on independence or positive dependence; ID - independence
% pN  - Nonparametric p-value threshold, no assumptions about how the tests are correlated; N - nonparametric
% tID - corresponding t value
% tN  - corresponding t value
%______________________________________________________________________________
% $Id: FDR.m,v 1.1 2009/10/20 09:04:30 nichols Exp $
% http://www.sph.umich.edu/~nichols/FDR/#FDRill
% Genovese, C.R. et al. (2002). Thresholding of Statistical Maps in Functional Neuroimaging Using the False Discovery Rate. NeuroImage 15, 870�878.
%
% adjusted by BH 2009-10-30



p = p(isfinite(p));  % Toss NaN's
p = sort(p(:));
numVoxel = length(p);
I = (1:numVoxel)';

cVID = 1;
cVN  = sum(1 ./ (1:numVoxel));

pID = p(max(find(p <= I/numVoxel*q/cVID)));
pN  = p(max(find(p <= I/numVoxel*q/cVN)));

tID = icdf('T', 1-pID, df);     % T threshold, indep or pos. correl.
tN  = icdf('T', 1-pN, df);      % T threshold, no correl. assumptions


