% set up UDP messaging socket
localIP = '10.1.1.3';
remoteIP = '10.1.1.2';
port = 6665;

%socketTag = matlabUDP('open',localIP,remoteIP,port);
u = udp(remoteIP, port);
fopen(u);

diameter =  0.3;
color =     [255 255 0];

% concatenate into one long array for fprintf
arguments = [diameter color];

% demo code for showing four sets of dots and targets
fprintf(u,'myTarg1    = rAdd(''dXtarget'',1,''visible'',true,''diameter'',2,''penWidth'',24,''color'',[0 0 0]);');
fprintf(u,'myTarg2    = rAdd(''dXtarget'',1,''visible'',true,''diameter'',%d,''penWidth'',24,''color'',[%d %d %d]);', arguments);
fprintf(u,'dotsIdx    = rAdd(''dXdots'', 1, ''color'', [255 255 255], ''direction'',0,''coherence'',10, ''diameter'',10,''size'',floor(rGet(''dXscreen'', 1, ''pixelsPerDegree'')*0.15),''loops'',3,''density'',20,''speed'',7,''lifetimeMode'',''random'', ''visible'',false);');
fprintf(u,'rSet(''dXdots'',dotsIdx,''direction'',0,''visible'',true);');
fprintf(u,'rSet(''dXtarget'',myTarg1,''visible'',true);');
fprintf(u,'rSet(''dXtarget'',myTarg2,''visible'',true);');
fprintf(u,'draw_flag=1;');
WaitSecs(2);
fprintf(u,'draw_flag=0;');
fprintf(u,'rGraphicsBlank;');
fprintf(u,'continue_flag=false;');

fclose(u);
delete(u);
clear u;

% test string concatenation within fprintf. Works with strcat. Note space
% before string... spaces after string are stripped.
fprintf(1,strcat('hello', ...
    ' hello2', ...
    ' hello%i\n'), 4);
