% set up UDP messaging socket
localIP = '10.1.1.3';
remoteIP = '10.1.1.2';
port = 6665;

try
    u = udp(remoteIP, port);
    fopen(u);
catch ME1
    fprintf('Unable to open UDP connection');
    rethrow (ME1);
end

diameter =  0.3;
color =     [255 255 0];

% concatenate into one long array for fprintf
arguments = [diameter color];

% demo code for showing four sets of dots and targets
try
    fprintf(u,'myTarg1    = rAdd(''dXtarget'',1,''visible'',true,''diameter'',2,''penWidth'',24,''color'',[0 0 0]);');
    fprintf(u,'UDP worked!');
catch
    fprint('myTarg1    = rAdd(''dXtarget'',1,''visible'',true,''diameter'',2,''penWidth'',24,''color'',[0 0 0]);');
    fprintf('udp didn''t work!');
end
    
fclose(u);
delete(u);
clear u;
    
% test string concatenation within fprintf. Works with strcat. Note space
% before string... spaces after string are stripped.
fprintf(1,strcat('hello', ...
    ' hello2', ...
    ' hello%i\n'), 4);
