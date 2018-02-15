function m_function=delta_function_writer(unknown1,unknown2,n_links)
% [m_function]=delta_function_writer(unknown1,unknown2,n_links)
% Generates a temporary function to solve for unknown linkage variables.
%
% If no output is specified (nargout==0), then the m file generated is
% delta_function_temp. If an output is specified that a randomly generated
% temporary file name is used. This is done because of the way the JIT
% compiler works. If you try to solve for two different variables in a
% script or funcition, the compiler will compile 'delta_function_temp.m'
% only once, so the second time it is called with different unknown
% variables an error will be given. Use feval to evaluate the function.
% 
% Example:
% delta_function_writer('link_1','angle_2',4);
% edit delta_function_temp;
%
% m_file=delta_function_writer('link_1','angle_1',5);
% edit(m_file);
%
% See also: delta_fcn_static_generator, link_solver, fourbar, draw_bar,
% tempnam

if nargout<1
    m_function='delta_function_temp.m';
else
    [jnk,m_function]=fileparts(tempname);
end

[delta_u1,delta_u2,n_compiled]=delta_function_static(unknown1,unknown2,n_links);
fid=fopen([m_function '.m'],'w');
fprintf(fid,'function [delta_u1,delta_u2]=delta_function_temp(links)\n');
% Extract given variables.
for i=1:n_links
    fprintf(fid,'length_%d=links.length_%d;\n',i,i);
    fprintf(fid,'angle_%d=links.angle_%d;\n',i,i);
end
% Zero all other variables that the static delta function is compiled for.
for i=n_links+1:n_compiled
    fprintf(fid,'length_%d=0;\n',i);
    fprintf(fid,'angle_%d=0;\n',i);
end
fprintf(fid,'%% Static delta function with unknown variables: %s & %s\n',unknown1,unknown2);
fprintf(fid,'delta_u1=%s;\ndelta_u2=%s;\nend\n',delta_u1,delta_u2);
fclose('all');
while ~(exist(m_function,'file'))
    % Wait while the OS updates file handles, otherwise execution time is too quick and the file will show up as not existing.
end
end