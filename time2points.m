function points = time2points(x, sr, bl)

% points = time2points(data, sr, bl)
% timepoints to datapoints
% input:
%
% x  - timepoints (ms)
% sr - sampling rate
% bl - baseline (ms)

points = round((x + abs(bl))*sr/1000 + 1);