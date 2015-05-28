function [nw] = rand_network(n)

% function [nw] = rand_network(n, cfg)
%
% creates a connectivity matrix of a random network of node size n
%
% input:
%
% n - nodes
%
% output:
%
% nw - n by n matrix of random pseudo connectivity values
%
% 

% copyright (c), 2014, P. Ruhnau, email: mail@philipp-ruhnau.de, 2014-01-22
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

nw = zeros(n);

for i = 1:n
   nw(i+1:end,i) = rand(n-i,1);
end

nw = nw + nw';
