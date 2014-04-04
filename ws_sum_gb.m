function ws_sum_gb

% function [si_who] = ws_sum_gb(whos)
% calculates current working memory size in GB

% copyright (c), 2014, P. Ruhnau, email: mail(at)philipp-ruhnau.de, 2014-04-04
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

ws = evalin('caller','whos');

sum_b = 0;
for i = 1:numel(ws)
    sum_b = sum_b + ws(i).bytes;
end

si_who = (sum_b / 2^30);

disp(['You have ' num2str(round(si_who*1e3)/1e3) ' GB in your workspace']) 