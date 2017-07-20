function mesh = read_mesh_data(filename)

% function to read in mesh imported from gmsh
% 
% import as post-processing gmsh-pos
% settings on visible and mesh-based
%
% input:
% filename - name of the mesh export file
% 
% output:
% mesh - structure with fields:
%     .pos - 3d coordinates of nodes
%     .tri3d - triangulation 
%     .tri4d - fourth triangulation row, no idea what this is for
%     .trilabel - numeric grouping vector, see gmsh/simnibs for what they
%                mean
%     .powspctrm - simulated current strength that you exported
%

% copyright (c), 2017, P. Ruhnau, email: mail(at)philipp-ruhnau.de, 2017-07-20
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

% vers 20170720 - initialized function


fid = fopen(filename);

finished = 0;
counter = 0;
actLine = cellstr(fgetl(fid));
while finished ~= 1
  
  
  counter = counter +1;
  
  if strcmp(actLine, '$Nodes')
    % do all the stuff essential for nodes (coordinates)
    % move one line down (# of nodes
    nnodes = cellstr(fgetl(fid));
    nnodes = str2double(nnodes{1});
    % read everything between the tags
    t = textscan(fid, '%f%f%f%f', nnodes);
    pos = [t{2} t{3} t{4}];
    % move along to get to next line
    actLine = cellstr(fgetl(fid));
    
  elseif strcmp(actLine, '$Elements')
    % get element information
    % move one line down (# of elements
    nelements = cellstr(fgetl(fid));
    nelements = str2double(nelements{1});
    % read everything between the tags
    t = textscan(fid, '%f%f%f%f%f%f%f%f%f', nelements);
    tri3d = [t{6} t{7} t{8}];
    tri4d = [t{9}]; % not sure if this is needed anywhere
    % tissue labels (1 = wm, 2 = gm etc, see gmesh)
    trilabel = t{4};
       % move along to get to next line
    actLine = cellstr(fgetl(fid));
    
    
  elseif strcmp(actLine, '$ElementData')
    for i = 1:8
      dummy = cellstr(fgetl(fid));
    end
    nelements = cellstr(fgetl(fid));
    nelements = str2double(nelements{1});
    
    % read datta (index and value)
    t = textscan(fid, '%f%f', nelements);
    powspctrm = t{2};
      
    % move along to get to next line
    actLine = cellstr(fgetl(fid));
  elseif strcmp(actLine, '$EndElementData')
    finished = 1;
  else
    actLine = cellstr(fgetl(fid));
  end
  
end

mesh = struct();
mesh.pos = pos;
mesh.tri3d = tri3d;
mesh.tri4d = tri4d;
mesh.trilabel = trilabel;
mesh.powspctrm = powspctrm;


fclose(fid);