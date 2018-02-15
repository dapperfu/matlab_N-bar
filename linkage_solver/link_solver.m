function varargout=link_solver(varargin)
% [unknown1,unknown2]=link_solver(
%           link1,angle1,link2,angle2,link3,angle3,
%           ...,linkN,angleN,[guess1,guess2])
% [all_linkages]=link_solver(
%           link1,angle1,link2,angle2,link3,angle3,
%           ...,linkN,angleN,[guess1,guess2])
% [link1,link2,link3,...,linkN]=link_solver(
%           link1,angle1,link2,angle2,link3,angle3,
%           ...,linkN,angleN,[guess1,guess2])
%
% Generic linkage solver. Most common use is for four bar linkages.
%
% Given a guess, the solver will attempt to start from the guessed
% position. There are linked systems where there may be more than one valid
% solution.
%
% Returns:
%   unknown1: the first unknown given
%   unknown2: the second unknown given
%   all_linkages: a struct with all linkages and angles corrected to 0-360
%       and positive linkage length.
%
% To solve for any two unknowns, input all other given parameters. Unknown 
% information should be inputted as either an empty string ('') or
% empty array ([]). All solutions will be returned with angles between 
% 0-360 and linkage lengths positive.
%
% To keep signs and angles correct, select one point and work around clockwise or counter clockwise
% using the length as a positive number and the angle as the absolute angle
% from the horizon. If you wish to input the angle of the linkage from
% 'end' to 'beginning' then you should give the length of the linkage as
% negative.
%
% Example:
% Consider this simple five bar linkage with shown unknowns.  
% %     
% %          O
% %         / \ ?*
% %        /   \
% %   (5) /     \ (?)
% %      /       \
% %     / 53.87*  \
% %    O           O
% %    |           |
% %    |           |
% %(6) |           | (6)
% %    |           |
% %    | 90*   90* |
% %    O - - - - - O
% %         (6)
%
% %Working clockwise:
% [unknown1,unknown2]=link_solver(6,90,5,53.1301,[],[],6,270,6,180)
%
% %  Linkage 1 is of length 5 and is at 90 degrees.
% %  Linkage 2 is unknown.
% %  Linkage 3 is of length 5 and at 270 degrees.
% %  Linkage 4 is of length 5 and at 180 degrees.
% % Alternative ways to call link_solver that will get the correct solution:
% [length3, angle3]=link_solver(6,90,5,53.1301,[],[],6,270,-6,0,[5,-50])
% links=link_solver(6,90,5,53.1301,'',[],6,-90,6,180)
% [link1, link2, link3, link4, link5]=link_solver(6,90,-5,233.1301,{},[],6,270,6,180)
%
% % Inputs can also be given in vector format to simultaneously solve for
% % multiple vector input.
% links=link_solver(6,[0 45 90],5,'',5,'',6,270)%
%
% % Supplying a guess for the unknown variables is not manditory, however it
% % is suggested as certain input configurations the solver will correctly
% % solve for the unknowns, although the linkage may not look as expected.
% % No guesses
% link=link_solver(1,-10,5,[],4,[],4,180),figure(1);draw_bar(link);
% link=link_solver(1,-15,5,[],4,[],4,180),figure(2);draw_bar(link);
% % Guesses
% link=link_solver(1,-10,5,[],4,[],4,180),figure(1);draw_bar(link)
% link=link_solver(1,-15,5,[],4,[],4,180,[link.angle_2 link.angle_3]),figure(2);draw_bar(link)
%
% % Guesses for multiple solutions to the same linkage measurements
% l=link_solver(1,-15,5,[],4,[],4,180,[45,-90;-45,90]);draw_bar(l)

% Author: Jedediah Frey
% Created: May 2010
% Copyright 2010
% Change to enabled to show the results after each loop.
verbose=false;
warning('off','MATLAB:DELETE:FileNotFound'); % Disable warning from tryin to delete temp file name if it doesn't exist.

%% Determine and assign unknown variables.
unknown_idx=find(cellfun('isempty',varargin));
if length(unknown_idx)<2
    error('Over constrained system. At least two inputs should be empty.');
elseif length(unknown_idx)>2
    error('Under constrained system. Only two inputs should be empty.');
end
% Assign the guessed variables
for i=1:2
    if mod(unknown_idx(i),2)
        unknown{i}=sprintf('length_%d',floor((unknown_idx(i)+1)/2));
    else
        unknown{i}=sprintf('angle_%d',floor((unknown_idx(i)+1)/2));
    end
    if mod(nargin,2)
        varargin{unknown_idx(i)}=varargin{end}(:,i)';
    else
        % Nothing guessed, guess a a positive, non zero, non identical
        % number
        varargin{unknown_idx(i)}=i;
    end
end
%% Determine and assign the given link angles and lengths.
% Create a structure of the bar lengths and input angles
link_count=floor(nargin/2);
error(nargoutchk(0, link_count, nargout, 'struct'));
for i=1:link_count;
    link=sprintf('length_%d',i);
    angle=sprintf('angle_%d',i);
    links.(link)=varargin{i*2-1};
    links.(angle)=varargin{i*2}.*pi/180;
end
%% Create the function to calculate the delta & setup loop variables
% Create the static delta function for the given unknown variables. 
% Cuts down on symbolic library time.
m_file=delta_function_writer(unknown{1},unknown{2},link_count);
% Print header if verbrosity is turned on.
if verbose
    fprintf('%10s%10s%10s%10s%10s\n','Loop',unknown{1},unknown{2},'Delta 1','Delta 2');
end
%%
% Once the deltas are smaller than the stop criterion, the function exits.
% How accurate should the model be.
stop_criterion=1E-10;
delta_u1=inf;delta_u2=inf; % Set initial stop criterion large.
i=1;
%% Process data.
% While the change is larger than the stop critera (both).
while(stop_criterion<max(abs((delta_u1))) && stop_criterion<max(abs((delta_u2))))
    if (mod(i,10000)==0)
        error('%d loops executed with no solution, canceleing.',i);
    end
    % Calculate the changes to the guesses.
    [delta_u1,delta_u2]=feval(m_file,links);
    if any(isinf([delta_u1,delta_u2])|isnan([delta_u1,delta_u2]))
        error('Inf or NaN returned as a delta. Current solution could be unsolveable an indeterminate system.');
    end
    % If verbose, print current loop.
    if verbose
        % If the field is an angle, convert it to degrees.
        for j=1:2
            if strcmp(unknown{j}(1:5),'angle')
                tmp{j}=wrapTo360(links.(unknown{j}).*180/pi);
            else
                tmp{j}=links.(unknown{j});
            end
        end
        % Print the current loop calculations.
        fprintf('%10d%10.3f%10.3f%10.3f%10.3f\n',i,tmp{1},tmp{2},delta_u1,delta_u2);
    end
    % Add the old guess and the delta to form the new guess and repeat.
    links.(unknown{1})=links.(unknown{1})+delta_u1;
    links.(unknown{2})=links.(unknown{2})+delta_u2;
    i=i+1;
end
%% Post processing cleanup.
solved_links=length(links.(unknown{1}));
f=fieldnames(links);
% If more than one solution was solved for.
if solved_links>1
    % For each of the solutions
    for l=1:solved_links
        for i=1:numel(f);
            if length(links.(f{i}))==1
                links.(f{i})=repmat(links.(f{i}),size(links.(unknown{1})));
            end
        end
    end
end
% Orient the bars so that all lengths are positive and all angles are
% 0-360.
links=bar_ortienter(links,link_count);
% Convert radians back to degrees.
for i=1:link_count
    a=sprintf('angle_%d',i);
    links.(a)=wrapTo360(links.(a).*180./pi);
end

%% Output Processing.
% Assign the variables to return.
switch nargout
    case {0,1}
        % If there was more than one unknown position solved for (matrix
        % input) then create an array of structures for each given input.
        if solved_links>1
            links_temp=links;clear('links');
            % For each of the solved linkage solutions
            for l=1:solved_links
                % For each length/angle
                for i=1:numel(f);
                    links(l).(f{i})(1)=links_temp.(f{i})(l);
                end
            end
        end
        varargout{1}=links;
    case 2
        varargout{1}=links.(unknown{1});
        varargout{2}=links.(unknown{2});
    case link_count
        % Put into 
        for i=1:link_count
            link=sprintf('length_%d',i);
            angle=sprintf('angle_%d',i);
            varargout{i}=[links.(link)',links.(angle)'];
        end
    otherwise
        error('Incorrect number of outputs');
end
% Delete the temporary function.
delete([m_file '.m']);
end

%% Helper Functions.
% Orient the bars so that all lengths are positive and all angles are
% 0-360.
function links=bar_ortienter(links,link_count)
% Loop through link lengths
for i=1:link_count
    link=sprintf('length_%d',i);
    % If any is less than 0
    if (any(links.(link)<0))
        angle=sprintf('angle_%d',i);
        % And rotate the angle by 180 degrees still (in radians)
        links.(angle)(links.(link)<0)=links.(angle)(links.(link)<0)+pi;
        % Orient bar with positive length.
        links.(link)=abs(links.(link));
    end
end
end

function lon = wrapTo360(lon)
% wrapTo360 Wrap angle in degrees to [0 360]
%
%   lonWrapped = wrapTo360(LON) wraps angles in LON, in degrees, to the
%   interval [0 360] such that zero maps to zero and 360 maps to 360.
%   (In general, positive multiples of 360 map to 360 and negative
%   multiples of 360 map to zero.)
%
%   See also wrapTo180, wrapToPi, wrapTo2Pi.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2008/12/22 23:50:54 $

positiveInput = (lon > 0);
lon = mod(lon, 360);
lon((lon == 0) & positiveInput) = 360;
end