function y = sinewin(N)
% SINEWIN Sine window.
%   y = sinewin(N)
%
%   Used in MDCT transform for TDAC
%   Maximum length, maximum overlap sine window
%
%   N: length of window to create
%   y: the window in column

% ------- sinewin.m ----------------------------------------
% Marios Athineos, marios@ee.columbia.edu
% http://www.ee.columbia.edu/~marios/
% Copyright (c) 2002 by Columbia University.
% All rights reserved.
% ----------------------------------------------------------

x = (0:(N-1)).';
y = sin(pi*(x+0.5)/N);
end