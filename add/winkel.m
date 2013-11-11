function [beta] = winkel(l, g)
% 'l' length
% 'g' distance
% calculates visual angle
beta = 2 * atan(l/(2*g));
beta = beta * 180/pi;
