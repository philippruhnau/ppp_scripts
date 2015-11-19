function h = plot_polar_hist(cfg, theta, rho)


% function PLOT_POLAR_HIST(cfg, theta, rho)
% plots a polar histogram similar to matlabs rose but with more input
% possibilities
%
%
% mandatory input:
% theta - polar coordinates of the angle theta in radians
% rho   - radius of angles in theta, numeric
%
% optional [defaults]:
% 
% cfg.linestyle - line style of data ['-']
% cfg.linewidth - line width of data [1]
% cfg.linecolor - line color of data ['b']
% 
% the following is optional for plotting of the basic circular diagram:
%
% cfg.circlim       - radius of circle [based on data, rounded to next 10]
% cfg.circtick      - within circle circles (ticks) radius vector, positive 
%                     values [based on circlim]
% cfg.circlinewidth - linewidth of inner circles [1]
% cfg.circcolor     - color of inner circles [0.8 0.8 0.8]
% cfg.circlinestyle - line style of inner circles ['-']
% cfg.outercircle   - by default the outmost circle is plotted in black and
%                     on top, set to 0 if you don't want that [1]
% cfg.tickpos       - angular position of tick numbers in degree
% cfg.circticktext  - set to 0 if no tick numbers wanted [1]
% 
% easiest to use like this:
% [theta rho] = rose(theta)
% cfg =[];
% plot_polar_hist(cfg, theta, rho);
%
% this function is largely based on matlabs(c) polar.m

% copyright (c), 2015, P. Ruhnau, email: mail(at)philipp-ruhnau.de,
% 2015-11-17

%% defaults
if isempty(cfg), cfg = struct; end
if ~isfield(cfg, 'circlim'), cfg.circlim = ceil(max(abs(rho))/10)*10; end
if ~isfield(cfg, 'circlinewidth'), cfg.circlinewidth = 1; end
if ~isfield(cfg, 'circcolor'), cfg.circcolor = [0.8 0.8 0.8]; end
if ~isfield(cfg, 'circlinestyle'), cfg.circlinestyle = '-'; end
if ~isfield(cfg, 'outercircle'), cfg.outercircle = 1; end
if ~isfield(cfg, 'tickpos'), cfg.tickpos = 80; end
if ~isfield(cfg, 'circticktext'), cfg.circticktext = 1; end
if ~isfield(cfg, 'linestyle'), cfg.linestyle = '-'; end
if ~isfield(cfg, 'linewidth'), cfg.linewidth = 1; end
if ~isfield(cfg, 'linecolor'), cfg.linecolor = 'b'; end

% get an integer equally distributed tick pattern with 3, 4 or 5 ticks
if ~isfield(cfg, 'circtick')
  cfg.circtick = [];
  while isempty(cfg.circtick)
    if rem(cfg.circlim/5,1) == 0
      cfg.circtick = 0:cfg.circlim/5:cfg.circlim;
    elseif rem(cfg.circlim, 4) == 0
      cfg.circtick = 0:cfg.circlim/4:cfg.circlim;
    elseif rem(cfg.circlim, 3) == 0
      cfg.circtick = 0:cfg.circlim/3:cfg.circlim;
    else % if not one of the above add one and start anew
      cfg.circlim = cfg.circlim+1;
    end
  end
  % remove 0
  cfg.circtick(1) = [];
end


%% start making the figure

if ~isfield(cfg, 'newfig') || cfg.newfig == 1
  h = figure;
else
  h = gcf;
end
% make it white
h.Color = [1 1 1];
hold on

%% draw circles and lines
% circle
th = 0 : pi / 50 : 2 * pi;
xunit = cos(th);
yunit = sin(th);

% force points on x/y axes to lie on them exactly
inds = 1 : (length(th) - 1) / 4 : length(th);
xunit(inds(2 : 2 : 4)) = zeros(2, 1);
yunit(inds(1 : 2 : 5)) = zeros(3, 1);

% plot background circle with black outline
patch('XData', xunit * cfg.circlim, 'YData', yunit * cfg.circlim, 'FaceColor', h.Color);

% draw inner circles
ctick = cos(cfg.tickpos * pi / 180);
stick = sin(cfg.tickpos * pi / 180);

for i = cfg.circtick
  line(xunit * i, yunit * i, 'LineStyle', cfg.circlinestyle, 'Color', cfg.circcolor, 'LineWidth', cfg.circlinewidth);
  if cfg.circticktext
    text((i + diff(cfg.circtick(1:2)) / 20) * ctick, (i + diff(cfg.circtick(1:2)) / 20) * stick, ...
      ['  ' num2str(i)], 'VerticalAlignment', 'bottom');
  end
end

% plot orthogonal lines
th = (1 : 6) * 2 * pi / 12;
cst = cos(th);
snt = sin(th);
cs = [-cst; cst];
sn = [-snt; snt];
line(cfg.circlim * cs, cfg.circlim * sn, 'LineStyle', cfg.circlinestyle, 'Color', cfg.circcolor, 'LineWidth', 1);

if cfg.outercircle
  % make outer circle black and solid
  line(xunit * cfg.circlim, yunit * cfg.circlim, 'LineStyle', '-', 'Color', 'k', 'LineWidth', 2);
end

if cfg.circticktext
  % annotate spokes in degrees
  rt = 1.1 * cfg.circlim;
  for i = 1 : length(th)
    text(rt * cst(i), rt * snt(i), int2str(i * 30), ...
      'HorizontalAlignment', 'center');
    if i == length(th)
      loc = int2str(0);
    else
      loc = int2str(180 + i * 30);
    end
    text(-rt * cst(i), -rt * snt(i), loc, 'HorizontalAlignment', 'center');
  end
end

% set view to 2-D
view(2)
% set axis to equal (otherwise stretches x)
axis equal
% set axis limits
axis(cfg.circlim * [-1.1, 1.1, -1.1, 1.1])

%% plot data
% transform data to Cartesian coordinates.
xx = rho .* cos(theta);
yy = rho .* sin(theta);

% plot the data
plot(xx, yy, 'LineStyle', cfg.linestyle, 'Color', cfg.linecolor, 'LineWidth', cfg.linewidth);

%% remove outside axis and move further to edge
set(gca, 'Visible', 'off')
set(gca, 'Position', get(gca, 'OuterPosition'))

