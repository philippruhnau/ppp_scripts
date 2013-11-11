function results = rmANOVA1(data)

% this is a slightly modified version of a script by B.Herrmann
% results = rmANOVA1(data)
%
% Input:
%	data - subjects x conditions
%
% Reference:
%	Bortz (1999) Statistik f�r Sozialwissenschaftler. Springer Verlag
%
% Description: one-way repeated measures analysis of variance
% ----------------------------------------------------------------
% B.Herrmann, Email: bherrmann@cbs.mpg.de, 2010-11-03

mean_total = mean(data(:)); % total mean
mean_meas  = mean(data,2); % mean over measurements
mean_subj  = mean(data,1); % mean over subjects

n = size(data, 1); % number of subjects
p = size(data, 2); % number of measurements

% Compute squares of sum
% ----------------------
results.SS.total  = sum(sum((data - mean_total).^2));
results.SS.betw   = p * sum((mean_meas - mean_total).^2);
results.SS.within = sum(sum((data - repmat(mean_meas,1,p)).^2));
results.SS.effect = n * sum((mean_subj - mean_total).^2);
results.SS.error  = results.SS.within - results.SS.effect;

% Get degrees of freedom
% ----------------------
results.DF.total  = n * p - 1;
results.DF.betw   = n - 1;
results.DF.within = n * (p - 1);
results.DF.effect = p - 1;
results.DF.error  = (n - 1) * (p - 1);

% Compute mean squares
% --------------------
results.MS.total  = results.SS.total / results.DF.total;
results.MS.betw   = results.SS.betw / results.DF.betw;
results.MS.within = results.SS.within / results.DF.within;
results.MS.effect = results.SS.effect / results.DF.effect;
results.MS.error  = results.SS.error / results.DF.error;

results.F = results.MS.effect / results.MS.error;
results.p = 1 - fcdf(results.F, results.DF.effect, results.DF.error);
results.df = [results.DF.effect results.DF.error];

return

