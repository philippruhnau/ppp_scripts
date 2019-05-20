function bic = compute_bic(residuals, p)

% Schwarz 1978 

rss = sum(residuals.^2);
n = numel(residuals);% n of cases

% this is a corrected version for smaller samples
%bic =  n + n*log(2*pi) + n* log(rss/n) + log(n)*(p+1);

bic = n * log(rss/n) + p*log(n);