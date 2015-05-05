function [ind] = nearest_element(input_vec, targets)

% [IND] = NEAREST_ELEMENT(INPUT_VEC, TARGETS)
%
% prints the indices of the elements closest to target(s) in the input vector
% pay attention that your targets are within the input vector limits
% 
% Input:
% input_vec - vector 
% targets   - vector 
%

% (c) P.Ruhnau, 2015, e-mail: mail(at)philipp-ruhnau.de
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

ind = NaN(1,numel(targets));

for i = 1:numel(targets)
  [~, ind(i)] = min(abs(input_vec - targets(i)));
end
  
