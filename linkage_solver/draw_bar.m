function varargout=draw_bar(varargin)
%DRAW_BAR  One line description goes here.
%   fig=draw_bar(link1,angle1,link2,angle2,...,linkN,angleN,[legend])
%   fig=draw_bar(link_structure,[legend])
%
%   Draws the linkage described with linkage length and angles. Will give
%   an warning if the linkage does is not a closed system. Returns the
%   figure of the plotted output
%
%   The legend command is optional, if it is set to 'on' a legend
%   will be created for each angle with the length and angle. Options:
%   'on' (default) or 'off'.
%
%   Example:
%   % Five bar linkage
%   [links]=link_solver(6,90,5,53.1301,[],[],6,270,6,180);
%   draw_bar(links);
%
%   % Four bar linkage - Parallelogram
%   link_solver(1,45,1,0,[],[],1,180)
%   draw_bar(ans);
%
%   % Three bar linkages
%   % -Equilateral Triangle
%   [link3, angle3]=link_solver(1,60,[],[],1,180);
%   draw_bar(1,60,link3,angle3,1,180);
%   % - Isosceles Triangle
%   [link1, link2, link3]=link_solver(1,rand(1,1)*60,1,[],[],180);
%   draw_bar(link1(1),link1(2),link2(1),link2(2),link3(1),link3(2));
%   % - Scalene Triangle
%   [links]=link_solver(5,0,3,45,[],[]);
%   draw_bar(links);
%
%   % Multiple
%   links=link_solver(1,[0 45 90],5,[],4,[],4,180,[45,270]);
%   draw_bar(links)
%   disp('Press any key to display with no legend');pause;
%   draw_bar(links,'off');
%
%   See also: link_solver, fourbar

% Author: Jedediah Frey
% Created: May 2010
% Copyright 2010
%
if ischar(varargin{end})
    switch varargin{end}
        case 'on'
            legend_on=true;
        case 'off'
            legend_on=false;
        otherwise
            error('Unknown legend command. Please use ''on'' or ''off''');
    end
    varargin(end)='';
else
    legend_on=true;
end
switch numel(varargin);
    % If the user just inputs the structure that is returned from
    % fourbar/fivebar, use that.
    case 1
        var=varargin{1};
        c=numel(fieldnames(var));
        if mod(c,2)
            error('Odd number of input arguments');
        end
        num_links=c/2;
        num_mechanisms=numel(var);
        for i=1:num_links
            for l=1:num_mechanisms
                link_length(l,i)=var(l).(sprintf('length_%d',i));
                angle(l,i)=var(l).(sprintf('angle_%d',i));
            end
        end
    otherwise
        if mod(numel(varargin),2)
            error('Odd number of input arguments');
        end
        if unique(cellfun('length',varargin))>2
            error('Too many different length inputs given. If multiple mechanical systems are to be plotted the lengths and angles of the linkages must be of length 1 (meaning constant) or all others must be of the same length, one for each of the mechanical systems')
        end
        num_mechanisms=max(cellfun('length',varargin));
        num_links=numel(varargin)/2;
        for i=1:num_links
            len_tmp=varargin{2.*i-1};
            ang_tmp=varargin{2.*i};
            for l=1:num_mechanisms
                link_length(l,i)=len_tmp(min([length(len_tmp) l]));
                angle(l,i)=ang_tmp(min([length(ang_tmp) l]));
            end
        end
end
if size(num_mechanisms,2)>5
    r=questdlg('More than 5 link mechanisms given. draw_bar will open a figure for each one. Are you sure you want to proceed?',sprintf('Proceed with %d figures?',num_mechanisms),'Yes','Cancel Plots','Cancel Plots');
    if strcmp('Cancel Plots',r)
        error('Plotting canceled for %d figures.',num_mechanisms);
    end
end

% Convert angles to radians.
angle=angle.*pi/180;
if num_mechanisms==1
    fig=gcf;
else
    fig=1:num_mechanisms;
end
for q=1:num_mechanisms
    % Draw Plot
    figure(fig(q));clf(fig(q));
    % Determine each point.
    pt(1,:)=[0 0]; % Always start at the origin.
    % Calculate each point
    for i=1:num_links
        pt(i+1,:)=[link_length(q,i).*cos(angle(q,i))+pt(i,1) link_length(q,i).*sin(angle(q,i))+pt(i,2)];
    end
    % If the final point isn't within a hundredth of the origin, the
    % lengths/angles may not describe a closed linkage.
    if max(abs(pt(end,:)))>1E-2
        warning('Last point further than 0.01 from origin, linkage may not close.');
    else
        pt(end,:)=[0 0];
    end
    clf;hold all; % Clear current plot and hold all.
    ColorSet=varycolor(num_links); % Create a varied color array.
    l=cell(0,0); % Create empty legend cell.
    for i=1:num_links
        % Plot each point, turn off handle visibility so no legend entry is
        % created.
        plot(pt(i,1),pt(i,2),'Ok','HandleVisibility','off');
        %
        line(pt(i:i+1,1),pt(i:i+1,2),'Color',ColorSet(i,:))
        % Describe the angle and length of length.
        l=[l {sprintf('Link %d: %.2f \\angle%.2f^o',i,link_length(q,i),angle(q,i)*180/pi)}];
    end
    % Draw the last point
    plot(pt(end,1),pt(end,2),'Ok','HandleVisibility','off');
    % Write legend.
    if legend_on
        legend(l,'Location','BestOutside');
    end
    % Write axes labels.
    xlabel('X');ylabel('Y');
    % Axis 'tight' will make the axis fit so that the lines are usually on the
    % boundry. 
    axis('tight');
    plot_axis(q,:)=axis; % Store it for later to determine the global axis.
    % Clear the points.
    clear('pt');
end
if num_mechanisms>1
    % Determine the range of the plots that will encompass all plots.
    mins=min(plot_axis(:,[1 3]));
    maxs=max(plot_axis(:,[2 4]));
    % Figure out the ideal axis for all plots by adding a 5% buffer to all sides so that the drawing can
    % easily be seen.
    tight_axis=[mins(1) maxs(1) mins(2) maxs(2)];
else
    tight_axis=plot_axis;
end
x=range(tight_axis(1:2)).*.05;
y=range(tight_axis(3:4)).*.05;
for q=1:num_mechanisms
    figure(fig(q));
    axis([tight_axis(1)-x tight_axis(2)+x tight_axis(3)-y tight_axis(4)+y]);
end
% If on output argument is given, return all the figures used.
if nargout==1
    varargout{1}=fig;
end
end

function ColorSet=varycolor(NumberOfPlots)
% VARYCOLOR Produces colors with maximum variation on plots with multiple
% lines.
%
%     VARYCOLOR(X) returns a matrix of dimension X by 3.  The matrix may be
%     used in conjunction with the plot command option 'color' to vary the
%     color of lines.
%
%     Yellow and White colors were not used because of their poor
%     translation to presentations.
%
%     Example Usage:
%         NumberOfPlots=50;
%
%         ColorSet=varycolor(NumberOfPlots);
%
%         figure
%         hold on;
%
%         for m=1:NumberOfPlots
%             plot(ones(20,1)*m,'Color',ColorSet(m,:))
%         end
%Created by Daniel Helmick 8/12/2008
error(nargchk(1,1,nargin))%correct number of input arguements??
error(nargoutchk(0, 1, nargout))%correct number of output arguements??
%Take care of the anomolies
switch NumberOfPlots
    case 1
        ColorSet=[];
    case 1
        ColorSet=[0 1 0];
    case 2
        ColorSet=[0 1 0; 0 1 1];
    case 3
        ColorSet=[0 1 0; 0 1 1; 0 0 1];
    case 4
        ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1];
    case 5
        ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1; 1 0 0];
    case 6
        ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1; 1 0 0; 0 0 0];
    otherwise %default and where this function has an actual advantage
        %we have 5 segments to distribute the plots
        EachSec=floor(NumberOfPlots/5);
        %how many extra lines are there?
        ExtraPlots=mod(NumberOfPlots,5);
        %initialize our vector
        ColorSet=zeros(NumberOfPlots,3);
        %This is to deal with the extra plots that don't fit nicely into the
        %segments
        Adjust=zeros(1,5);
        for m=1:ExtraPlots
            Adjust(m)=1;
        end
        SecOne   =EachSec+Adjust(1);
        SecTwo   =EachSec+Adjust(2);
        SecThree =EachSec+Adjust(3);
        SecFour  =EachSec+Adjust(4);
        SecFive  =EachSec;
        for m=1:SecOne
            ColorSet(m,:)=[0 1 (m-1)/(SecOne-1)];
        end
        for m=1:SecTwo
            ColorSet(m+SecOne,:)=[0 (SecTwo-m)/(SecTwo) 1];
        end
        for m=1:SecThree
            ColorSet(m+SecOne+SecTwo,:)=[(m)/(SecThree) 0 1];
        end
        for m=1:SecFour
            ColorSet(m+SecOne+SecTwo+SecThree,:)=[1 0 (SecFour-m)/(SecFour)];
        end
        for m=1:SecFive
            ColorSet(m+SecOne+SecTwo+SecThree+SecFour,:)=[(SecFive-m)/(SecFive) 0 0];
        end
end
end