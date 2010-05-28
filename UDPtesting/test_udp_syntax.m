function test_udp_syntax()

%####################
%## INITIALIZATION ##
%####################

% set up UDP messaging socket
localIP = '10.1.1.2';
remoteIP = '10.1.1.3';
port = 6665;

u = udp(remoteIP, port);
fopen(u);

% Hard-code results of rGraphicsGetScreenAttributes (run on laptop). This
% is to compensate for not running rRemoteSetup.
wn_=10;sr_=[0,0,1152,870];ppd_=32.7808;fr_=75;

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

colors = [0 128 255];

% demo code for showing four sets of dots and targets
fprintf(u,'targIdx    = rAdd(''dXtarget'',1,''visible'',false,''diameter'',%d,''penWidth'',24,''color'',[%d %d %d]);', arguments);
fprintf(u,'dotsIdx    = rAdd(''dXdots'', 1, ''color'', [255 255 255], ''direction'',0,''coherence'',10, ''diameter'',10,''size'',floor(rGet(''dXscreen'', 1, ''pixelsPerDegree'')*0.15),''loops'',3,''density'',20,''speed'',7,''lifetimeMode'',''random'', ''visible'',false);');
%fprintf(u,'disp(dotsIdx);');
%fprintf(u,'disp(targIdx);');
fprintf(u,'draw_flag=1;');
   
for n = 1:length(colors)
    fprintf(u,'rSet(''dXtarget'',targIdx,''visible'',true,''color'',[255 %d %d]);',[colors(n) colors(n)]);
    fprintf(u,'rSet(''dXdots'',dotsIdx,''direction'',0,''visible'',true);');
    fprintf(u,'draw_flag=1;');

%     % wait for response
%     val     = getvalue(parport);
%     decval  = bin2dec(num2str(val));
%     d       = decval;
%     while d == decval
%         val     = getvalue(parport);
%         decval  = bin2dec(num2str(val));
%     end
    WaitSecs(2);

    fprintf(u,'rGraphicsBlank;');
%   fprintf(u,'draw_flag=0;');
    WaitSecs(1);
end

fprintf(u,'draw_flag=0;');
fprintf(u,'rGraphicsBlank;');
fprintf(u,'continue_flag=false;');

fclose(u);
delete(u);

% test string concatenation within fprintf. Works with strcat. Note space
% before string... spaces after string are stripped.
% fprintf(1,strcat('hello', ...
%     ' hello2', ...
%     ' hello%i\n'), 4);
