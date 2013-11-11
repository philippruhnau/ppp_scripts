function trans_mat = comp_trans_mat(size_data, nMeans)



A = eye(size_data,size_data);

minus_idx = floor((nMeans - 1)/2);
plus_idx = floor((nMeans)/2);
meanArray = 0:nMeans-1;

% indx = [];
for indy = 1+minus_idx:size(A,1)-plus_idx 
%     indx = find(A(indy,:),1);
    A(indy,meanArray+indy-minus_idx) = 1/nMeans;
end

% begining and end
for i = 1:minus_idx %begin
    new_nMeans = numel(1:i+plus_idx);
    A(i,1:i+plus_idx)= 1/(new_nMeans);
end
end_idxs = size(A,2)-plus_idx+1:size(A,2);
for i = 1:numel(end_idxs) % end
    new_nMeans = numel(end_idxs(i)-minus_idx:size(A,2));
    A(end_idxs(i),end_idxs(i)-minus_idx:size(A,2))= 1/(new_nMeans);
end

trans_mat = A;
