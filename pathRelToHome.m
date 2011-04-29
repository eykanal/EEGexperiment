function newDir = pathRelToHome( directory )
%
% function success = pathRelToHome( directory )
%
% Accepts a folder existing in the user directory as input and returns the
% full path to that folder as output. Intended to make the dynamic adding of
% folders to the MATLAB path more robust to changing the computer on which the
% function is running.
%
%   directory - a pathstring to a folder within your home directory

cmd = ['cd ~/' directory '; pwd'];
[status newDir] = unix( cmd );

if ~isempty(findstr('No such file', newDir))
    error('Folder does not exist within home directory.');
end