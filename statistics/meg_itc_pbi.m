function [phi, itcA, itcB, itc_all] = meg_itc_pbi(dataA, dataB, itc_all)

% function [phi, itcA, itcB, itc_all] = cimecex_itc_pbi(dataA, dataB, itc_all)
%
% computes the inter-trial coherence (itc) and phase bifurcation index (pbi)
% of two conditions
%
% mandatory input:
%
% dataA   - first condition data, either fiedtrip structure containing
%           fourierspctrm field (output of ft_frequanalysis), or matrix
%           containing the itc for condition 1
% dataB   - second condition data, must match data1
%
% optional input:
%
% itc_all - itc of combinded dataset, needed only if dataA and dataB are
%           itc matricies, otherwise computed from the input data [default:
%           empty]
%
% output:
%
% phi     - phase bifurcation index
% itcA    - itc condition A
% itcB    - itc condition B
% itc_all - itc of combined data sets
%
% Ref:
% Busch, N. A., Dubois, J., & VanRullen, R. (2009). The phase of ongoing
%   EEG oscillations predicts visual perception. J Neurosci, 29(24),
%   7869???7876.

%--------------------------------------------------------------------
% copyright (c), 2013, P. Ruhnau, mail@philipp-ruhnau.de, 2013-04-05
%
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

if isfield(dataA, 'fourierspctrm')
    disp('Input data contain fieldtrip structures including fourier spectra.')
    disp('Computing inter-trial coherence')
    disp(' ')
    % ITC
    % data 1
    dat = dataA.fourierspctrm;
    % normalize data in each trial
    dat = dat./abs(dat);
    % ITC is the length of the average complex numbers
    itcA = abs(mean(dat));
    
    % data 2
    dat = dataB.fourierspctrm;
    % normalize data in each trial
    dat = dat./abs(dat);
    % ITC is the length of the average complex numbers
    itcB = abs(mean(dat));
    
    % combined
    dat = [dataA.fourierspctrm; dataB.fourierspctrm];
    % normalize data in each trial
    dat = dat./abs(dat);
    % ITC is the length of the average complex numbers
    itc_all = abs(mean(dat, 1));
elseif isnumeric(dataA)
    % do nothing, only report
    disp('Input is inter-trial coherence')
    
    itcA = dataA;
    itcB = dataB;
else
    error('Wrong data input, See documentation')
end


% phase bifurcation index
phi = (itcA - itc_all) .* (itcB - itc_all);
phi = squeeze(phi);
