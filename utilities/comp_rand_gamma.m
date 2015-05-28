function [gammaVec, gammaVecScaled, gammaRaw, stats] = comp_rand_gamma(cfg)

% [gammaVec, gammaVecScaled, gammaRaw, stats] = COMP_RAND_GAMMA(cfg)
% computes gamma distributed random numbers 
%
% this function is calling gamrnd(a,b,n,1) and adding some extras in the
% process (see below)
%
% optional input [defaults]:
%
% cfg.a - shape parameter a (also called k) [1]
% cfg.b - scaling parameter b (also called theta or 1/beta) [1]
% cfg.n - n of numbers [101]
%
% cfg.mean.n - number of repeated drawings [3], 'smoothens' the
%              distribution, thus, making outliers at the edges 
%              less likely (see below)
% cfg.mean.method - string, 'mean' or 'median' ['mean']
%
% cfg.scale.val - scaling factor (e.g., if distribution is normalized), if
%                 defined empty the distribution is scaled to have a
%                 maximum of 1
%

% copyright (c), 2012, P. Ruhnau, email: mail@philipp-ruhnau.de, 2012-11-12
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


% defaults
if nargin<1; 
    cfg.a = 1;
    cfg.b = 1;
    cfg.n = 101;
    % send warning and defaults
    fprintf(['WARNING: --------------------------------------------------------\n'...
                  'You are computing gamma distributed random numbers using defaults\n' ...
            'That means a = 1, b = 1, and n = 101 (numbers created)\n' ...
            'No scaling is done.\n' ...
            'If you don''t know what that means, don''t use this function! \n' ...
            '-----------------------------------------------------------------\n'])
end
if ~isfield(cfg, 'a'), cfg.a = 1; end % exponential distribution 
if ~isfield(cfg, 'b'), cfg.b = 1; end % scaling to one -->mean at cfg.a
if ~isfield(cfg, 'n'), cfg.n = 101; end % 101 random numbers

% set parameters
a = cfg.a;
b = cfg.b;
n = cfg.n;

if isfield(cfg, 'mean') 
    % CAVE: this is meant to deal with outliers (resp. very high/low edge 
    % points) by computing the mean or median over (sorted) repeated 
    % random distributions (the more the merrier) with the same parameters
    % alternatively the distribution could be reduced to 90% of its
    % variance
    % NOT recommended for small sample sizes (cfg.n)
    if isfield(cfg.mean, 'n'), 
      nMean = cfg.mean.n; 
    else
      nMean = 3; 
    end
    if ~isfield(cfg.mean, 'method')
      cfg.mean.method = 'mean'; 
    end
    
    gammaRaw = NaN(nMean,n);
    for j = 1:nMean
      [gammaRaw(j,:), indx] = sort(gamrnd(a, b, n, 1));
    end
    if strcmp(cfg.mean.method, 'mean')
      gammaVec = mean(gammaRaw);
    elseif strcmp(cfg.mean.method, 'median')
      gammaVec = median(gammaRaw);
    end
    % undo sorting
    gammaVec = gammaVec(indx);
else
    gammaRaw = [];
    gammaVec = gamrnd(a, b, n,1)';
end

% scaling
if isfield(cfg, 'scale')
    % use this option if you want your values to have a specific maximum
    % (i.e. be in a specific range), you could also scale by adjusting the
    % 'scale' parameter b, but I find this a bit more convenient
    if ~isfield(cfg.scale, 'val'), 
        scVal = max(gammaVec); %scale to maximum (i.e. new maximum 1)
    else
        scVal = cfg.scale.val;
    end
    gammaVecScaled = gammaVec.*repmat(1/scVal,1,size(gammaVec,2));
else
    gammaVecScaled = [];
end

%% stats
stats.max  = (a-1)*b; % maximum
stats.mean = a*b; % mean
stats.var = a*b^2; % variance
