function meeg_plot_topography(cfg, data)

% meeg_plot_topography(cfg)
%
% Input:
%	data             - data vector: channels x 1
%	cfg.pos          - channel pos x 3 for 3D, and pos x 2 for 2D
%	cfg.tri          - triangulation: faces x 3
%	cfg.limits       - theshold [min max]
%	cfg.visualize    - either 'interpolate' or 'points'
%	cfg.title        - plot name
%	cfg.set_view     - for 3D plots, define the view
%	cfg.mapcolor     - Nx3 color map, if empty or undefined blue/gray/red (default)
%

% -----------------------------------------------------------------
% copyright (c) 2012, Philipp Ruhnau, mail@philipp-ruhnau.de
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

% Load defaults if appropriate
% ----------------------------

if nargin <2,      fprintf('Error: Data vector needs to be defined.\n'); return; end
if ~isfield(cfg, 'pos'),       fprintf('Error: Positions need to be defined.\n'); return; end
if size(cfg.pos,2) == 2, cfg.pos(:,3) = 1; del_tri = 2; else del_tri = 3; end % add third row with ones for 2D and define delauney dimension
if ~isfield(cfg, 'limits'),    cfg.limits     = [min(data) max(data)]; end
if ~isfield(cfg, 'visualize'), cfg.visualize  = 'interpolate'; end
if ~isfield(cfg, 'title'),   cfg.title    = ''; end
if ~isfield(cfg, 'set_view'),  cfg.set_view   = [0 90]; end

font_size = 20;

% Get colormap for helmet plotting
% --------------------------------
if isfield(cfg, 'mapcolor') && ~isempty(cfg.mapcolor)
	mycolor = cfg.own_cmap;
else % default map is blue-gray-red
    csteps = 45;
		colstart = [0 0 0.8]; % blue
		colmiddle = [0.95 0.95 0.95]; %gray
		colend = [0.8 0 0]; % red
		mycolor = ones(csteps, 3);
		mycolor(1:ceil(csteps/2), 1) = linspace(colstart(1), colmiddle(1), ceil(csteps/2))'; %red
		mycolor(ceil(csteps/2):end, 1) = linspace(colmiddle(1), colend(1), ceil(csteps/2))'; %red
		mycolor(1:ceil(csteps/2), 2) = linspace(colstart(2), colmiddle(2), ceil(csteps/2))'; %green
		mycolor(ceil(csteps/2):end, 2) = linspace(colmiddle(2), colend(2), ceil(csteps/2))'; %green
		mycolor(1:ceil(csteps/2), 3) = linspace(colstart(3), colmiddle(3), ceil(csteps/2))'; %blue
		mycolor(ceil(csteps/2):end, 3) = linspace(colmiddle(3), colend(3), ceil(csteps/2))'; %blue
	
end

% figure;
if strcmp(cfg.visualize, 'points')
	scatter3(cfg.pos(:,1), cfg.pos(:,2), cfg.pos(:,3), 3, data)
elseif strcmp(cfg.visualize, 'interpolate')
	if ~isfield(cfg, 'tri')
        if del_tri == 3
            tri = delaunay(cfg.pos(:,1), cfg.pos(:,2), cfg.pos(:,3));
        else
            tri = delaunay(cfg.pos(:,1), cfg.pos(:,2));
        end
	else
		tri = cfg.tri;
	end
	trisurf(tri, cfg.pos(:,1), cfg.pos(:,2), cfg.pos(:,3), data, 'FaceColor', 'interp', 'EdgeColor', 'interp');
	hold on;
	plot3(cfg.pos(:,1), cfg.pos(:,2), cfg.pos(:,3), 'k.');
else
	fprintf('Wrong visualization property.\n');
end	

hold on;
caxis([cfg.limits(1) cfg.limits(2)]);
title(cfg.title);
colormap(mycolor);
if isfield(cfg, 'colorbar') && cfg.colorbar == true
colorbar('location','EastOutside', 'FontSize', font_size);
end
grid on;
daspect([1,1,1]);
xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis');
view(cfg.set_view(1), cfg.set_view(2));


