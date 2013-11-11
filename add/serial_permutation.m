function finArray = serial_permutation(n, values)

% computes a matrix of all possible permutations if those are meant to be repeated  
%
% Input:
% n                - number of elements in permutation
% values(optional) - vector of permuted elements (otherwise 1:n)
%
% the easier way to do this is to compute perms(1:n-1), delivers the same
% result!!!
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

