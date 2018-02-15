function [unknown1,unknown2]=fivebar(link1,alpha1,link2,alpha2,link3,alpha3,link4,alpha4,link5,alpha5,guess1,guess2)
% The original program that I wrote to solve for five bars for Purdue ME352 Project #2,
% Spring 2005. As is, this paragraph is the only added documentation. Served as the
% basis for all the newer scripts. Saved for posterity.

% Also to remind me of how little I used to know about Matlab and how I used to program.

tic;
stop_criterion=0.001*pi/180;

% Set the index of unknown variables to 1.
uv=1;
% Create a structure of the variables.
variables=struct('link1',link1,'alpha1',alpha1*pi/180,'link2',link2,'alpha2',alpha2*pi/180,'link3',link3,'alpha3',alpha3*pi/180,'link4',link4,'alpha4',alpha4*pi/180,'link5',link5,'alpha5',alpha5*pi/180);
% Set up a blank structure for the unknown variables.
unknown=struct('u1','unknown1','u2','unknown2');
% The following if statements check each of the variables to see if
% they are undefined.  If they are undefined then they will define the
% unknown structure and increment the unknown variable index (uv) by 1.
if(~isnumeric(link1))
    unknown=setfield(unknown,['u' num2str(uv)],'link1');
    uv=uv+1;
end
if(~isnumeric(alpha1))
    unknown=setfield(unknown,['u' num2str(uv)],'alpha1');
    uv=uv+1;
end
if(~isnumeric(link2))
    unknown=setfield(unknown,['u' num2str(uv)],'link2');
    uv=uv+1;
end
if(~isnumeric(alpha2))
    unknown=setfield(unknown,['u' num2str(uv)],'alpha2');
    uv=uv+1;
end
if(~isnumeric(link3))
    unknown=setfield(unknown,['u' num2str(uv)],'link3');
    uv=uv+1;
end
if(~isnumeric(alpha3))
    unknown=setfield(unknown,['u' num2str(uv)],'alpha3');
    uv=uv+1;
end
if(~isnumeric(link4))
    unknown=setfield(unknown,['u' num2str(uv)],'link4');
    uv=uv+1;
end
if(~isnumeric(alpha4))
    unknown=setfield(unknown,['u' num2str(uv)],'alpha4');
    uv=uv+1;
end
if(~isnumeric(link5))
    unknown=setfield(unknown,['u' num2str(uv)],'link5');
    uv=uv+1;
end
if(~isnumeric(alpha5))
    unknown=setfield(unknown,['u' num2str(uv)],'alpha5');
    uv=uv+1;
end

% Set the initial guesses of the unknown variables.
if strcmp(unknown.u1(1:end-1),'alpha')
    variables=setfield(variables,unknown.u1,guess1*pi/180);
else 
    variables=setfield(variables,unknown.u1,guess1);
end

if strcmp(unknown.u2(1:end-1),'alpha')
    variables=setfield(variables,unknown.u2,guess2*pi/180);
else 
    variables=setfield(variables,unknown.u2,guess2);
end

% Enter the vector loop equations for the four bar linkage in symoblic
% notation.
epsilon1=sym('link1*cos(alpha1)+link2*cos(alpha2)+link3*cos(alpha3)+link4*cos(alpha4)+link5*cos(alpha5)');
epsilon2=sym('link1*sin(alpha1)+link2*sin(alpha2)+link3*sin(alpha3)+link4*sin(alpha4)+link5*sin(alpha5)');

% Set up the matrix that is used to solve for the unknown variables.
a_matrix=[[diff(epsilon1,unknown.u1),diff(epsilon1,unknown.u2)];[diff(epsilon2,unknown.u1),diff(epsilon2,unknown.u2)]];

% Determine the symbolic determinate of the matrix.
determinant=det(a_matrix);

% Set the change in unknown variables to the definition that was given
% in class.
delta_u1=(-epsilon1*a_matrix(2,2)+epsilon2*a_matrix(1,2))/determinant;
delta_u2=(-epsilon2*a_matrix(1,1)+epsilon1*a_matrix(2,1))/determinant;

% Assign the initial deltas to be a very large number so that it will
% enter the while loop.
delta_u1_num=1E10;
delta_u2_num=1E10;

% While loop to test for stop conditions, absolute value is used
% because the change could be negative, but not nessisarily close to
% the answer.
i=0;
while(stop_criterion<abs(subs(delta_u1_num)) && stop_criterion<abs(subs(delta_u2_num)))
    %Extract each of the variables from the structure so that they can
    %be used in the symbolic notation.
    i=i+1;
    link1=variables.link1;
    alpha1=variables.alpha1;
    link2=variables.link2;
    alpha2=variables.alpha2;
    link3=variables.link3;
    alpha3=variables.alpha3;
    link4=variables.link4;
    alpha4=variables.alpha4;
    link5=variables.link5;
    alpha5=variables.alpha5;
    
    
    % Assign the delta for each unknown variable.
    delta_u1_num=subs(delta_u1);
    delta_u2_num=subs(delta_u2);
    
    % Add the old guess and the delta to form the new guess and repeat.
    variables=setfield(variables,unknown.u1,getfield(variables,unknown.u1)+subs(delta_u1));
    variables=setfield(variables,unknown.u2,getfield(variables,unknown.u2)+subs(delta_u2));
end
% Assign the output variable to the structure.
variables.alpha1=variables.alpha1*180/pi;
variables.alpha2=variables.alpha2*180/pi;
variables.alpha3=variables.alpha3*180/pi;
variables.alpha4=variables.alpha4*180/pi;
variables.alpha5=variables.alpha5*180/pi;

out=variables;
unknown1=getfield(variables,unknown.u1);
unknown2=getfield(variables,unknown.u2);
fprintf('Time: %f\n',toc);