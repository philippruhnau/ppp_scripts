function [mycolor, steps] = define_color_map(mapnr, steps)

% defines personalized color map
%
% input:
% mapnr - 1 (red to gray to blue), 2 (black to white), 3 (white to black), 
%         4 (black to white to black), 5 (blue-grey-(inverted)blue),
%         6 (red-black-blue)
%         [default 1]
% steps - numeric, color map steps [default 45]
%
%

% (c) 2011 - P.Ruhnau - email: mail@philipp-ruhnau.de
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

if nargin < 1, mapnr =1; steps = 45; end



if mapnr == 1 % red to grey to blue (MEG or ERPs)
    if steps < 17, error('To use the red-grey-blue map at least 17 steps are necessary.'), end
       
    % correct for uneven step nr (could be more elegant, but this was fastest way) 
    if ~rem(steps,2)
        corr_color = 1; %needed to correct later
        steps = steps - 1;
    end
    
    steps_fila = round(steps/8);
    colstart = [0 0 1]; % blue
    colmiddle = [0.95 0.95 0.95]; %gray
    colend = [1 0 0]; % red
    
    mycolor = zeros(steps, 3);
    mycolor(steps_fila:ceil(steps/2), 1) = linspace(colstart(1), colmiddle(1), (ceil(steps/2)-steps_fila+1))'; %red
    mycolor(ceil(steps/2):(steps-steps_fila), 1) = linspace(colmiddle(1), colend(1), (ceil(steps/2)-steps_fila))'; %red
    mycolor((steps-steps_fila):end,1) = linspace(colend(1), colend(1)/2, (steps_fila+1))'; %red
    mycolor(steps_fila:ceil(steps/2), 2) = linspace(colstart(2), colmiddle(2), (ceil(steps/2)-steps_fila+1))'; %gray
    mycolor(ceil(steps/2):(steps-steps_fila), 2) = linspace(colmiddle(2), colend(2), (ceil(steps/2)-steps_fila))'; %gray
    mycolor(1:(steps_fila+1),3) = linspace(colstart(3)/2, colstart(3), (steps_fila+1))'; %blue
    mycolor((steps_fila+1):ceil(steps/2), 3) = linspace(colstart(3), colmiddle(3), (ceil(steps/2)-steps_fila))'; %blue
    mycolor(ceil(steps/2):(steps-steps_fila), 3) = linspace(colmiddle(3), colend(3), (ceil(steps/2)-steps_fila))'; %blue
    
    if exist('corr_color', 'var') % add one more gray point in the middle
       mycolor = [mycolor(1:ceil(steps/2),:); mycolor(ceil(steps/2):end,:)]; 
    end
    
elseif mapnr == 2 % black to white
  
    colstart = 1; % white
    colend = 0; % black
    
    mycolor = zeros(steps, 3);
    mycolor = repmat(linspace(colstart, colend, steps)',1,3);
elseif mapnr == 3 % white to black
    colstart = 0; % white
    colend = 1; % black
    
    mycolor = zeros(steps, 3);
    mycolor = repmat(linspace(colstart, colend, steps)',1,3);
     
elseif mapnr == 4 % black to white to black
    colstart = 0; % start and end black
    colend = 1-1/steps; % middle end grey
    
    mycolor = ones(steps, 3);
    halfcolor = repmat(linspace(colstart, colend, floor((steps-1)/2))',1,3); % secure at least one white field in the middle
    mycolor(1:size(halfcolor,1),:) = halfcolor;
    mycolor(steps-size(halfcolor,1)+1:steps,:) = flipud(halfcolor);
elseif mapnr == 5 % blue-gray-blue but colors inverted (dark to light) good for source plots
    if steps < 17, error('To use the red-grey-blue map at least 17 steps are necessary.'), end
       
    % correct for uneven step nr (could be more elegant, but this was fastest way) 
    if ~rem(steps,2)
        corr_color = 1; %needed to correct later
        steps = steps - 1;
    end
    
    steps_fila = round(steps/8);
    colstart = [0 0 1]; % blue
    colmiddle = [0.95 0.95 0.95]; %gray
    colend = [1 0 0]; % red
    
    % build map
    mycolor = zeros(steps, 3);
    mycolor(steps_fila:ceil(steps/2), 1) = linspace(colstart(1), colmiddle(1), (ceil(steps/2)-steps_fila+1))'; %red
    mycolor(ceil(steps/2):(steps-steps_fila), 1) = linspace(colmiddle(1), colend(1), (ceil(steps/2)-steps_fila))'; %red
    mycolor((steps-steps_fila):end,1) = linspace(colend(1), colend(1)/2, (steps_fila+1))'; %red
    mycolor(steps_fila:ceil(steps/2), 2) = linspace(colstart(2), colmiddle(2), (ceil(steps/2)-steps_fila+1))'; %gray
    mycolor(ceil(steps/2):(steps-steps_fila), 2) = linspace(colmiddle(2), colend(2), (ceil(steps/2)-steps_fila))'; %gray
    mycolor(1:(steps_fila+1),3) = linspace(colstart(3)/2, colstart(3), (steps_fila+1))'; %blue
    mycolor((steps_fila+1):ceil(steps/2), 3) = linspace(colstart(3), colmiddle(3), (ceil(steps/2)-steps_fila))'; %blue
    mycolor(ceil(steps/2):(steps-steps_fila), 3) = linspace(colmiddle(3), colend(3), (ceil(steps/2)-steps_fila))'; %blue
    
    % invert the first 1:steps/2 and then the steps/2:end map steps
    mycolor(1:floor(steps/2),:) =  flipud(mycolor(1:steps/2,:));
    mycolor(ceil(steps/2)+1:end,:) =  flipud(mycolor(ceil(steps/2)+1:end,:));
    
    if exist('corr_color', 'var')
       mycolor = [mycolor(1:ceil(steps/2),:); mycolor(ceil(steps/2):end,:)]; 
    end
elseif mapnr == 6 
  warning('This map has 101 predefined steps:FIXME')
  mycolor=[1 1 0; 1 0.96 0; 1 0.92 0; 1 0.88 0; 1 0.84 0; 1 0.80 0; 1 0.76 0; 1 0.72 0; 1 0.68 0; 1 0.64 0; 1 0.60 0; 1 0.56 0; 1 0.52 0; 1 0.48 0; 1 0.44 0; 1 0.40 0;  ...
             1 0.36 0; 1 0.32 0; 1 0.28 0; 1 0.24 0; 1 0.20 0; 1 0.16 0; 1 0.12 0; 1 0.08 0; 1 0.04 0;
             1 0 0; 0.96 0 0; 0.92 0 0; 0.88 0 0; 0.84 0 0; 0.80 0 0; 0.76 0 0; 0.72 0 0; 0.68 0 0; 0.64 0 0; 0.60 0 0; 0.56 0 0; 0.52 0 0; 0.48 0 0; 0.44 0 0; 0.40 0 0;  ...
             0.36 0 0; 0.32 0 0; 0.28 0 0; 0.24 0 0; 0.20 0 0; 0.16 0 0; 0.12 0 0; 0.08 0 0; 0.04 0 0; 0 0 0;                                   ...
             0 0 0.04;  0 0 0.08; 0 0 0.12; 0 0 0.16; 0 0 0.20; 0 0 0.24; 0 0 0.28; 0 0 0.32; 0 0 0.36; 0 0 0.40; 0 0 0.44; 0 0 0.48; 0 0 0.52; ...
             0 0 0.56; 0 0 0.60; 0 0 0.64; 0 0 0.68; 0 0 0.72; 0 0 0.76; 0 0 0.80; 0 0 0.84; 0 0 0.88; 0 0 0.92; 0 0 0.96; 0 0 1; ...
             0 0.04 1;  0 0.08 1; 0 0.12 1; 0 0.16 1; 0 0.20 1; 0 0.24 1; 0 0.28 1; 0 0.32 1; 0 0.36 1; 0 0.40 1; 0 0.44 1; 0 0.48 1; 0 0.52 1; ...
             0 0.56 1; 0 0.60 1; 0 0.64 1; 0 0.68 1; 0 0.72 1; 0 0.76 1; 0 0.80 1; 0 0.84 1; 0 0.88 1; 0 0.92 1; 0 0.96 1; 0 1 1];
else
    error('Wrong map number')
end