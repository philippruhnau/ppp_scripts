function points = time2points(data, sr, bl)

% points = time2points(data, sr, bl)
% timepoints to datapoints
% input:
%
% data - timepoints (ms)
% sr   - sampling rate
% bl   - baseline (ms)

points = round((data + abs(bl))*sr/1000 + 1);