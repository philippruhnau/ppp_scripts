function [h] = plot_polar(input)

% PLOT_POLAR(input)
% wrapper to plot normalized rose plots
%
% input - vector of radians

h = polar(repmat(input(:)', 2, 1), repmat([0 1]', 1, length(input)), 'k');