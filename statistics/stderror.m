function sem = stderror(data) 

% function sem = stderror(stats)
% calculates the standard error of the mean columnwise in n by m array
% stats
%
% if groups have unequal n, replace missing values with NaNs

% (c) P.Ruhnau, 2012, e-mail: mail(at)philipp-ruhnau.de
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