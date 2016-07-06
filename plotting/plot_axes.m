function plot_axes(cfg)

% plot_axes(cfg)
%
% Obligatory inputs:
%	cfg.lims        - limits of the axis [xmin xmax ymin ymax]
%
% Optional inputs (defaults):
% cfg.color       = 'k';
% cfg.line_width  = 2;
% cfg.origin      = [0 0]; % center/origin of the cross hair
% cfg.tick_steps  = [NaN NaN]; % steps of the ticks [x y], e.g. [100 2] or 
%                   [NaN NaN] for no ticks
% cfg.tick_length = line length of the ticks [x y], e.g. [0.2 6], 
%                   default = 1% of the xyaxis respcetively.
% cfg.xtick_type  = 'both'; % 'both', 'upper', 'lower'
% cfg.xtick_text  = cell of strings, replace numeric values
% cfg.ytick_type  = 'both'; % 'both', 'left', 'right'
% cfg.font_size   = 15;
% cfg.font_weight = 'normal'; % 'light', 'normal', 'demi', 'bold'
% cfg.xtext_pos   = 'below'; % 'below', 'above'
% cfg.ytext_pos   = 'left'; % 'left', 'right'
% cfg.xlabel      = ''; % e.g. 'ms'
% cfg.ylabel      = ''; % e.g. 'fT'
% cfg.xpoints     = []; vector with exact points on xaxis you want ticks at
% cfg.xpoints     = []; vector with exact points on yaxis you want ticks at
% cfg.ylabel_rot  = [0]; rotation angle of ylabel text
% cfg.text_dis    = [0 0]; % distance for the text away from the tick [x y]
%                   , e.g. [0.1 6]
% cfg.xexclude    = [cfg.origin(1)]; % exclude these x-numbers from
%                   plotting as text
% cfg.yexclude    = [cfg.origin(2)]; % exclude these y-numbers from plotting as text
%
% Note: Many of the parameters use the unit of the x-axis or the y-axis.
% Furthermore, when using reversed axes you need to reverse them before
% running the script.
% -------------------------------------------------------------------------
% B.Herrmann, Email: bherrmann@cbs.mpg.de, 2010-10-12

% ideas by PPP
%
% line 22: added optional input description
% line 71: added default for cfg.ylabel_rot
% line 94/95: added 'Color' to plot function so rgb definitions are possible
% line 123: added 'Color' to plot function
% line 139: added 'Color' to plot function
% line 170-74: added 'if', if cfg.xtick_text exists it replaces the tick numbers
% line 241/46: renamed tpos to htpos
% line 244/49: 'if'- added to change vertical alignment in case ylabel is rotated (90 degrees)
% line 252: changed fixed 'top' for vertical alignment to vtpos and renamed
%           tpos to htpos

% Load some defaults if appropriate
% ---------------------------------
if nargin < 1, fprintf('Error: cfg struct needs to be defined!\n\n'); help plot_axes; return; end;
if ~isfield(cfg, 'lims'),        fprintf('Error: cfg.lims needs to be defined!\n'); return; end
if ~isfield(cfg, 'origin'),      cfg.origin      = [0 0]; end
if ~isfield(cfg, 'color'),       cfg.color       = 'k'; end
if ~isfield(cfg, 'line_width'),  cfg.line_width  = 2; end
if ~isfield(cfg, 'tick_steps'),  cfg.tick_steps  = [NaN NaN]; end
if ~isfield(cfg, 'tick_length')
    cfg.tick_length(1) = diff(cfg.lims(3:4)) / 100;
    cfg.tick_length(2) = diff(cfg.lims(1:2)) / 100;
end
if ~isfield(cfg, 'xtick_type'),  cfg.xtick_type  = 'both'; end
if ~isfield(cfg, 'ytick_type'),  cfg.ytick_type  = 'both'; end
if ~isfield(cfg, 'font_size'),   cfg.font_size   = 15; end
if ~isfield(cfg, 'font_weight'), cfg.font_weight = 'normal'; end
if ~isfield(cfg, 'xtext_pos'),   cfg.xtext_pos   = 'below'; end
if ~isfield(cfg, 'ytext_pos'),   cfg.ytext_pos   = 'left'; end
if ~isfield(cfg, 'xlabel'),      cfg.xlabel      = ''; end
if ~isfield(cfg, 'ylabel'),      cfg.ylabel      = ''; end
if ~isfield(cfg, 'xexclude'),    cfg.xexclude    = cfg.origin(1); end
if ~isfield(cfg, 'yexclude'),    cfg.yexclude    = cfg.origin(2); end
if ~isfield(cfg, 'text_dis'),    cfg.text_dis    = [0 0]; end
if ~isfield(cfg, 'ylabel_rot'),  cfg.ylabel_rot  = 0; end
hold on;


% determine decimal places for x-axis
numXDec = 0;
sx   = num2str(cfg.tick_steps(1),16);
pnt  = regexp(sx, '\.');
if ~isempty(pnt), numXDec = length(sx) - pnt; end
pnt = regexp(sx, 'e');
if ~isempty(pnt), numXDec = str2num(sx(pnt+2:end)); end


% determine decimal places for y-axis
numYDec = 0;
sx   = num2str(cfg.tick_steps(2),16);
pnt  = regexp(sx, '\.');
if ~isempty(pnt), numYDec = length(sx) - pnt; end
pnt = regexp(sx, 'e');
if ~isempty(pnt), numYDec = str2num(sx(pnt+2:end)); end


% plot x-axis and y-axis
plot([cfg.lims(1) cfg.lims(2)], [cfg.origin(2) cfg.origin(2)], 'Color', cfg.color, 'LineWidth', cfg.line_width);
plot([cfg.origin(1) cfg.origin(1)], [cfg.lims(3) cfg.lims(4)], 'Color', cfg.color, 'LineWidth', cfg.line_width);


% get points on x-axis and y-axis
if ~isfield(cfg, 'xpoints') || isempty(cfg.xpoints)
  xpoints = cfg.lims(1):cfg.tick_steps(1):cfg.lims(2);
else
  xpoints = cfg.xpoints;
end
if ~isfield(cfg, 'ypoints') || isempty(cfg.ypoints)
  ypoints = cfg.lims(3):cfg.tick_steps(2):cfg.lims(4);
else
  ypoints = cfg.ypoints;
end

% get max points for axis label
xlabpos = max(xpoints);
if strcmp(get(gca, 'XDir'), 'reverse'), xlabpos = min(xpoints); end
ylabpos = max(ypoints);
if strcmp(get(gca, 'YDir'), 'reverse'),	ylabpos = min(ypoints); end


% plot x-ticks
xpo = repmat(xpoints,2,1);
ypo_un = repmat([cfg.origin(2); cfg.origin(2)+cfg.tick_length(1)],1,size(xpo,2)); % upper normal
ypo_ln = repmat([cfg.origin(2)-cfg.tick_length(1); cfg.origin(2)],1,size(xpo,2)); % lower normal
if strcmp(cfg.xtick_type, 'both')
    ypo = repmat([cfg.origin(2)-cfg.tick_length(1); cfg.origin(2)+cfg.tick_length(1)],1,size(xpo,2));
elseif strcmp(cfg.xtick_type, 'upper')
    ypo = ypo_un;
    if strcmp(get(gca, 'YDir'), 'reverse'), ypo = ypo_ln; end
elseif strcmp(cfg.xtick_type, 'lower')
    ypo = ypo_ln;
    if strcmp(get(gca, 'YDir'), 'reverse'), ypo = ypo_un; end
end
plot(xpo, ypo, 'Color', cfg.color, 'LineWidth', cfg.line_width);


% plot y-ticks
ypo = repmat(ypoints,2,1);
xpo_ln = repmat([cfg.origin(1)-cfg.tick_length(2); cfg.origin(1)],1,size(ypo,2)); % left normal
xpo_rn = repmat([cfg.origin(1); cfg.origin(1)+cfg.tick_length(2)],1,size(ypo,2)); % right normal
if strcmp(cfg.ytick_type, 'both')
    xpo = repmat([cfg.origin(1)-cfg.tick_length(2); cfg.origin(1)+cfg.tick_length(2)],1,size(ypo,2));
elseif strcmp(cfg.ytick_type, 'left')
    xpo = xpo_ln;
    if strcmp(get(gca, 'XDir'), 'reverse'), xpo = xpo_rn; end
elseif strcmp(cfg.ytick_type, 'right')
    xpo = xpo_rn;
    if strcmp(get(gca, 'XDir'), 'reverse'), xpo = xpo_ln; end
end
plot(xpo, ypo, 'Color', cfg.color, 'LineWidth', cfg.line_width);

% reduce points in x and y
xtmp = ismember(xpoints, cfg.xexclude);
xpoints(xtmp) = [];
ytmp = ismember(ypoints, cfg.yexclude);
ypoints(ytmp) = [];


% set distance of text to the x-axis
if strcmp(cfg.xtick_type, 'both') && strcmp(cfg.xtext_pos, 'above'), xtickTextPnt = cfg.tick_length(1); end
if strcmp(cfg.xtick_type, 'upper') && strcmp(cfg.xtext_pos, 'above'), xtickTextPnt = cfg.tick_length(1); end
if strcmp(cfg.xtick_type, 'lower') && strcmp(cfg.xtext_pos, 'above'), xtickTextPnt = 0; end
if strcmp(cfg.xtick_type, 'both') && strcmp(cfg.xtext_pos, 'below'), xtickTextPnt = -cfg.tick_length(1); end
if strcmp(cfg.xtick_type, 'upper') && strcmp(cfg.xtext_pos, 'below'), xtickTextPnt = 0; end
if strcmp(cfg.xtick_type, 'lower') && strcmp(cfg.xtext_pos, 'below'), xtickTextPnt = -cfg.tick_length(1); end
if strcmp(get(gca, 'YDir'), 'reverse'), xtickTextPnt = xtickTextPnt * (-1); end

% plot x-axis text
tposy_bn = cfg.origin(2) + xtickTextPnt - cfg.text_dis(1); % below normal
tposy_an = cfg.origin(2) + xtickTextPnt + cfg.text_dis(1); % above normal
if strcmp(cfg.xtext_pos, 'below')
    tpos = 'top';
    tposy = tposy_bn;
    if strcmp(get(gca, 'YDir'), 'reverse'), tposy = tposy_an; end
elseif strcmp(cfg.xtext_pos, 'above')
    tpos = 'bottom';
    tposy = tposy_an;
    if strcmp(get(gca, 'YDir'), 'reverse'), tposy = tposy_bn; end
end

if ~isfield(cfg, 'xtick_text')
    xtext = eval(['strread(sprintf(''%.' num2str(numXDec) 'f\n'', xpoints), ''%s'')']);
else
    xtext = cfg.xtick_text;
end

text(xpoints, repmat(tposy,1,length(xpoints)), xtext, 'HorizontalAlignment', 'center', 'VerticalAlignment', tpos, 'Color', cfg.color, 'FontSize', cfg.font_size, 'FontWeight', cfg.font_weight);


% set distance of text to the y-axis
if strcmp(cfg.ytick_type, 'both') && strcmp(cfg.ytext_pos, 'left'), ytickTextPnt = -cfg.tick_length(2); end
if strcmp(cfg.ytick_type, 'left') && strcmp(cfg.ytext_pos, 'left'), ytickTextPnt = -cfg.tick_length(2); end
if strcmp(cfg.ytick_type, 'right') && strcmp(cfg.ytext_pos, 'left'), ytickTextPnt = 0; end
if strcmp(cfg.ytick_type, 'both') && strcmp(cfg.ytext_pos, 'right'), ytickTextPnt = cfg.tick_length(2); end
if strcmp(cfg.ytick_type, 'left') && strcmp(cfg.ytext_pos, 'right'), ytickTextPnt = 0; end
if strcmp(cfg.ytick_type, 'right') && strcmp(cfg.ytext_pos, 'right'), ytickTextPnt = cfg.tick_length(2); end
if strcmp(get(gca, 'XDir'), 'reverse'), ytickTextPnt = ytickTextPnt * (-1); end

% plot y-axis text
tposx_ln = cfg.origin(1) + ytickTextPnt - cfg.text_dis(2); % left normal
tposx_rn = cfg.origin(1) + ytickTextPnt + cfg.text_dis(2); % right normal
if strcmp(cfg.ytext_pos, 'left')
    tpos = 'right';
    tposx = tposx_ln;
    if strcmp(get(gca, 'XDir'), 'reverse'), tposx = tposx_rn; end
elseif strcmp(cfg.ytext_pos, 'right')
    tpos = 'left';
    tposx = tposx_rn;
    if strcmp(get(gca, 'XDir'), 'reverse'), tposx = tposx_ln; end
end

if ~isfield(cfg, 'ytick_text')
    ytext = eval(['strread(sprintf(''%.' num2str(numYDec) 'f\n'', ypoints), ''%s'')']);
else
    ytext = cfg.ytick_text;
end


text(repmat(tposx,1,length(ypoints)), ypoints, ytext, 'HorizontalAlignment', tpos, 'VerticalAlignment', 'middle', 'Color', cfg.color, 'FontSize', cfg.font_size, 'FontWeight', cfg.font_weight);


% set distance of xlabel to the x-axis
if strcmp(cfg.xtick_type, 'both') && strcmp(cfg.xtext_pos, 'above'), xtickLabPnt = -cfg.tick_length(1); end
if strcmp(cfg.xtick_type, 'upper') && strcmp(cfg.xtext_pos, 'above'), xtickLabPnt = 0; end
if strcmp(cfg.xtick_type, 'lower') && strcmp(cfg.xtext_pos, 'above'), xtickLabPnt = -cfg.tick_length(1); end
if strcmp(cfg.xtick_type, 'both') && strcmp(cfg.xtext_pos, 'below'), xtickLabPnt = cfg.tick_length(1); end
if strcmp(cfg.xtick_type, 'upper') && strcmp(cfg.xtext_pos, 'below'), xtickLabPnt = cfg.tick_length(1); end
if strcmp(cfg.xtick_type, 'lower') && strcmp(cfg.xtext_pos, 'below'), xtickLabPnt = 0; end
if strcmp(get(gca, 'YDir'), 'reverse'), xtickLabPnt = xtickLabPnt * (-1); end

% plot x-label
tposy_bn = cfg.origin(2) + xtickLabPnt + cfg.text_dis(1); % below normal
tposy_an = cfg.origin(2) + xtickLabPnt - cfg.text_dis(1); % above normal
if strcmp(cfg.xtext_pos, 'below')
    tpos = 'bottom';
    tposy = tposy_bn;
    if strcmp(get(gca, 'YDir'), 'reverse'), tposy = tposy_an; end
elseif strcmp(cfg.xtext_pos, 'above')
    tpos = 'top';
    tposy = tposy_an;
    if strcmp(get(gca, 'YDir'), 'reverse'), tposy = tposy_bn; end
end
text(xlabpos, tposy, cfg.xlabel, 'HorizontalAlignment', 'right', 'VerticalAlignment', tpos, 'Color', cfg.color, 'FontSize', cfg.font_size, 'FontWeight', cfg.font_weight);


% set distance of ylabel to the y-axis
if strcmp(cfg.ytick_type, 'both') && strcmp(cfg.ytext_pos, 'left'), ytickLabPnt = cfg.tick_length(2); end
if strcmp(cfg.ytick_type, 'left') && strcmp(cfg.ytext_pos, 'left'), ytickLabPnt = 0; end
if strcmp(cfg.ytick_type, 'right') && strcmp(cfg.ytext_pos, 'left'), ytickLabPnt = cfg.tick_length(2); end
if strcmp(cfg.ytick_type, 'both') && strcmp(cfg.ytext_pos, 'right'), ytickLabPnt = -cfg.tick_length(2); end
if strcmp(cfg.ytick_type, 'left') && strcmp(cfg.ytext_pos, 'right'), ytickLabPnt = -cfg.tick_length(2); end
if strcmp(cfg.ytick_type, 'right') && strcmp(cfg.ytext_pos, 'right'), ytickLabPnt = 0; end
if strcmp(get(gca, 'XDir'), 'reverse'), ytickLabPnt = ytickLabPnt * (-1); end

% plot y-label
tposx_ln = cfg.origin(1) + ytickLabPnt + cfg.text_dis(2); % left normal
tposx_rn = cfg.origin(1) + ytickLabPnt - cfg.text_dis(2); % right normal
if strcmp(cfg.ytext_pos, 'left')
    htpos = 'left';
    tposx = tposx_ln;
    if strcmp(get(gca, 'XDir'), 'reverse'), tposx = tposx_rn; end
    if cfg.ylabel_rot == 0, vtpos = 'bottom'; else  vtpos = 'top'; htpos = 'right'; end
elseif strcmp(cfg.ytext_pos, 'right')
    htpos = 'right';
    tposx = tposx_rn;
    if strcmp(get(gca, 'XDir'), 'reverse'), tposx = tposx_ln; end
    if cfg.ylabel_rot == 0, vtpos = 'top'; else  vtpos = 'bottom'; end
end

text(tposx, ylabpos, cfg.ylabel, 'HorizontalAlignment', htpos, 'VerticalAlignment', vtpos, 'Color', cfg.color, 'FontSize', cfg.font_size, 'FontWeight', cfg.font_weight, 'rotation', cfg.ylabel_rot);

return;
