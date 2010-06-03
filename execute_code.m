function result = execute_code( local, u, varargin )

% function execute_code( local, u, code_cell )
%
%   local       = true if should be executed locally, false otherwise
%   u           = udp object
%   code_cell   = cell containing:
%                   (1) function handle
%                   (2) udp object
%                   (3) arguments (contained in a single string)
%                   (4) variable name for function output - optional
%                          only applicable when used for remote execution!
%
% This function will either send code to be executed remotely over UDP or 
% execute it locally, depending on the value of 'local'.

% EK, 6/3/2010

code_cell = varargin{1};

% set variable name to receive function output
var_name = '';
if nargin > 3
    var_name = strcat(varargin{2},'=');
end

if local
    result = code_cell{1}(code_cell{2:end});
    disp(result);
else
    % format the argument list
    arg_list = '';
    for n = 2:length(code_cell)
        if isa(code_cell{n},'char')
            arg_list = strcat(arg_list,'''',code_cell{n},''',');
        else
            arg_list = strcat(arg_list,cast(code_cell{n},'char'),',');
        end
    end
    % trim trailing comma off end of list
    arg_list = arg_list(1:length(arg_list)-1);
    
    str = strcat('func=@',func2str(code_cell{1}),';',var_name,'func(',arg_list,');');
    fprintf(u,str);
end