% this code is identical to the code in test_udp_syntax, except that it
% doesn't send across a UDP connection. This is to test whether the
% multiple monitor setup at presby is causing problems.

Screen('Preference','SkipSyncTests',0)
rInit({'screenMode','local','showWarnings',true});

myTarg     = rAdd('dXtarget',1,'visible',false,'diameter',3.000000e-001,'penWidth',24,'color',[255 255 0]);
dotsIdx    = rAdd('dXdots', 1, 'color', [255 255 255], 'direction',0,'coherence',10, 'diameter',10,'size',floor(rGet('dXscreen', 1, 'pixelsPerDegree')*0.15),'loops',3,'density',20,'speed',7,'lifetimeMode','random', 'visible',false);
rSet('dXdots',dotsIdx,'direction',0,'visible',true);
rSet('dXtarget',myTarg,'visible',true);
rGraphicsDraw(4000,0);
rGraphicsBlank;

rDone;