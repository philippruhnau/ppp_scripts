function ds_x = digit_sum(x)


% make sure it's a column
x = x(:);

% transform to array of split elements
elements_of_x = num2str(x)-'0';

% replace all -16 with NaN (-16 is placeholder for not given digit)
elements_of_x(elements_of_x == -16) = NaN;

% digit sum
ds_x = nansum(elements_of_x,2);