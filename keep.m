function keep(varargin)

% function keep(varargin)
% clears all variables but the input variables (i.e., keeps only those)
% can be used in analogy to clear
%
% e.g.:
% 
% keep X Y Z
% or
% keep('X', 'Y', 'Z')

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

% get input
keep_items = varargin;

% if noinput assume wrong usage
if isempty(keep_items), error('No input arguments to keep is equivalent to ''clear all''. Was that your intention?'), end

% get caller workspace
ws = evalin('caller','whos');

% get variable names from ws
ws_cell = struct2cell(ws);
ws_names = ws_cell(1,:);

% find the ones to be cleared 
indx = false(1,numel(ws_names));
for i = 1:numel(keep_items)
    % compare for each item to keep to use regexp
    match_names = regexp(ws_names, keep_items(i));
    % find indx for items to keep    
    temp = zeros(1,numel(match_names));
    for i2 = 1:numel(match_names)
        temp(i2) = ~isempty(match_names{i2});
    end
    % combine inds
    indx = indx | logical(temp);
end
% now choose all other variables
to_clear = ws_names(~indx);

% and make string
to_clear = sprintf(' %s', to_clear{:});

% clear in caller workspace
evalin('caller', ['clear ' to_clear])