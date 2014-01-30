function K = find_K_density(kden, N)
% function K = find_K_density(kden, N)
% calculate number of edges (K) based on network nodes and (desired) density
%
% input:
% kden - density
% N    - nodes
%
% output
% K    - edges 

% copyright (c), 2014, P. Ruhnau, email: mail@philipp-ruhnau.de, 2014-01-28
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


K = kden * ((N^2-N)/2);