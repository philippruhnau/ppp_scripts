function [s] = cimec_statfun_normchange(cfg, dat, design)

% FT_STATFUN_NORMCHANGE computes the normalized change between two 
% conditions;
% might be specifically useful for source space testing 
%
% For conditions A and B, the calculation is (A - B) / (A + B)
%


% version 20140320 - initial implimentation - PR

selA = find(design(cfg.ivar,:)==1); % selecton condition 1 or A
selB = find(design(cfg.ivar,:)==2); % selecton condition 2 or B
dfA  = length(selA);
dfB  = length(selB);
if (dfA+dfB)<size(design, 2)
  % there are apparently replications that belong neither to condition 1, nor to condition 2
  warning('inappropriate design, it should only contain 1''s and 2''s');
end
% compute the averages and then the normalized change
avgA = mean(dat(:,selA), 2);
avgB = mean(dat(:,selB), 2);

s = (avgA - avgB) ./ (avgA + avgB);

% the stat field is used in STATISTICS_MONTECARLO 
s.stat = s;

