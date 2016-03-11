function [output] = rad2deg2rad(input, type)
% computes degrees out of radians or radians out of degrees
%
% input = degree or radians
% type  = desired output ('deg' or 'rad')
%
% output = radians or degrees
% 

if strcmp(type, 'rad')
   % in case larger than 360
  input = rem(input, 360);
  % transform
  output = (input * pi) ./ 180;
elseif strcmp(type, 'deg')
  % in case values larger than pi, remove multiples
  input = rem(input, pi);
  % transform
  output = (input * 180) ./ pi;
else
  error('unkown output')
end