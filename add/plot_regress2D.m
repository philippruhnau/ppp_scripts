function [stats] = plot_regress2D(x,y,cfg)

% [stats] = plot_regress2D(x,y,cfg)
% plots 2D scatterplot and regressionline and R^2
% 
% mandatory input:
% x - vector or matrix containing independent variable(s) 
% y - vector or matrix containing dependent variable(s), same size as x
% columns in x and y correspond to different conditions (of the same
% variable)
%
% optional input [defaults]:
% cfg - struct containing several options for plotting
% cfg.reverse - reverses y axis if set 1 [0]
% cfg.markerstyle - cell array defining markerstyle of columns in x/y 
%                   [{'k*'} for all]
% cfg.linestyle - same as markerstyle for regression lines [{'k'} for all]
% cfg.fontcolor - same as markerstyle for text [{'k'} for all]
% cfg.lims - limits of plot and regression line [max/min of x and y]
% cfg.regind - for multiple columns in x/y, 'all' plots one regression 
%              line/R^2 for all data, 'ind' plots one line/R^2 for each
%              column ['all']
% cfg.rpos - string; defines the position of R^2 ('upleft' or 'downright')
%            ['downright']
%

%123412341234123412341234123412341234123412341234123
% P.Ruhnau, Email: ruhnau@uni-leipzig.de, 2012-06-25

% definitions
if size(y,2) ~= size(x,2), error('Number of colums in x and y must be the same'); end
if nargin < 3, cfg = struct; end 
if ~isfield(cfg, 'reverse'),    cfg.reverse = 0; end
if ~isfield(cfg, 'markerstyle'),  cfg.markerstyle(1:size(x,2)) = {'k*'}; end
if ~isfield(cfg, 'linestyle'),  cfg.linestyle(1:size(x,2)) = {'k'}; end
if ~isfield(cfg, 'fontcolor'),  cfg.fontcolor(1:size(x,2)) = {'k'}; end
if ~isfield(cfg, 'lims'), lims = [min(x(:)) max(x(:)) min(y(:)) max(y(:))]; else lims = cfg.lims; end
if ~isfield(cfg, 'regind'), cfg.regind = 'all'; end
if ~isfield(cfg, 'rpos') || strcmp(cfg.rpos, 'downright') % define position of R (default lower right corner)
    rpos = [2 3];
    rsign = {'-' '+'};
    rquot = '5';
elseif strcmp(cfg.rpos, 'upleft')
    rpos = [1 4];
    rsign = {'+' '-'};
    rquot = '9';
end

% figure defaults
figure;
set(gca,...
    'Box'          , 'off'     , ...
    'XColor'       , [0 0 0], ...
    'YColor'       , [0 0 0], ...
    'Layer'        , 'top');
set(gcf,...
    'Color'            , [1 1 1],...
    'PaperPositionMode', 'auto');


if cfg.reverse == 1, set(gca, 'YDir'         , 'reverse'); end

hold on


if size(y,2) == 1 % if x and y are vectors
    plot(x, y, cfg.markerstyle{1})
    stats = regstats(y, x, 'linear');
    b = stats.beta;
    r = stats.rsquare;
    % regression line
    xfit = linspace(lims(1),lims(2),20);
    YFIT = b(1) + b(2)*xfit;
    plot(xfit, YFIT, 'k')
    axis(lims)
    if stats.tstat.pval(2)<=0.01, sig = '**'; elseif stats.tstat.pval(2)<=0.05, sig = '*'; elseif stats.tstat.pval(2)<=0.1, sig = '+'; else sig = '{n.s.}';end
    % for some reason eval can or does produce single values which text
    % does not want to interprete...thus doubled here (and below)
    x_val = double(eval(['lims(rpos(1))' rsign{1} 'abs((lims(2)-lims(1))/' rquot ')']));
    y_val = double(eval(['lims(rpos(2))' rsign{2} 'abs((lims(3)-lims(4))/9)']));
    text(x_val, y_val, ['R^2 = ' num2str(round(1000*r)/1000, '%0.3f') '^{' sig '}'], 'fontsize', 12)

else
    for i = 1:size(y,2)
        plot(x(:,i), y(:,i),cfg.markerstyle{i})
        if strcmp(cfg.regind, 'ind') % individual regression lines, columnwise x on y
            stats(i) = regstats(y(:,i), x(:,i), 'linear');
            b = stats(i).beta;
            r = stats(i).rsquare;
            % regression line
            xfit = linspace(lims(1),lims(2),20);
            YFIT = b(1) + b(2)*xfit;
            plot(xfit, YFIT, cfg.linestyle{i})
            axis(lims)
            if stats(i).tstat.pval(2)<=0.01, sig = '**'; elseif stats(i).tstat.pval(2)<=0.05, sig = '*'; elseif stats(i).tstat.pval(2)<=0.1, sig = '+'; else sig = '{n.s.}';end
            x_val = double(eval(['lims(rpos(1))' rsign{1} 'abs((lims(2)-lims(1))/6)']));
            y_val = double(eval(['lims(rpos(2))' rsign{2} 'abs((lims(3)-lims(4))/6)' rsign{2} '(i-1)*abs((lims(3)-lims(4))/9)']));
            text(x_val, y_val , ['R^2 = ' num2str(round(1000*r)/1000, '%0.3f') '^{' sig '}'], 'fontsize', 12, 'color', cfg.fontcolor{i})
        end
    end
    
    if strcmp(cfg.regind, 'all') % one regression line for all values in x on all values in y
        stats = regstats(y(:), x(:), 'linear');
        b = stats.beta;
        r = stats.rsquare;
        % regression line
        xfit = linspace(lims(1),lims(2),20);
        YFIT = b(1) + b(2)*xfit;
        plot(xfit, YFIT, cfg.linestyle{1})
        axis(lims)
        if stats.tstat.pval(2)<=0.01, sig = '**'; elseif stats.tstat.pval(2)<=0.05, sig = '*'; elseif stats.tstat.pval(2)<=0.1, sig = '+'; else sig = '{n.s.}';end
        x_val = double(eval(['lims(rpos(1))' rsign{1} 'abs((lims(2)-lims(1))/6)']));
        y_val = double(eval(['lims(rpos(2))' rsign{2} 'abs((lims(3)-lims(4))/9)']));
        text(x_val, y_val , ['R^2 = ' num2str(round(1000*r)/1000, '%0.3f') '^{' sig '}'], 'fontsize', 12)

    end

end

