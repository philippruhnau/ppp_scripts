function info = normalize_wave_to_rms(cfg)

% info = normalize_wave_to_rms(cfg)
%
% Input, e.g. (defaults):
%	cfg.wavfile = 'test.wav';
%	cfg.outfile = 'scram_test.wav';
%	cfg.rms_ny  = 0.1; % RMS for the normalized wave (y)
%
% Output:
%	info.min - gives the minimum value of the amplitude
%	info.max - gives the maximum value of the amplitude
%
% -------------------------------------------------------------------------------
% Normalizes to a given RMS, for each channel of the wave file separately.
% copyright (c) 2010, Björn Herrmann, Email: bherrmann@cbs.mpg.de, 2010-03-01

% Load some defaults if appropriate
% ---------------------------------
if ~isfield(cfg, 'wavfile'), fprintf('Error: cfg.wavfile needs to be defined.\n'); return; end
if ~isfield(cfg, 'outfile'), fprintf('Error: cfg.outfile needs to be defined.\n'); return; end
if ~isfield(cfg, 'rms_ny'),  cfg.rms_ny = 0.1; end

fprintf('Normalizing: %s ... ', cfg.outfile);

% Read wavefile
% -------------
[y, fs, nbits] = wavread(cfg.wavfile);
for i = 1 : size(y,2)
	rms_y  = sqrt(sum(y(:,i).^2)/size(y,1));
	factor = cfg.rms_ny / rms_y;
	ny(:,i)     = y(:,i) * factor;
end

info.min = min(ny);
info.max = max(ny);

if max(abs(info.min)) > 1 | max(abs(info.max)) > 1
		fprintf('Info: %s includes an amplitude value higher than 1.', cfg.outfile);
end

% Write new wavefile
% ------------------
wavwrite(ny, fs, nbits, cfg.outfile);
fprintf('done\n');

