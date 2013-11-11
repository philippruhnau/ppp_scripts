function sem = stderror(data) 

% function sem = stderror(stats)
% calculates the standard error of the mean columnwise in n by m array
% stats
%
% if groups have unequal n, replace 'missing values with NaNs


% for unequal group sizes NaNs in arrays, to have equal length, remove
% before computation

if ~any(isnan(data(:))) 
    sem = std(data)./sqrt(size(data,1));
else
    sem = NaN(1,size(data,2));
    for i = 1:size(data,2)
        sem(i) = nanstd(data(:,i))./sqrt(size(data(~isnan(data(:,i)),i),1));
    end
        
end