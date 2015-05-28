function [X2, dof, p] = chi2test(successes, trials, probab)
%[X2, dof, p] = chi2test(successes, trials, [probab])
%
%   performs Chi-Squared Test. Be aware of the meaning of this statistical
%   test. It does only tell you if two variables are independent or
%   associated.. nothing about the direction of the association!
%   
%   INPUT variables.
%   successes: a vector containing the number of correct responses of each subject.
%   trials: a vector containing the number of valid trials for each subject
%   (i.e., sum of successes and failures).
%   probab: the probability of having a success under the rules of chance
%   (default is 1/2 or 0.5).
%   
%   OUTPUT variables.
%   X2: chi-squared value of the test.
%   dof: degrees of freedom (must be n-1, otherwise there is an error).
%   p: p-value or probability of error when rejecting the null hypothesis
%   (H0 = probability of success is at chance level).
%   
%   copyright(c), 2013, L. Magazzini, email: lorenzomagazzini@gmail.com, 2013-06-11

if nargin<3
    probab = 0.5;
end

for iSub = 1:numel(successes)
    expected_successes(iSub) = trials(iSub)*probab;
    individual_X2(iSub) = ((successes(iSub) - expected_successes(iSub))^2)/expected_successes(iSub);
end

individual_X2(isnan(individual_X2)) = 0;

X2 = sum(individual_X2);
dof = length(successes)-1;
p = 1 - chi2cdf(X2, dof);

end
