function [comparison, levels, ps, pw_matrix] = direct_comparisons(X,p,factypes,pool)

% function [comparison levels ps pw_matrix] = direct_comparisons(X,p,factypes,pool)
%
% computes direct comparisons between all groups of variance analyses
% uses either all obtained p-values to compute fdr-corrected p-values or
% the input thresholds for .05, .01, & .001 alpha levels (p)
%
% calls fdr.m by A. Delorme (attached below)
%
% mandatory input:
%
% X - n by m matrix of datapoints and group/condition indizes
%     first column - data; second to mth column - factorstep indizes
%
% optional input:
%
% p         - threshholds for .05, .01, & .001 alpha levels of preferred
%             correction method (will be calculated when []), might contain
%             also four values, then thresholds at 0.1, 0.05, 0.01, and 
%             0.001 are assumed 
% factypes  - cell array, factor types 'rm' for repeated measures, 'btw' 
%             for between subjects factor; default: {'rm'} for all factors
% pool      - index of pooled factor(s) (CAVE: conjoint betwenn and within 
%             subject factor pooling has not really been tested, check 
%             your results)
%
% output:
%
% comparisons - struct containing statistical values for each comparison
% levels      - n by m matrix defining the comparison groups (e.g., [1 1 2]
%               is a group in a three-factorial design with step 1 of the
%               first, step 1 of the second, and step two of the third
%               factor
% ps          - uncorrected p-values of all individual comparisons (rounded
%               to the fourth decimal)
% pw_matrix   - pairwise comparison matrix, shows significance level or 1,
%               if non significant
%
                                                              
% P.Ruhnau, Email: philipp.ruhnau@unitn.it, 2012-12-04
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
                                                              
% 2012-12-04 - between subject factor pooling fixed (appending to one
% group)
% 2012-12-04 - removed subject indx column
% 2012-12-13 - cleaned up


if nargin < 2,  p = []; end
if ~exist('factypes', 'var') || isempty(factypes), factypes = repmat({'rm'}, 1, size(X,2)-2); end

warning('prToolbox:removedSubCol', '\nThe subject column is deprecated and was removed, \ncheck if your data fits the required input')

% extract data
data = X(:,1);
% extract factor vectors
fac = X(:,2:end);

% compute group indizes and all group comparisons
if ~exist('pool', 'var')
    levels = unique(fac, 'rows');
    level_contrasts = nchoosek(1:size(levels,1),2);
    left_factypes = factypes;
else
    % get index of pooled factor(s) and remove from contrasts
    idx_fac = ~ismember(1:size(fac,2),pool);
    idx_p = ismember(1:size(fac,2),pool);
    fac_p = fac(:,idx_fac);
    % find pooled rm factors
    fac_p_rm = fac(:, logical(idx_p.*strcmp(factypes, 'rm')));
    levels = unique(fac_p, 'rows');
    level_contrasts = nchoosek(1:size(levels,1),2);
    left_factypes = factypes(idx_fac);
    fprintf('Data pooled over factor %2d\n', pool)
end


% check for between subject factors
btw_fac = strcmp(left_factypes, 'btw');

ps = [];

for i = 1:size(level_contrasts,1)
    % get relevant data
    cur_contrast = [levels(level_contrasts(i,1),:);...
        levels(level_contrasts(i,2),:)];
    if ~exist('pool', 'var') % no pooling
        set1 = data(ismember(fac,cur_contrast(1,:), 'rows'));
        set2 = data(ismember(fac,cur_contrast(2,:), 'rows'));
    elseif exist('pool', 'var') && sum(strcmp(factypes(pool), 'btw'))
        % if pool factor is between, append groups, 
        set1 = data(ismember(fac_p,cur_contrast(1,:), 'rows'));
        set2 = data(ismember(fac_p,cur_contrast(2,:), 'rows'));
        if sum(strcmp(factypes(pool), 'rm')) % if additionally pooling is required for an rm factor      
            % reshape each set, and compute mean for same subjects
            pool_steps = prod(max(fac_p_rm));
            set1 = reshape(set1,numel(set1)/pool_steps, pool_steps);
            set1 = mean(set1,2); 
            set2 = reshape(set2,numel(set2)/pool_steps, pool_steps);
            set2 = mean(set2,2);
        end
    else  % for repeated measures, pool for same subjects over different factor steps
        pool_steps = prod(max(fac(:,pool)));
        set1 = data(ismember(fac_p,cur_contrast(1,:), 'rows'));
        set1 = reshape(set1,numel(set1)/pool_steps, pool_steps);
        set1 = mean(set1,2);
        set2 = data(ismember(fac_p,cur_contrast(2,:), 'rows'));
        set2 = reshape(set2,numel(set2)/pool_steps, pool_steps);
        set2 = mean(set2,2);
    end
    
    if sum(btw_fac) ~=0 % if between subject factor present
        if sum(diff(cur_contrast(:,btw_fac))) ~= 0 % if curent contrast between
            temp = ANOVA1([set1;set2], [ones(size(set1));ones(size(set2))+1]);
        else % if rm
            temp = rmANOVA1([set1,set2]);
        end
    else % if only rm factors
        temp = rmANOVA1([set1,set2]);
    end
    comparison{i} = temp;
    ps = [ps temp.p];
    
end

if isempty(p) % get fdr correction, if no input
    ps = round(ps * 1e10) / 1e10;
    p_fdr(1) = fdr(ps,0.05);
    p_fdr(2) = fdr(ps,0.01);
    p_fdr(3) = fdr(ps,0.001);
else
    p_fdr = p;
end

if numel(p_fdr) == 4 % if you want marginally significant results as well
    p_level = [0.1 0.05 0.01 0.001];
else
p_level = [0.05, 0.01 0.001];
end

pw_matrix = NaN(size(levels,1));
for icomp = 1:size(comparison,2) % print reslts
    eta2 = comparison{icomp}.SS.effect ./ comparison{icomp}.SS.total;
    [numSign signif sSign] = find_p_FDR(comparison{icomp}, p_fdr,p_level);
    fprintf('Contrast: %.0f vs. %.0f - F(%.0f,%.0f) = %.2f, p %s %.3f, eta=%.3f \n',...
        level_contrasts(icomp,1), level_contrasts(icomp,2), comparison{icomp}.df(1), comparison{icomp}.df(2), comparison{icomp}.F, sSign, signif, eta2);
    if strcmp(sSign, '>') % pairwise matrix
        pw_matrix(level_contrasts(icomp,1), level_contrasts(icomp,2)) = 1.000;
    else
        pw_matrix(level_contrasts(icomp,1), level_contrasts(icomp,2)) = signif;
    end
end




% fdr() - compute false detection rate mask
%
% Usage:
%   >> [p_fdr, p_masked] = fdr( pvals, alpha);
%
% Inputs:
%   pvals - vector or array of p-values
%   alpha - threshold value (non-corrected). If no alpha is given
%           each p-value is used as its own alpha and FDR corrected
%           array is returned.
%
% Outputs:
%   p_fdr    - pvalue used for threshold (based on independence
%              or positive dependence of measurements)
%   p_masked - p-value thresholded. Same size as pvals.
%
% Author: Arnaud Delorme, SCCN, 2008-
%         Based on a function by Tom Nichols
%
% See also: eeglab()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
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

% $Log: fdr.m,v $
% Revision 1.3  2010/01/19 20:58:20  arno
% fix problem with very discontinous values
%
% Revision 1.2  2009/05/31 02:22:10  arno
% Adding FDR and bootstrap to all STUDY functions
%
% Revision 1.1  2008/05/06 22:32:52  arno
% Initial revision
%

function [pID, p_masked] = fdr(pvals, q)

p = sort(pvals(:));
V = length(p);
I = (1:V)';

cVID = 1;
cVN = sum(1./(1:V));

if nargin < 2
    pID = ones(size(pvals));
    thresholds = exp(linspace(log(0.1),log(0.000001), 100));
    for index = 1:length(thresholds)
        [tmp p_masked] = fdr(pvals, thresholds(index));
        pID(p_masked) = thresholds(index);
    end;
else
    pID = p(max(find(p<=I/V*q/cVID))); % standard FDR
    %pN = p(max(find(p<=I/V*q/cVN)));  % non-parametric FDR (not used)
end;
if isempty(pID), pID = 0; end;

if nargout > 1
    p_masked = pvals<=I/V*q/cVID;
end;

% finds significant effects
function [numSign signif sSign] = find_p_FDR(results, p, pp)


numSign = max(find(round(p*1e10) == round(results.p*1e10)));
if numSign ~= 0
	signif = pp(numSign);
	sSign  = '=';
else
	numSign = length(find(round(p*1e10) > round(results.p*1e10)));
	if numSign == 0
		signif = 0.05;
		sSign  = '>';
	else
		signif = pp(numSign);
		sSign  = '<';
	end
end
