function results = rmANOVA32(X,names)

% results = ANOVA32(X, names)
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
% Description: three-way analysis of variance with repeated measurements on
%              one factor, n may be unequal groups
% ----------------------------------------------------------------
% P.Ruhnau, Email: ruhnau@uni-leipzig.de, 2011-08-19

p = numel(unique(X(:,2))); % number of between factor steps (groups)
q = numel(unique(X(:,3))); % number of within factor steps WF1
n = hist(X(:,2));
n = n(n~=0)./(q);
% N = sum(n); 


% sum of squares
CT =  (sum(X(:,1))^2)/(p*q*mean(n)); % correction term (1)
SS_all = sum(X(:,1).^2); % sum of all sqares (2)

%% SS single factors
sums_A = zeros(1,p);
for i_p = 1:p
sums_A(i_p)  = (sum(X(X(:,2)==i_p,1))^2)/(n(i_p)); % devide by group n (necessary for n unequal)
end
SS_A = sum(sums_A)/(q);% SS between factor (3)

sums_B = zeros(1,q);
for i_q = 1:q
sums_B(i_q) = sum(X(X(:,3)==i_q,1))^2; 
end
SS_B = sum(sums_B)/(sum(n));% SS fist within factor (4)


%% SS two facors
sums_AB = zeros(p,q);
for i_p = 1:p
    for i_q = 1:q
        sums_AB(i_p,i_q) = (sum(X(X(:,2)==i_p&X(:,3)==i_q,1))^2)/n(i_p); % devide by group n (necessary for n unequal)
    end
end
SS_AB = sum(sum(sums_AB)); % SS between with first within factor (5)


%% SS Subjects and factors with Subjects
sums_subs = nan(p,max(n));
for i_p = 1:p    
    for sub = 1:n(i_p)
        sums_subs(i_p,sub) = sum(X(X(:,2)==i_p&X(:,4)==sub,1))^2; % sum of single subjects over all within factor steps
    end
end
SS_subs = sum(nansum(sums_subs))/(q); % SS single subjects (6)

sums_ABsubs = nan(p,q,max(n));
for i_p = 1:p   
    for i_q = 1:q
        for sub = 1:n(i_p)
            sums_ABsubs(i_p,i_q,sub) = sum(X(X(:,2)==i_p&X(:,3)==i_q&X(:,4)==sub,1))^2;
        end
    end
end
SS_ABsubs = sum(sum(nansum(sums_ABsubs))); % SS between with first within factor with single subjects (7)


%% Compute squared sums for statistic values

results.SS.total  = SS_all - CT; % (2) - (1)
results.SS.A = SS_A - CT; % between (3)-(1)
results.SS.Aerror  =  SS_subs - SS_A; % (6)-(3)
results.SS.between = SS_subs - CT; % between subs (6)-(1)
results.SS.B = SS_B - CT;% first within (4)-(1)
results.SS.AB = SS_AB - SS_A - SS_B + CT;% between x first within (5)-(3)-(4)+(1)
results.SS.Berror = SS_ABsubs - SS_AB - SS_subs + SS_A; % first within error (7)-(5)-(6)+(3)
results.SS.within = SS_all - SS_subs; % within subjects (2)-(6) 

%% Get degrees of freedom

results.DF.total  = sum(n)*q -1; % N = sum(n) equals p*n, when all n's are equal, or p*mean(n), when not equal
results.DF.A = p - 1;
results.DF.Aerror = sum(n)-p; 
results.DF.between = sum(n)-1;
results.DF.B = q-1;
results.DF.AB = (p-1)*(q-1);
results.DF.Berror = p*(mean(n)-1)*(q-1); % for n equal in groups p(n-1)(q-1), here the comprehensible way; correcly written: Nq-N-pq-p with N=sum(n)
results.DF.within = sum(n)*(q-1);

%% Compute mean squares

results.MS.A = results.SS.A / results.DF.A;
results.MS.Aerror  = results.SS.Aerror / results.DF.Aerror;
results.MS.B = results.SS.B / results.DF.B;
results.MS.AB = results.SS.AB / results.DF.AB;
results.MS.Berror  = results.SS.Berror / results.DF.Berror;


%% Compute F-values

results.F.A = results.MS.A / results.MS.Aerror;
results.F.B = results.MS.B / results.MS.Berror;
results.F.AB = results.MS.AB / results.MS.Berror;


%% Compute p-values

results.p.A = 1 - fcdf(results.F.A, results.DF.A, results.DF.Aerror);
results.p.B = 1 - fcdf(results.F.B, results.DF.B, results.DF.Berror);
results.p.AB = 1 - fcdf(results.F.AB, results.DF.AB, results.DF.Berror);


%% Get effect specific dfs

results.df.A = [results.DF.A results.DF.Aerror];
results.df.B = [results.DF.B results.DF.Berror];
results.df.AB = [results.DF.AB results.DF.Berror];

%% Display results
if nargin < 2, names = {'IV1' 'IV2'}; end

% display results
disp('Two-way Analysis of Variance With Repeated Measures on One-Factor (Within -Subjects) Table.')
fprintf('-----------------------------------------------------------------------------------\n');
disp('SOV                           SS          df           MS             F        P ');
fprintf('-----------------------------------------------------------------------------------\n');
fprintf('Between-Subjects         %11.3f%10i\n',results.SS.between,results.DF.between);
fprintf([names{1} '                      %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.A,results.DF.A,results.MS.A,results.F.A,results.p.A);
fprintf(['Error(' names{1} ')               %11.3f%10i%15.3f\n\n'],results.SS.Aerror,results.DF.Aerror,results.MS.Aerror);
fprintf('Within-Subjects          %11.3f%10i\n',results.SS.within,results.DF.within);
fprintf([names{2} '                      %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.B,results.DF.B,results.MS.B,results.F.B,results.p.B);
fprintf([names{1} ' x ' names{2} '                %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.AB,results.DF.AB,results.MS.AB,results.F.AB,results.p.AB);
fprintf(['Error(' names{2} ')               %11.3f%10i%15.3f\n\n'],results.SS.Berror,results.DF.Berror,results.MS.Berror);
fprintf('---------------------------------------------------------------------------------------------------\n');
fprintf('Total                    %11.3f%10i\n',results.SS.total,results.DF.total);
fprintf('---------------------------------------------------------------------------------------------------\n');

return

