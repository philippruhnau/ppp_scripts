function data = lookup_roi(cfg, data)

% function data = lookup_roi(cfg, data)
% 
% creates a mask, an index, and a name field in your data for a specified
% region of interest (roi) extracted from an atlas
%
% mandatory input:
% cfg.roi - region of interest (needs to be in the atlas)
% data    - source data structure (anything containing 3d positions
%           basically)
%
% optional [defaults]:
% cfg.atlas      - filename of atlas or struct [TTatlas+tlrc.BRIK]
% cfg.inputcoord - coordinate system of input ['mni']
% 
% output:
% data - same as input but additional fields roi_mask (, roi_ind

% copyright (c), 2014, P. Ruhnau, email: mail@philipp-ruhnau.de, 2014-01-29
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
%


% defaults
if ~isfield(cfg, 'atlas'), atlas = '/Users/ruhnau/Documents/work/atlas/TTatlas+tlrc.BRIK'; else atlas = cfg.atlas; end
if ~isfield(cfg, 'roi'), error('If you want to look for a ROI then you should specify a ROI (cfg.roi empty)'); else roi = cfg.roi; end
if isfield(cfg, 'inputcoord'), coord = cfg.inputcoord; else coord = 'mni'; end


cfg =[];

if ischar(atlas)
    % read atlas
    cfg.atlas = ft_read_atlas(atlas);
else
    cfg.atlas = atlas;
end

% convert data and atlas to cm
data = ft_convert_units(data, 'cm');
cfg.atlas = ft_convert_units(cfg.atlas, 'cm');


cfg.inputcoord = coord;
cfg.roi = roi;

data.mask_roi=ft_volumelookup(cfg, data);
% for some reason double needed for the mask??? wtf
data.roi_mask = double(data.mask_roi);
data.roi_ind  = find(data.mask_roi(data.inside)==1);
data.roi_name = roi;