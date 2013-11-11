function new_dist = change_dist(x, new_mean, new_rg)
%
% Usage: change_dist(data, new mean, new range)
% changes range and mean of distribution of N by 2 matrix for each column
% individually to new parameters 
%
% CAVE: range is equally large in all columns afterwards

% definitions
dif = zeros(1,size(x,2));
ratio = dif;
t = zeros(size(x));

% changing the range by computing maximal differences (old range) and 
% relation to new range, finaly multiplying old matrix with ratio 
for i = 1:size(x,2)
dif(i) = max(x(:,i)) - min(x(:,i)); 
ratio(i) = new_rg* 1/dif(i); 
t(:,i) = x(:,i).*ratio(i); 
end

% moving distribution from current to desired mean
new_dist = (t - repmat(mean(t)-new_mean,size(t,1),1));