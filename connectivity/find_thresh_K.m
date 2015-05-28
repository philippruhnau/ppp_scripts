function thresh = find_thresh_K(data, K)

% find a certain threshold for a connectivity matrix for a desired
% number of edges (K)
%
% similar to a staircase



sorted_data = sort(data(:));
thresh = sorted_data(ceil(K));





% 
% 
% % well one can do it the hard way
% 
% if K > size(data)/2, error('Too many edges for this adjacency matrix'), end
% 
% % take upper and lower boundary and create with hundred points 
% threshArray = [min(min(data)) max(max(data))];
% threshArray = threshArray(1):threshArray(2)/100:threshArray(2);
% threshArray = threshArray(2:end);
% 
% % starting threshold
% thresh = threshArray(1);
% 
% % initialize counter
% count = 1;
% track_count = [];
% 
% % now loop until threshold is found
% while sum(sum(data>thresh)) ~= K*2
%     
% %     keep tract of the last counts to stop while in case
% track_count = [track_count count];
% if numel(track_count) ~= numel(unique(track_count))
%     return
% end
%         
%     if sum(sum(data>thresh)) > K*2
%         count = count+1;
%         thresh = threshArray(count);
% 
%     elseif sum(sum(data>thresh)) < K*2
%         count = count-1;
%         thresh = threshArray(count);
% 
%     end
% end
% 
% disp(['Threshold = ' num2str(thresh)])