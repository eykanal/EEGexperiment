function result = execute_code( local, varargin )

% function execute_code( local, code_cell [, u [, var_name ] ] )
%
%   local       = boolean - true if should be executed locally, false otherwise
%   code_cell   = cell containing:
%                   (1) function handle
%                   (2,:) arguments (strings)
%   u           = udp object - optional, required for UDP transmission
%   var_name (optional)	= Variable name for function output. For functions
%                 returning a single value, should be string. If
%                 multiple values returned, should be cell array of
%                 strings.
%
% This function will either send code to be executed remotely over UDP or 
% execute it locally, depending on the value of 'local'. If an argument in
% cell_code should be interpreted as a variable, it should be written as a
% string prefixed by the '*' symbol, as follows:
%
%   var = 8;
%   execute_code( local, u, { @max, '*var',7 } );
%
% This would result in the following function being executed:
% 
%    max(var,7);
%
% 
% Eliezer Kanal, 6/3/2010

code_cell = varargin{1};

% set UDP object
var_name = '';
if nargin >= 3
    u = varargin{2};
end

% set variable name to receive function output
if nargin >= 4
    var_name = varargin{3};
	if ~iscell(var_name)
		var_name = {var_name};
	end
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
    
    % Evaluate the function, assigning the result to var_name. Code written
    % this way to deal with functions that return more than one value.
    nao = nargout(code_cell{1});
    [result{1:nao}] = code_cell{1}(code_cell{2:end});

    if ~isempty(var_name)
        for n = 1:nao
            assignin('caller', var_name{n}, result{n});
        end
    end
        
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
	
	equals = '';
	% add "=" if var_name is present
	if ~isempty(var_name)
		equals = '=';
	end
    
    str = strcat('func=',func2str(code_cell{1}),';',var_name,equals,'func(',arg_list,');');
    fprintf(u,str);
    disp(str);
end