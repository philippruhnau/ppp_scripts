function [avg, covd] = compute_avg_cov(data_cell)

% function [avg, covd] = COMPUTE_AVG_COV(data_cell)
%
% computes average and covariance over trials (cell array)
%
% input:
% data - cell array of [chan x time] matrizes, each cell is one trial
%
% output:
%
% avg  - average over trials
% covd - covariance estimate over trials
%

% copyright(c), 2016, P. Ruhnau, email: mail(at)philipp-ruhnau.de, 2016-02-04
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

% v201602 - initial inplementation, PR

nT = numel(data_cell);
covd = NaN(nT, size(data_cell{1},1), size(data_cell{1},1));
avg  = zeros( size(data_cell{1},1), size(data_cell{1},2));


for iT = 1:nT

  % flip to get right order
  dat = data_cell{iT}';
  n = size(dat,1);
  % compute mean
  dat_m = dat - repmat(mean(dat), size(dat,1),1);
  % trial covariance
  covd(iT,:,:) = (dat_m' * dat_m) ./ (n-1);
  
  % running average
  avg = avg + dat';
  
end

if nT == 1
  % if only one ignore df
  covd = squeeze(sum(covd,1));
else
  % estimator, devide by trials-1
  covd = squeeze(sum(covd,1)) ./ (nT-1);
end
% mean
avg = avg ./ nT;