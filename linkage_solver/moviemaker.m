%% Four Bar Linkage
% Rotates linkage 1 in the drawing below a full 360 degrees and makes a
% movie of the resulting movement. This script is just used to illustrate
% how fourbar (and link_solver) and draw_bar may be used. It is sparsely
% documented and for demonstrative purposes only.

%        o
%       /|                                                                                                                                
%  ?*  / |                                                                                                                                
% (5) /  |                                                                                                                                
%    /   |                                                                                                                                
%   /    |                                                                                                                                
%  /     | (4)                                                                                                                               
% o      |  ?*                                                                                                                              
% |      |                                                                                                                               
% | (1)  |                                                                                                                               
% | 90*  |                                                                                                                               
% o------o                                                                                                                               
% (4) 180* 

mov = avifile('movies/fourbar.avi','FPS',45);
link=fourbar(1,1:360,5,[],4,[],4,180,[45,-90]);
for i=1:length(link)
    draw_bar(link(i),'off');
    axis([-1.5 5 -1.5 5])
    set(gcf,'Position',[680 678 560 420])
    F = getframe(gca);
    mov = addframe(mov,F);
end
mov = close(mov);

%% Parallelogram 
for i=1:360
    draw_bar(5,i,10,0,5,i+180,10,180,'off');
    axis([-6 16 -6 16])
    set(gcf,'Position',[680 678 560 420])
    M(i)=getframe;
end
if ~exist('mpgwrite')
    error('mpgwrite not installed, download it at: http://www.mathworks.com/matlabcentral/fileexchange/309-mpgwrite');
end
mpgwrite(M,colormap,'movies/paralellogram',1);

%% Slider Mechanism
clear;
mov = avifile('movies/slider.avi','FPS',45);
link=link_solver(1,1:360,5,[],.25,-90,[],180);
for i=1:length(link)
    draw_bar(link(i),'off');
    axis([-1.5 6.5 -1.5 6.5])
    set(gcf,'Position',[100 100 500 500])
    F = getframe(gca);
    mov = addframe(mov,F);
end
mov = close(mov);
                                                                      
%% Five bar
% Linkage from linkage_solver example
% Solve for unknown linkage and length
links=link_solver(6,0:359,5,53.1301,[],[],6,180:539,6,180);
mov = avifile('movies/fivebar.avi','FPS',45);
for i=1:length(links)
    draw_bar(links(i),'off');
    axis([-6.5 12.5 -6.5 12.5])
    set(gcf,'Position',[680 678 560 420])
    F = getframe(gca);
    mov = addframe(mov,F);
end
mov = close(mov);