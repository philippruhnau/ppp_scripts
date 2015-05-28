function finArray = serial_permutation(n, values)

% computes a matrix of all possible permutations if those are meant to be repeated  
%
% Input:
% n                - number of elements in permutation
% values(optional) - vector of permuted elements (otherwise 1:n)
%
% the easier way to do this is to compute perms(1:n-1), but what can i do ;)

% (c) copyright P.Ruhnau, mail@philipp-ruhnau.de
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

if nargin<2, values = 1:n; end

X = flipud(perms(values));
go=0;
finArray=[];

while go ~=1

test1 = [X(1,:) X(1,:)];
test2 = [X(1,:) X(2,:)];
finArray = [finArray; X(1,:)];
X(1,:)=[];

for j =1:size(X,2)
    testArray1 = test1(1+j:size(X,2)+j);
    [~,indx,~] = intersect(X,testArray1,'rows');
    X(indx,:) = []; 
    testArray2 = test2(1+j:size(X,2)+j);
    [~,indx,~] = intersect(X,testArray2,'rows');
    X(indx,:) = [];
end
if size(X,1)<2
    go =1;
    finArray = [finArray; X];
end

end

