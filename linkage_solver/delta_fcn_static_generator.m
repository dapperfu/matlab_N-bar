% delta_fcn_static_generator 
% Renerates all possible partial derivatives for linkage mechanisms for up
% to 10 linkages (can be changed).
% For use with link_solver on computers that do not have symbolic math
% installed.

if ~exist('sym')
    error('Symbolic library required to run delta_fcn_static_generator');
end
n=10; % Generate equations for up to n linkages.
variables=cell(1,2*n);
epsilon1_eqn='';
epsilon2_eqn='';
for i=1:n
    variables(2*i-1:2*i)={sprintf('length_%d',i) sprintf('angle_%d',i)};
    epsilon1_eqn=sprintf('%s+length_%d*cos(angle_%d)',epsilon1_eqn,i,i);
    epsilon2_eqn=sprintf('%s+length_%d*sin(angle_%d)',epsilon2_eqn,i,i);
end
epsilon1=sym(epsilon1_eqn(2:end));
epsilon2=sym(epsilon2_eqn(2:end));
fid=fopen('delta_function_static.m','w');
fprintf(fid,'function [delta_u1,delta_u2,n]=delta_function_static(varargin)\n');
fprintf(fid,'%%[delta_u1,delta_u2]=delta_function_static(unknown1,unknown2,n)\n');
fprintf(fid,'%%Auto generated with delta_function_static.\n\nn=%d;\n',n);
fprintf(fid,'error(nargchk(3,3, nargin, ''struct''));\n');
fprintf(fid,'if varargin{3}>n\n');
fprintf(fid,'\terror(''%s'',n,varargin{3});\n','Equations have only been generated for %d links, equations for Link %d cannot be determined.\nEdit delta_fcn_static_generator and set ''''n'''' to a higher number. Rerun it on a computer with symbolic library installed');
fprintf(fid,'end\n\n');
delta_u=cell(1,2);
for i=1:numel(variables)
    for j=1:numel(variables)
        if j==i
            continue;
        end
        % Set up the matrix that is used to solve for the unknown var.
        a_matrix=[[diff(epsilon1,variables{i}),diff(epsilon1,variables{j})];[diff(epsilon2,variables{i}),diff(epsilon2,variables{j})]];
        % Determine the symbolic determinate of the matrix.
        determinant=det(a_matrix);
        % Determine how much to change the unknown variable.
        delta_u{1}=char((-epsilon1*a_matrix(2,2)+epsilon2*a_matrix(1,2))/determinant);
        delta_u{2}=char((-epsilon2*a_matrix(1,1)+epsilon1*a_matrix(2,1))/determinant);
        op={'*','/','^'};
        for k=1:2
            for l=1:numel(op)
                delta_u{k}=strrep(delta_u{k},op{l},['.' op{l}]);
            end
        end
        fprintf(fid,'if (strcmp(varargin{1},''%s'')&&strcmp(varargin{2},''%s''))\n\tdelta_u1=''%s'';\n\tdelta_u2=''%s'';\n\treturn;\nend\n',variables{i},variables{j},delta_u{1},delta_u{2});
    end
end
fclose('all');