function [d g d_unbiased g_unbiased] = effect_size(m1,m2,s1,s2,n1,n2)

% [d g d_unbiased g_unbiased] = effect_size(m1,m2,s1,s2,n1,n2)
%
% Input:
%	m1, m2 - means for measure 1 and 2
%	s1, s2 - standard deviation
%	n1, n2 - number of subjects
%
% Output:
%	d - Cohen's d [1,3]
%	g - Hedges's g [2,3]
%	d_unbiased - Cohen's d unbiased (for small sample sizes < 20) [3]
%	g_unbiased - Hedges's g unbiased (for small sample sizes < 20) [3]
%
% Note:
%	- d,g = 0,2 small effekt; d,g = 0,5 middle effect; d,g = 0,8 strong effekt
%	- d == g in case of n1 == n2
%	- can be used for independent oder dependent data
%
% References:
%	[1] Cohen J (1988) Statistical Power Analysis for the Behavioral Sciences.
%			2nd edition. Erlbaum, Hillsdale, NJ.
%	[2] Hedges LV (1981) Distributional theory for Glass's estimator of effect 
%			size and related estimators. Journal of Educational Statistics 6:107–128.
%	[3] Nakagawa S, Cuthill IC (2007) Effect size, confidence interval and statistical 
%			significance: a practical guide for biologists. Biological Reviews
%			82:591–605
% -------------------------------------------------------------------------
% B. Herrmann, Email: bherrmann@cbs.mpg.de, 2010-11-04

d = (m1 - m2) / sqrt((s1^2 + s2^2)/2);
g = (m1 - m2) / sqrt(((n2 - 1)*(s2^2) + (n1-1)*(s1^2)) / (n1+n2-2));

d_unbiased = d * (1 - (3/(4*(n1+n2-2)-1)));
g_unbiased = g * (1 - (3/(4*(n1+n2-2)-1)));

return;



