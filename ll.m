function ll(path)
% don't laugh at me
% but matlab simply doesn't know ll...

if nargin < 1, path = cd; end

eval(['ls -lh ' path])