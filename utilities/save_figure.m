function save_figure(name, resolution, loose)

% function save_figure(name, resolution, loose)
% saves figures in postscipt or portable network graphic format
% picks format based on file extension (.png/.eps)
%
% Input:
%
% name       - name and place of to be saved file
% resolution - picture resolution
% loose      - if one using loose option for eps printing

% (c) P.Ruhnau, 2013, mail@philipp-ruhnau.de
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

if nargin < 1, help save_figure; return; end
if nargin < 2, resolution = 600; end;
if nargin < 3, loose = 1; end
    
if ~isempty(strfind(name, 'png'))
    print(name, '-dpng', ['-r' num2str(resolution)])
    disp(' '); disp(['Saving file: ' name '!!!']); disp(' ')
elseif ~isempty(strfind(name, 'eps'))
    if loose == 1
      print(name, '-depsc2', ['-r' num2str(resolution)], '-loose')
    else
      print(name, '-depsc2', ['-r' num2str(resolution)])
    end
    disp(' '); disp(['Saving file: ' name '!!!']); disp(' ')
elseif ~isempty(strfind(name, 'jpg'))
    print(name, '-djpeg90', ['-r' num2str(resolution)])
    disp(' '); disp(['Saving file: ' name '!!!']); disp(' ')
else
    disp('WARNING: No format given, nothing is saved!!!!')
end
