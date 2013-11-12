function [g_eta2_me g_eta2_ma c_eta2 p_eta2] = eta_squared(SSb_me, SSb_ma, SSb_error, SSrm, SSia_me, SSia_ma)

%
% [g_eta2_me g_eta2_ma c_eta2 p_eta2] = eta_squared(SSb_me, SSb_ma, SSb_error, SSrm, SSia_me, SSia_ma)
%
% The rationale behind the generalized eta-squareed is to take only measured
% variance (individual differences like gender, socioeconomic status etc.)
% into account for the effect size and leave manipulated variance
% out (as this would not be part of other studies).
%
% Inputs (leave empty if not present []):
% SSb_me    - vector of squared sums of all measured between-subject effects
% SSb_ma    - vector of squared sums of all manipulated between-subject effects
% SSb_error - squared sum of between-subject error
% SSrm      - N by 2 array of squared sums of effects and errors of
%             repeated-measures factors (manipulated by definition)
% SSia_me   - N by 2 array of squared sums of effects and errors of
%             interactions including at least one measured factor (NB: errors
%             correspond to the between-subject error)
% SSia_ma   - N by 2 array of squared sums of effects and errors of
%             interactions of manipulated factors ONLY (NB: errors correspond
%             to rm-factors included in the interaction or between-subject
%             error in case only between-sub factors in the IA)
%             NB2: Order the input that the within-sub interactions are last,
%             otherwise the error sums get mixed up, see comment in the
%             script (around line 63)
%
% Outputs:
% g_eta2_me - generalized eta-squared for each measured effect (recommended)
% g_eta2_ma - generalized eta-squared for each manipulated effect (recommended)
% c_eta2    - classical eta-squared for each effect (order: measured and
%             between first)
% p_eta2    - partial eta-squared for each effect (order: measured and
%             between first)
%
%
% References:
%	Bakeman R (2005) Recommended effect size statistics for repeated
%		measures designs. Behavior Research Methods 37, 379-384.
%   Olejnik S & Algina J (2003) Generalized eta and omega squared
%       statistics: measures of effect size for some common research
%       designs. Psychological Methods 8, 434-447.
% -------------------------------------------------------------------------
%

% (c) copyright P.Ruhnau, Email: philipp.ruhnau@unitn.it, 2011-09-09
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
%
%
% update: function naming and documentation corrected, 2012-02-01 pruhnau

if ~isempty(SSb_me), % add error to me-effects
    if size(SSb_me,2) < size(SSb_me,1), SSb_me = SSb_me';end
    SSb_me(:,2) = SSb_error;
end
if ~isempty(SSb_ma), % add error to ma-effects
    if size(SSb_ma,2) < size(SSb_ma,1), SSb_ma = SSb_me';end
    SSb_ma(:,2) = SSb_error;
end
if isempty(SSrm),
    SSrm_error = 0;
elseif size(SSrm,1)>1 && isempty(SSb_ma)
    SSrm_error = sum(SSrm(:,2)) + sum(SSia_ma(:,2));
elseif size(SSrm,1)>1 && ~isempty(SSb_ma)
    % when there are rm factors and manipulated between-sub factors it is
    % necessary to extract the error variance attributed only to the rm
    % factors interactions. They have to be placed at the END of the SSia_ma 
    % matrix to be extracted correctly
    n_ws = size(SSrm,2); %number of rm factors
    for k=2:n_ws % number of interactions of rm factors
        K_ia(k-1) = nchoosek(n_ws,k);
    end
    n_ias = sum(K_ia);
    SSrm_error = sum(SSrm(:,2)) + sum(SSia_ma(end-(n_ias-1):end,2));
else
    SSrm_error = sum(SSrm(:,2));
end

% one matrix for me- and ma effects/errors
SSme = [SSb_me; SSia_me];
SSma = [SSb_ma; SSrm; SSia_ma];
% sum of errors
SSerror = SSb_error + SSrm_error;

% generalized eta for me- and ma- effects
if ~isempty(SSme)
    g_eta2_me = SSme(:,1) ./ (sum(SSme(:,1)) + SSerror);
else
    g_eta2_me = 'no measured factors';
end

if ~isempty(SSma)
    if ~isempty(SSme)
        g_eta2_ma = SSma(:,1) ./ (SSma(:,1) + sum(SSme(:,1)) + SSerror);
    else
        g_eta2_ma = SSma(:,1) ./ (SSma(:,1) + SSerror);
    end
else
    g_eta2_ma = 'no manipulated factors';
end

% classical and partial eta
SS = [SSme;  SSma];

c_eta2 = SS(:,1) ./ (sum(SS(:,1)) + SSerror);
p_eta2 = SS(:,1) ./ (SS(:,1) + SS(:,2));


return








