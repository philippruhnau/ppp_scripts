function new_dist = change_dist(x, new_mean, new_rg)
%
% Usage: change_dist(data, new mean, new range)
% changes range and mean of distribution of N by 2 matrix for each column
% individually to new parameters 
%
% CAVE: range is equally large in all columns afterwards

% (c) copyright 2012. P.Ruhnau. philipp.ruhnau@yahoo.de
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