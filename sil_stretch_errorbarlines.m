function sil_stretch_errorbarlines( f )
%SIL_STRETCH_ERRORBARLINES Summary of this function goes here
%   Detailed explanation goes here
%   -0.5 < f < ...
% done by the great Stefan Illek!

if nargin==0, f = 1; end
H = findobj('LDataSource','','Parent',gca);

for h = H'
    ch = get(h,'Children');
    XD = get(ch(2),'XData');
    d  = max(diff(XD));
    XD([4:9:end, 7:9:end]) = XD([4:9:end, 7:9:end])-d*f;
    XD([5:9:end, 8:9:end]) = XD([5:9:end, 8:9:end])+d*f;
    set(ch(2),'XData',XD)
end
