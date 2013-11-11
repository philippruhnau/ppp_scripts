
function save_figure(name, resolution)
% function save_figure(name, resolution)
% saves figures in postscipt or portable network graphic format
%
% Input:
%
% name       - name and place of to be saved file
% resolution - picture resolution

if nargin < 1, help save_figure; return; end
if nargin < 2, resolution = 600; end;

if ~isempty(strfind(name, 'png'))
    eval(['print -dpng -r' num2str(resolution) ' ' name]);
    disp(' '); disp(['Saving file: ' name '!!!']); disp(' ')
elseif ~isempty(strfind(name, 'eps'))
    eval(['print -depsc2 -painters -loose -r' num2str(resolution) ' ' name]);
    disp(' '); disp(['Saving file: ' name '!!!']); disp(' ')
else
    disp('WARNING: No format given, nothing is saved!!!!')
end
