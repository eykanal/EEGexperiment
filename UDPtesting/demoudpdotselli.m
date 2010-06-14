% set up UDP messaging socket
localIP = '169.254.154.1';
remoteIP = '169.254.214.8';
port = 6665;
socketTag = matlabUDP('open',localIP,remoteIP,port);

% demo code for showing four sets of dots and targets
sendMsg('myTarg1    = rAdd(''dXtarget'',1,''visible'',true,''diameter'',2,''penWidth'',24,''color'',[0 0 0]);');
sendMsg('myTarg2    = rAdd(''dXtarget'',1,''visible'',true,''diameter'',0.3,''penWidth'',24,''color'',[0 0 0]);');
sendMsg('dotsIdx    = rAdd(''dXdots'', 1, ''color'', [255 255 255], ''direction'',0,''coherence'',10, ''diameter'',10,''size'',floor(rGet(''dXscreen'', 1, ''pixelsPerDegree'')*0.15),''loops'',3,''density'',20,''speed'',7,''lifetimeMode'',''random'', ''visible'',false);');
sendMsg('draw_flag=1;');
sendMsg('dotsIdx');
sendMsg('rSet(''dXdots'',1,''direction'',''visible'',true);');
WaitSecs(4);
sendMsg('draw_flag=0;');
sendMsg('rGraphicsBlank;');
sendMsg('continue_flag=false;');

socketTag = matlabUDP('close');
