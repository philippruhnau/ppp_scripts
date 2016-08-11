function [h] = plot_polar(input, rad, color, linewidth)

% PLOT_POLAR(input)
% wrapper to plot normalized rose plots
%
% input - vector of radians
%
% optional
% rad - radius of the lines [1]
% color - color of the lines ['k']
% linewidth - [1]
% 

if nargin < 2, rad = 1; end
if nargin < 3, color = 'k'; end
if nargin < 4, linewidth = 1; end

h = polar(repmat(input(:)', 2, 1), repmat([0 rad]', 1, length(input)), color);



for iL = 1:numel(h)
  % change width
  h(iL).LineWidth = linewidth;
end

