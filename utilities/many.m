function [ varargout ] = many( x )
%MANY Assign the same values to many output variables
%   MANY takes in the variable x and assign it to all the output variables.
%   This function works as the equation sign in C++ so that the following
%   expression in C++:
%       x1 = x2 = x3 = x4 = x5 = 8
%   is equivalent to the following expression in Matlab:
%       [ x1, x2, x3, x4, x5 ] = MANY( 8 );
%
%   Examples:
%   [ x1, x2, x3, x4, x5 ] = MANY( 8 );
%   [ x1, x2, x3, x4, x5 ] = MANY( 'Hello' );
%
%   See also: repmat.

% PR17 removed the parallel option and changed capital to lower letters
%   Copyright 2009-2010 Hairui Zhang
%   $Revision: 2.2.0.3 $  $Date: 2010/5/13 16:44:00 $
%   $Email: hairui.zhang@ua.ac.be $

varargout = cell(nargout, 1);

for i=1:nargout
    varargout(i) = {x};
end

end

