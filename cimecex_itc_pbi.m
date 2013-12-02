function [phi, itcA, itcB, itc_all] = cimecex_itc_pbi(dataA, dataB, itc_all)

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
%   7869–7876.

%--------------------------------------------------------------------
% copyright (c), 2013, P. Ruhnau, philipp_ruhnau@yahoo.de, 2013-04-05

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
elseif isnumeric(peter)
    % do nothing, only report
    disp('Input is inter-trial coherence')
else
    error('Wrong data input, See documentation')
end


% phase bifurcation index
phi = (itcA - itc_all) .* (itcB - itc_all);
