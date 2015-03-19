function caml = plot_caret_style(name, resolution, material_mode, view_angle, save_figure)

% function plot_caret_style(name, resolution, material_mode, view_angle)
% takes a figure (surface plot) and rotates it to some viewing angles
% and move the camlight respectively
%
% use this directy after you created the surface plot with ft_sourceplot
% with the option cfg.camlight = 'no' (otherwise it will be too bright)
%
%
% Input:
% mandatory:
% name - string, place+name of to be saved file without ending
% optional:
% resolution    - number, dots per inch (default: 200)
% material_mode - 'shiny', 'dull', 'metalic', or see the help of the
%                 material function (default: a mixture between 'dull' and
%                 'shiny')
% view_angle    - 'right', 'left', 'occipital', 'frontal', 'dorsal',
%                 'ventral', 'all' (default), or 2D coordinates [x y]
% save_figure   - 1 for yes [default]
%
% Output:
% caml - camera light pointer (in case you want to move the image
%        afterwards you need to take the light with you)

%% defaults
if nargin < 2 || isempty(resolution)
  resolution = 200; % default dpi
end
if nargin < 4
  view_angle = 'all';
end
if nargin < 5
  save_figure = 1;
end

%% user feedback
if save_figure == 1
  disp(' --- ')
  disp('Saving output files')
  disp(' --- ')
end
%% make image bigger bigger (twice seems to be a nice size in the end)
for i = 1:2
  set(gca, 'Position', get(gca, 'OuterPosition'))
end

%% set material (shiny vs dull)
if nargin < 3 || isempty(material_mode)
  material([0.3,0.9,0.2]) %a little shiny but not too much
else
  material(material_mode);
end

%% initialize camlight
view(90,0),
% create camlight
caml = camlight('left');

%% go to self selected angle
if isnumeric(view_angle)
  %% start at the right
  view(view_angle),
  % create camlight
  camlight(caml, 'headlight');
  save_name = [name '.png'];
  if save_figure == 1
    eval(['print -dpng -r' num2str(resolution) ' ' save_name]);
  end
end
%% or go through different view modes
if strcmp(view_angle, 'right') || strcmp(view_angle, 'all')
  %% start at the right
  view(90,0),
  % create camlight
  camlight(caml, 'left');
  save_name = [name '_right.png'];
  if save_figure == 1
    eval(['print -dpng -r' num2str(resolution) ' ' save_name]);
  end
end
if strcmp(view_angle, 'left') || strcmp(view_angle, 'all')
  %% move to the left
  view(-90,0),
  % take camlight along
  camlight(caml, 'left');
  save_name = [name '_left.png'];
  if save_figure == 1
    eval(['print -dpng -r' num2str(resolution) ' ' save_name]);
  end
end
if strcmp(view_angle, 'occipital') || strcmp(view_angle, 'all')
  %% move to the back
  view(0,0),
  % take camlight along (now headlight)
  camlight(caml, 'headlight');
  save_name = [name '_occipital.png'];
  if save_figure == 1
    eval(['print -dpng -r' num2str(resolution) ' ' save_name]);
  end
end
if strcmp(view_angle, 'frontal') || strcmp(view_angle, 'all')
  %% nove to the front
  view(180,0),
  % take camlight along (now headlight)
  camlight(caml, 'headlight');
  save_name = [name '_frontal.png'];
  eval(['print -dpng -r' num2str(resolution) ' ' save_name]);
end
if strcmp(view_angle, 'dorsal') || strcmp(view_angle, 'all')
  %% move up
  view(90,90),
  % take camlight along
  camlight(caml, 'right');
  save_name = [name  '_dorsal.png'];
  if save_figure == 1
    eval(['print -dpng -r' num2str(resolution) ' ' save_name]);
  end
end
if strcmp(view_angle, 'ventral') || strcmp(view_angle, 'all')
  %% move down
  view(-90,-90),
  % take camlight along
  camlight(caml, 'left');
  save_name = [name  '_ventral.png'];
  if save_figure == 1
    eval(['print -dpng -r' num2str(resolution) ' ' save_name]);
  end
end