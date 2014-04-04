function results = rmANOVA32(X,names)

% results = ANOVA32(X, names)
% Description: three-way analysis of variance with repeated measurements on
%              two factors, n may be unequal between groups
%
% Mandatory input:
% X - n by 5 matrix of datapoints and group indizes
%     first column - data; second column - between subject factor; third
%     colum - within subject factor 1, third colum - within subject 
%     factor 2, fourth column - subject indizes
%
% Optional input:
% names - factor names, are displayed in the results table 
%
% Output:
% results - struct containing sum of squares (SS), degrees of freedom (DF),
%           mean squares (MS), F-values (F), p-values (p), and effect
%           related degrees of freedom (df)
%
% Sum of squares of within factors are not adjusted for group size.
%
% Reference:
%	Bortz (1999) Statistik fuer Sozialwissenschaftler. Springer Verlag
%


% ----------------------------------------------------------------
% P.Ruhnau, Email: mail@philipp-ruhnau.de, 2011-08-19
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

p = numel(unique(X(:,2))); % number of between factor steps (groups)
q = numel(unique(X(:,3))); % number of within factor steps WF1
r = numel(unique(X(:,4))); % number of within factor steps WF2
n = hist(X(:,2));
n = n(n~=0)./(q*r);
% N = sum(n); 


% sum of squares
CT =  (sum(X(:,1))^2)/(p*q*r*mean(n)); % correction term (1)
SS_all = sum(X(:,1).^2); % sum of all sqares (2)

%% SS single factors
sums_A = zeros(1,p);
for i_p = 1:p
sums_A(i_p)  = (sum(X(X(:,2)==i_p,1))^2)/(n(i_p)); % devide by group n (necessary for n unequal)
end
SS_A = sum(sums_A)/(q*r);% SS between factor (3)

sums_B = zeros(1,q);
for i_q = 1:q
sums_B(i_q) = sum(X(X(:,3)==i_q,1))^2; 
end
SS_B = sum(sums_B)/(r*sum(n));% SS fist within factor (4)

sums_C = zeros(1,r);
for i_r = 1:r
sums_C(i_r) = sum(X(X(:,4)==i_r,1))^2; 
end
SS_C = sum(sums_C)/(q*sum(n));% SS second within factor (5)

%% SS two facors
sums_AB = zeros(p,q);
for i_p = 1:p
    for i_q = 1:q
        sums_AB(i_p,i_q) = (sum(X(X(:,2)==i_p&X(:,3)==i_q,1))^2)/n(i_p); % devide by group n (necessary for n unequal)
    end
end
SS_AB = sum(sum(sums_AB))/(r); % SS between with first within factor (6)

sums_AC = zeros(p,r);
for i_p = 1:p
    for i_r = 1:r
        sums_AC(i_p,i_r) = (sum(X(X(:,2)==i_p&X(:,4)==i_r,1))^2)/n(i_p); % devide by group n (necessary for n unequal)
    end
end
SS_AC = sum(sum(sums_AC))/(q); % SS between with second within factor (7)

sums_BC = zeros(q,r);
for i_q = 1:q
    for i_r = 1:r
        sums_BC(i_q,i_r) = sum(X(X(:,3)==i_q&X(:,4)==i_r,1))^2; 
    end
end
SS_BC = sum(sum(sums_BC))/(sum(n)); % SS first with second within factor (8)

%% SS three factors
sums_ABC = zeros(p,q,r);
for i_p = 1:p
    for i_q = 1:q
        for i_r = 1:r
            sums_ABC(i_p,i_q,i_r) = (sum(X(X(:,2)==i_p&X(:,3)==i_q&X(:,4)==i_r,1)).^2)/n(i_p); 
        end
    end
end
SS_ABC = sum(sum(sum(sums_ABC))); % SS between with first with second within factor (9)

%% SS Subjects and factors with Subjects
sums_subs = nan(p,max(n));
for i_p = 1:p    
    for sub = 1:n(i_p)
        sums_subs(i_p,sub) = sum(X(X(:,2)==i_p&X(:,5)==sub,1))^2; % sum of single subjects over all within factor steps
    end
end
SS_subs = sum(nansum(sums_subs))/(q*r); % SS single subjects (10)

sums_ABsubs = nan(p,q,max(n));
for i_p = 1:p   
    for i_q = 1:q
        for sub = 1:n(i_p)
            sums_ABsubs(i_p,i_q,sub) = sum(X(X(:,2)==i_p&X(:,3)==i_q&X(:,5)==sub,1))^2;
        end
    end
end
SS_ABsubs = sum(sum(nansum(sums_ABsubs)))/(r); % SS between with first within factor with single subjects (11)

sums_ACsubs = zeros(r,sum(n));
for i_p = 1:p   
    for i_r = 1:r
        for sub = 1:n(i_p)
            sums_ACsubs(i_r,sub+sum(n(1:p-1))*(i_p-1)) = sum(X(X(:,2)==i_p&X(:,4)==i_r&X(:,5)==sub,1))^2;
        end
    end
end
SS_ACsubs = sum(sum(sums_ACsubs))/(q); % SS between with second within factor with single subjects (12)


%% Compute squared sums for statistic values

results.SS.total  = SS_all - CT; % (2) - (1)
results.SS.A = SS_A - CT; % between (3)-(1)
results.SS.Aerror  =  SS_subs - SS_A; % (10)-(3)
results.SS.between = SS_subs - CT; % between subs (10)-(1)
results.SS.B = SS_B - CT;% first within (4)-(1)
results.SS.AB = SS_AB - SS_A - SS_B + CT;% between x first within (6)-(3)-(4)+(1)
results.SS.Berror = SS_ABsubs - SS_AB - SS_subs + SS_A; % first within error (11)-(6)-(10)+(3)
results.SS.C = SS_C - CT; % second within (5)-(1)
results.SS.AC = SS_AC - SS_A - SS_C + CT; % between x second within (7)-(3)-(5)+(1)
results.SS.Cerror = SS_ACsubs - SS_AC - SS_subs + SS_A; % second within error (12)-(7)-(10)+(3)
results.SS.BC = SS_BC - SS_B - SS_C + CT; % first x second within (8)-(4)-(5)+(1)
results.SS.ABC = SS_ABC - SS_AB - SS_AC - SS_BC + SS_A + SS_B + SS_C - CT; % between x first x second within (9)-(6)-(7)-(8)+(3)+(4)+(5)-(1)
results.SS.BCerror = SS_all - SS_ABC - SS_ABsubs - SS_ACsubs + SS_AB + SS_AC + SS_subs - SS_A; % first x second within error (2)-(9)-(11)-(12)+(6)+(7)+(10)-(3)
results.SS.within = SS_all - SS_subs; % within subjects (2)-(10) 

%% Get degrees of freedom

results.DF.total  = sum(n)*q*r -1; % N = sum(n) equals p*n, when all n's are equal, or p*mean(n), when not equal
results.DF.A = p - 1;
results.DF.Aerror = sum(n)-p; 
results.DF.between = sum(n)-1;
results.DF.B = q-1;
results.DF.AB = (p-1)*(q-1);
results.DF.Berror = p*(mean(n)-1)*(q-1); % for n equal in groups p(n-1)(q-1), here the comprehensible way; correcly written: Nq-N-pq-p with N=sum(n)
results.DF.C = r-1;
results.DF.AC = (p-1)*(r-1);
results.DF.Cerror = p*(mean(n)-1)*(r-1); % same here as for last comment, for n equal in groups p(n-1)(r-1), here the comprehensible way; correcly written: Nr-N-pr-p with N=sum(n)
results.DF.BC = (q-1)*(r-1);
results.DF.ABC = (p-1)*(q-1)*(r-1);
results.DF.BCerror = p*(mean(n)-1)*(q-1)*(r-1); % same here
results.DF.within = sum(n)*(q*r-1);

%% Compute mean squares

results.MS.A = results.SS.A / results.DF.A;
results.MS.Aerror  = results.SS.Aerror / results.DF.Aerror;
results.MS.B = results.SS.B / results.DF.B;
results.MS.AB = results.SS.AB / results.DF.AB;
results.MS.Berror  = results.SS.Berror / results.DF.Berror;
results.MS.C = results.SS.C / results.DF.C;
results.MS.AC = results.SS.AC / results.DF.AC;
results.MS.Cerror  = results.SS.Cerror / results.DF.Cerror;
results.MS.BC = results.SS.BC / results.DF.BC;
results.MS.ABC = results.SS.ABC / results.DF.ABC;
results.MS.BCerror = results.SS.BCerror / results.DF.BCerror;


%% Compute F-values

results.F.A = results.MS.A / results.MS.Aerror;
results.F.B = results.MS.B / results.MS.Berror;
results.F.AB = results.MS.AB / results.MS.Berror;
results.F.C = results.MS.C / results.MS.Cerror;
results.F.AC = results.MS.AC / results.MS.Cerror;
results.F.BC = results.MS.BC / results.MS.BCerror;
results.F.ABC = results.MS.ABC / results.MS.BCerror;


%% Compute p-values

results.p.A = 1 - fcdf(results.F.A, results.DF.A, results.DF.Aerror);
results.p.B = 1 - fcdf(results.F.B, results.DF.B, results.DF.Berror);
results.p.AB = 1 - fcdf(results.F.AB, results.DF.AB, results.DF.Berror);
results.p.C = 1 - fcdf(results.F.C, results.DF.C, results.DF.Cerror);
results.p.AC = 1 - fcdf(results.F.AC, results.DF.AC, results.DF.Cerror);
results.p.BC = 1 - fcdf(results.F.BC, results.DF.BC, results.DF.BCerror);
results.p.ABC = 1 - fcdf(results.F.ABC, results.DF.BC, results.DF.BCerror);

%% Get effect specific dfs

results.df.A = [results.DF.A results.DF.Aerror];
results.df.B = [results.DF.B results.DF.Berror];
results.df.AB = [results.DF.AB results.DF.Berror];
results.df.C = [results.DF.C results.DF.Cerror];
results.df.AC = [results.DF.AC results.DF.Cerror];
results.df.BC = [results.DF.BC results.DF.BCerror];
results.df.ABC = [results.DF.ABC results.DF.BCerror];


%% make a quick check if any negative F value
if any(cell2mat(struct2cell(results.F))<0) % if so display warning
    % most likely when CT and SS of a factor are equal but differ in the,
    % e.g., 10th digit
    warning('negF:anova', ['Negative F-values can be due to rounding errors when the SS of one factor '...
        'is actually zero!\nThis can happen, for instance, when you normalize your data.'])
end
%% Display results
if nargin < 2, names = {'IV1' 'IV2' 'IV3'}; end

% display results
disp('Two-way Analysis of Variance With Repeated Measures on One-Factor (Within -Subjects) Table.')
fprintf('------------------------------------------------------------------------------------\n');
disp('SOV                           SS          df           MS             F        P ');
fprintf('------------------------------------------------------------------------------------\n');
fprintf('Between-Subjects         %11.3f%10i\n',results.SS.between,results.DF.between);
fprintf([names{1} '                      %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.A,results.DF.A,results.MS.A,results.F.A,results.p.A);
fprintf(['Error(' names{1} ')               %11.3f%10i%15.3f\n\n'],results.SS.Aerror,results.DF.Aerror,results.MS.Aerror);
fprintf('Within-Subjects          %11.3f%10i\n',results.SS.within,results.DF.within);
fprintf([names{2} '                      %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.B,results.DF.B,results.MS.B,results.F.B,results.p.B);
fprintf([names{1} ' x ' names{2} '                %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.AB,results.DF.AB,results.MS.AB,results.F.AB,results.p.AB);
fprintf(['Error(' names{2} ')               %11.3f%10i%15.3f\n\n'],results.SS.Berror,results.DF.Berror,results.MS.Berror);
fprintf([names{3} '                      %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.C,results.DF.C,results.MS.C,results.F.C,results.p.C);
fprintf([names{1} ' x ' names{3} '                %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.AC,results.DF.AC,results.MS.AC,results.F.AC,results.p.AC);
fprintf(['Error(' names{3} ')               %11.3f%10i%15.3f\n\n'],results.SS.Cerror,results.DF.Cerror,results.MS.Cerror);
fprintf([names{2} ' x ' names{3} '                %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.BC,results.DF.BC,results.MS.BC,results.F.BC,results.p.BC);
fprintf([names{1} ' x ' names{2} ' x ' names{3} '          %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.ABC,results.DF.ABC,results.MS.ABC,results.F.ABC,results.p.ABC);
fprintf(['Error(' names{2} ' x ' names{3} ')         %11.3f%10i%15.3f\n'],results.SS.BCerror,results.DF.BCerror,results.MS.BCerror);
fprintf('------------------------------------------------------------------------------------\n');
fprintf('Total                    %11.3f%10i\n',results.SS.total,results.DF.total);
fprintf('------------------------------------------------------------------------------------\n');

return

