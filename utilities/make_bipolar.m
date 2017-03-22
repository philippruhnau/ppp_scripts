function data = make_bipolar(data, combining_array)

% function [data] = MAKE_BIPOLAR(data, combining_array)
% creates a new data set in which the data are re-referenced according to
% an input array such that measurements for input measures a,b,c,d with the
% combining_array [a b; b c; c d] results in new data a-minus-b,b-c,c-d 
%
% input
% data            - cell array of trials with electrode-by-time arrays
% combining_array - numeric n by 2 array defining how to reference, if one
%                   of the elements is a NaN then the original channel is
%                   kept without re-referencing
% 

%% first create a new label field
new_labels = cell(size(combining_array,1)+sum(~ismember(1:length(data.label), unique(combining_array(~isnan(combining_array))))),1);
% index for labels that are not combined
non_comb_labels = find(~ismember(1:length(data.label), unique(combining_array(~isnan(combining_array)))));
for i = 1:length(new_labels)
  if i <= size(combining_array,1)
    new_labels{i} = strjoin({num2str(combining_array(i,1)) num2str(combining_array(i,2))},'-');
  else
    for j = 1:numel(non_comb_labels)
      new_labels{i+j-1} = data.label{non_comb_labels(j)};
    end
    break
  end
end

%% now new data
new_data = cell(size(data.trial));


% loop through trials
for iT = 1:length(new_data)
  % now fill with new computations
  % first differences
  for iChan = 1:size(combining_array,1)
    if any(isnan(combining_array(iChan,:)))
      % if one of a pair is a nan then the user doesn't want a subtraction
      new_data{iT}(iChan,:) = data.trial{iT}(combining_array(iChan,~isnan(combining_array(iChan,:))),:);
    else % here do subtraction of two channels
      new_data{iT}(iChan,:) = diff(data.trial{iT}(combining_array(iChan,:),:));
    end
  end
  
  % add the non combined channels to the end
  new_data{iT}(iChan+1:iChan+numel(non_comb_labels),:) = data.trial{iT}(non_comb_labels,:);
  
end

%% change input to output data
data.label = new_labels;
data.trial = new_data;