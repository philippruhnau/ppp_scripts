function data = apply_SSP(cfg, data)

% function data = apply_SSP(cfg, data)
% applies SSP vectors (Neuromag) to the data
%
% mandatory input:
% data - fieldtrip structure, raw data 
% 
% optional input [default]:
% cfg.proj_sel - vector, indices of to-be-applied projections [all]
% cfg.channel  - cell of strings, labels of channels to-be projected
%                [data.label]
% cfg.bad_chan - bad channel labels [empty]
%
% output:
% data - data structure with projected data

% vers 20140211 - initial implimentation, PR

%% defaults
if ~isfield(cfg, 'proj_sel'); proj_sel = 1:length(data.hdr.orig.projs); else proj_sel = cfg.proj_sel; end
if ~isfield(cfg, 'bad_chan'); bad = data.hdr.orig.bads; else bad =   cfg.bad_chan; end
if ~isfield(cfg, 'channel'); chan = data.label(:)'; else chan = cfg.channel(:)'; end

%% do SSP projection on data (inspired by Stephen Moratti)
for k = 1:length(data.hdr.orig.projs)
    if ismember(k, proj_sel) 
    data.hdr.orig.projs(k).active = true;
    end
end

% create the projection matrix
[ proj, nproj ] = mne_make_projector(data.hdr.orig.projs(proj_sel), chan , bad);
data.hdr.orig.raw.proj = proj;
data.hdr.orig.raw.nproj = nproj;

fprintf(1,'%d projection items activated\n',nproj);

% now apply to data
for i = 1:length(data.trial)
    data.trial{i} = proj*data.trial{i};
end
