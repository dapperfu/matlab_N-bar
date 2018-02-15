function varargout=fourbar(varargin)
% [unknown1,unknown2,all_linkages]=fourbar(link1,angle1,link2,angle2,link3,angle3,link4, angle4)
% Simple method for calling fourbar, sets the #5 linkage length and angle
% to 0.
%
% Example:
% Consider this square with 'unknown' length and angle for the top linkage.
% %         (?)
% %    O - - - - - O
% %    | ?     90* |
% %    |           |
% %(5) |           | (5)
% %    |           |
% %    | 90*   90* |
% %    O - - - - - O
% %         (5)
%
% %Working clockwise:
% [link2, angle2]=fourbar(5,90,[],[],5,270,5,180)
% %  Linkage 1 is of length 5 and is at 90 degrees.
% %  Linkage 2 is unknown.
% %  Linkage 3 is of length 5 and at 270 degrees.
% %  Linkage 4 is of length 5 and at 180 degrees.
%
% % Alternative ways to call fourbar that will get the correct solution:
% [link2, angle2]=fourbar(5,90,[],[],5,270,5,180)
% [link1, link2, link3, link4]=fourbar(-5,270,[],[],5,270,5,180)
% links=fourbar(-5,270,[],[],5,270,5,180)
%
% See also link_solver, draw_bar

% Author: Jedediah Frey
% Created: May 2010
% Copyright 2010
error(nargchk(8, 9, nargin, 'struct'))
error(nargchk(0, 4, nargout, 'struct'))
switch nargout
    case {0,1}
        varargout{1}=link_solver(varargin{:});
    case 2
        [unknown1,unknown2]=link_solver(varargin{:});
        varargout{1}=unknown1;
        varargout{2}=unknown2;
    case 4
        [ varargout{1}, varargout{2}, varargout{3}, varargout{4}]=link_solver(varargin{:});
    otherwise
        error('Incorrect number of outputs');
end