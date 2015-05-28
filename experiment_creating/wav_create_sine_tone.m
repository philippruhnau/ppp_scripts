function y = wav_create_sine_tone(cfg);

% y = wav_create_sine_tone(cfg);
%
% Input, e.g. (defaults):
%	cfg.fname = 'filename.wav'; % optional
%	cfg.freq  = 250; % frequency of the tone in [Hz]
%	cfg.amp   = 1; % amplitude of tone
%	cfg.nbits = 16;
%	cfg.fs    = 44100; % sampling frequency
%	cfg.dur   = 0.5; % duration in [s]
%	cfg.rf    = 0.01; % rise and fall time in [s] (the time is used for rise and fall individually)
%
% --------------------------------------------------
% Creates a sine tone, including rise and fall times
% copyright (c) 2010, Björn Herrmann, Email: bherrmann@cbs.mpg.de, 2010-03-01

% Load some defaults if appropriate
% ---------------------------------
if ~isfield(cfg, 'freq'),  cfg.freq  = 250; end
if ~isfield(cfg, 'amp'),   cfg.amp   = 1; end
if ~isfield(cfg, 'nbits'), cfg.nbits = 16; end
if ~isfield(cfg, 'fs'),    cfg.fs    = 44100; end
if ~isfield(cfg, 'dur'),   cfg.dur   = 0.5; end
if ~isfield(cfg, 'rf'),    cfg.rf    = 0.01; end

% Initialize some parameters
% --------------------------
dt    = 1 / cfg.fs; % get delta t
t     = [0:dt:cfg.dur]';
nsamp = round(cfg.dur * cfg.fs);
rf_window = tukeywin(nsamp, (cfg.rf * 2) / cfg.dur);

% Get pure tones, including rise and fall time
% --------------------------------------------
tone = cfg.amp * sin(2*pi*cfg.freq*t(1:size(rf_window,1)));
y    = tone .* rf_window;

% Write new wavfile
% -----------------
if isfield(cfg, 'fname')
	wavwrite(y, cfg.fs, cfg.nbits, cfg.fname);
end
