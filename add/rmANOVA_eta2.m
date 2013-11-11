function [g_eta2 c_eta2 p_eta2] = rmANOVA_eta2(SSeffect, SSerror, SSbetw)

% [g_eta2 c_eta2 p_eta2] = rmANOVA_eta2(SSeffect, SSerror, SSbetw)
%
% Inputs:
%	SSeffect - vector of the squared sum effects for each effect of the rmANOVA
%	SSerror  - vector of the squared sum errors for each effect of the rmANOVA
%	SSbetw   - the squared sum for the between-subject
%
% Outputs:
%	g_eta2 - generalized eta-squared for each effect (recommended)
%	c_eta2 - classical eta-squared for each effect
%	p_eta2 - partial eta-squared for each effect
%
% Note: SSeffect and SSerror entries need to belong together.
%
% References:
%	Bakeman R (2005) Recommended effect size statistics for repeated 
%		measures designs. Behavior Research Methods 37:379-384.
%
% -------------------------------------------------------------
% B.Herrmann, Email: bherrmann@cbs.mpg.de, 2010-11-03

g_eta2 = SSeffect ./ (SSeffect + SSbetw + sum(SSerror));
c_eta2 = SSeffect ./ (sum(SSeffect) + SSbetw + sum(SSerror));
p_eta2 = SSeffect ./ (SSeffect + SSerror);

return
