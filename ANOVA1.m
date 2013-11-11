function results = ANOVA1(data,grps,table, names)

% results = ANOVA1(data,grps,table, names)
%
% Input:
%   data - vector of datapoints for all subjects
%   grps - vector indicating factor step (n may be unequal)   
% 
% optional:
%   table - set 1 if tabular results presentation desired
%   names - name of factor
%
% Reference:
%	Bortz (1999) Statistik f???r Sozialwissenschaftler. Springer Verlag
%
% Description: one-way analysis of variance, n may be not equal in all groups

% ----------------------------------------------------------------
% P.Ruhnau, Email: ruhnau@uni-leipzig.de, 2011-08-19
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

mean_total = mean(data(:)); % total mean

for s = 1:numel(unique(grps))
mean_grps(s)  = mean(data(grps==s)); % mean over factor steps
end


N = size(data, 1); % number of subjects
n = hist(grps);
n = n(n~=0);
p = numel(unique(grps)); % number of factor steps

% Compute squares of sum
% ----------------------
results.SS.total  = sum((data - mean_total).^2);
results.SS.effect = sum(n.*(mean_grps - mean_total).^2);
results.SS.error  = results.SS.total - results.SS.effect; % this is SSw

% Get degrees of freedom
% ----------------------

results.DF.total  = N - 1;
results.DF.effect = p - 1;
results.DF.error  = N - p;


% Compute mean squares
% --------------------
results.MS.total  = results.SS.total / results.DF.total;
results.MS.effect = results.SS.effect / results.DF.effect;
results.MS.error  = results.SS.error / results.DF.error;

results.F = results.MS.effect / results.MS.error;
results.p = 1 - fcdf(results.F, results.DF.effect, results.DF.error);
results.df = [results.DF.effect results.DF.error];

if nargin < 4,  names = {'IV1'}; end
if nargin < 3, table = 0; end
if table == 1
% display results
disp('One-way Analysis of Variance Table.')
fprintf('-----------------------------------------------------------------------------------\n');
disp('SOV                           SS          df           MS             F        P ');
fprintf('-----------------------------------------------------------------------------------\n');
fprintf('Between-Subjects         \n');
fprintf([names{1} '                      %11.3f%10i%15.3f%14.3f%9.4f\n'],results.SS.effect,results.DF.effect,results.MS.effect,results.F,results.p);
fprintf(['Error(' names{1} ')               %11.3f%10i%15.3f\n\n'],results.SS.error,results.DF.error,results.MS.error);
fprintf('---------------------------------------------------------------------------------------------------\n');
fprintf('Total                    %11.3f%10i\n',results.SS.total,results.DF.total);
fprintf('---------------------------------------------------------------------------------------------------\n');
end



return

