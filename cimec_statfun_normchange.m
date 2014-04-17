function [s] = cimec_statfun_normchange(cfg, dat, design)

% FT_STATFUN_NORMCHANGE computes the normalized change between two 
% conditions;
% might be specifically useful for source space testing 
%
% For conditions A and B, the calculation is (A - B) / (A + B)
%
% Ref (e.g.):
% Spaak, E., de Lange, F. P., & Jensen, O. (2014). 
% Local entrainment of alpha oscillations by visual stimuli causes cyclic modulation of perception. 
% J Neurosci, 34(10), 3536?3544. 

% version 20140320 - initial implimentation - PR

selA = find(design(cfg.ivar,:)==1); % selecton condition 1 or A
selB = find(design(cfg.ivar,:)==2); % selecton condition 2 or B
dfA  = length(selA);
dfB  = length(selB);
if (dfA+dfB)<size(design, 2)
  % there are apparently replications that belong neither to condition 1, nor to condition 2
  warning('inappropriate design, it should only contain 1''s and 2''s');
end
% compute the averages ...
avgA = mean(dat(:,selA), 2);
avgB = mean(dat(:,selB), 2);
%...and then the normalized change
s = (avgA - avgB) ./ (avgA + avgB);

% the stat field is used in STATISTICS_MONTECARLO 
s.stat = s;

