function result = execute_code( local, varargin )

% function execute_code( local, code_cell [, u [, var_name ] ] )
%
%   local       = true if should be executed locally, false otherwise
%   code_cell   = cell containing:
%                   (1) function handle
%                   (2,:) arguments (strings)
%   u           = udp object - optional, required for UDP transmission
%   var_name    = variable name for function output - optional
%                   - only applicable when used for remote execution!
%
% This function will either send code to be executed remotely over UDP or 
% execute it locally, depending on the value of 'local'. If an argument in
% cell_code should be interpreted as a variable, it should be prefixed by a
% '*' symbol, as follows:
%
%   var = 8;
%   execute_code( local, u, { @max, '*var',7 } )

% EK, 6/3/2010

code_cell = varargin{1};

% set UDP object
var_name = '';
if nargin >= 3
    u = varargin{2};
end

% set variable name to receive function output
if nargin >= 4
    var_name = strcat(varargin{3},'=');
end

if local
    % resolve all local variables
    for n = 2:length(code_cell)
        % Check for '*' prefixing the entry. If present, should be a
        % variable, resolve it.
        if code_cell{n}(1) == '*'
            code_cell{n} = evalin('caller',code_cell{3}(2:end));
        end
    end
    
    % evaluate the function
    result = code_cell{1}(code_cell{2:end});
    disp(result);
else
    % format the argument list
    arg_list = '';
    
    % Check for '*' prefixing entry. If present, don't surround with
    % quotes.
    for n = 2:length(code_cell)
        % form argument list
        
        % check if using the *var syntax
        if code_cell{n}(1) == '*'
            arg_list = strcat(arg_list,code_cell{n}(2:end),',');

        % if number, coerce contents to string
        elseif isnumeric(code_cell{n})
            arg_list = strcat(arg_list,'[',num2str(code_cell{n}),'],');
        
        % if string, add to list with quotes
        else
            arg_list = strcat(arg_list,'''',code_cell{n},''',');
        end
    end
    
    % trim trailing comma off end of list
    arg_list = arg_list(1:length(arg_list)-1);
    
    str = strcat('func=',func2str(code_cell{1}),';',var_name,'func(',arg_list,');');
    fprintf(u,str);
end