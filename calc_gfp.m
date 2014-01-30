function [GFP DIS] = calc_gfp(X, avgRef, normFac)

% calculates the global field power (GFP) by calculating the square root on
% the mean of all squared differences between sensors at each timepoint
%
% mandatory input:
%
% X       - N by M matrix (sensors by timepoints)
% avgRef  - set 0 if no average reference calculation wanted
% normFac - normalization factor, sting, global field potential ('gfp');
%           maximum amplitude difference ('maxdif'), or 'none'
%
% output:
%
% GFP - global field power (1 x M)
% DIS - dissimilarity index (1 x M-1)
%
% Reference:
%
% Lehmann, D. & Skrandies, W. Reference-free identification of components
%   of checkerboard-evoked multichannel potential fields. Electroencephalogr
%   and Clinical Neurophysiology, 1980, 48, 609-621
% Lehmann, D. & Skandries, W. Spatial analysis of evoked potentials in man-
%   a review. Progress in Neurobiology, 1984, 23, 227-250.
%

% ----------------------------------------------------
% P.Ruhnau, Email: mail@philipp-ruhnau.de, 07-18-2012
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

if nargin < 2; avgRef = 1; end
if nargin < 3; normFac = 'gfp'; end

% average reference if needed
if avgRef == 1
    X = X - repmat(mean(X,1), size(X,1),1);
end

%% global field power

GFP = std(X);

%% dissimilarity index

% normalize by GFP or magnitude difference
if strcmp(normFac, 'gfp')
    normX = X ./ repmat(GFP, size(X,1),1);
elseif strcmp(normFac, 'maxdif')
    normX = X ./ repmat(max(X)-min(X), size(X,1),1);
else % no normalization
    normX = X; 
end 
   
% differences between adjacent maps (timepoints)
dif_data = diff(normX,1,2);
% DIS = sqrt(mean(dif_data.^2,1)); %next is estimator
DIS = std(dif_data);

