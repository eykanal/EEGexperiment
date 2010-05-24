%####################
%## INITIALIZATION ##
%####################

% set up UDP messaging socket
localIP = '10.1.1.3';
remoteIP = '10.1.1.2';
port = 6665;

u = udp(remoteIP, port);
fopen(u);

% set up response collection 
parport = digitalio('parallel','LPT1');
hwlines = addline(parport,0:7,0,'out');
hwlines = addline(parport,0:4,1,'in');
hwlines = addline(parport,0:3,2,'in');
% set line value to 0 at start
putvalue(parport.Line(1:8), 0);


%#####################
%## MAIN EXPERIMENT ##
%#####################

% set vars
diameter =  0.3;
color =     [255 255 0];

% concatenate into one long array for fprintf
arguments = [diameter color];

% demo code for showing four sets of dots and targets
fprintf(u,'myTarg2    = rAdd(''dXtarget'',1,''visible'',true,''diameter'',%d,''penWidth'',24,''color'',[%d %d %d]);', arguments);
fprintf(u,'dotsIdx    = rAdd(''dXdots'', 1, ''color'', [255 255 255], ''direction'',0,''coherence'',10, ''diameter'',10,''size'',floor(rGet(''dXscreen'', 1, ''pixelsPerDegree'')*0.15),''loops'',3,''density'',20,''speed'',7,''lifetimeMode'',''random'', ''visible'',false);');
fprintf(u,'rSet(''dXdots'',dotsIdx,''direction'',0,''visible'',true);');
fprintf(u,'rSet(''dXtarget'',myTarg1,''visible'',true);');
fprintf(u,'rSet(''dXtarget'',myTarg2,''visible'',true);');
fprintf(u,'draw_flag=1;');

% wait for response
val     = getvalue(parport);
decval  = bin2dec(num2str(val));
d       = decval %debug - print value from line

while d == decval
    val     = getvalue(parport);
    decval  = bin2dec(num2str(val));
end

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
