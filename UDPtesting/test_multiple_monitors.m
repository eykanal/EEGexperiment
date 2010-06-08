% this code is identical to the code in test_udp_syntax, except that it
% doesn't send across a UDP connection. This is to test whether the
% multiple monitor setup at presby is causing problems.

Screen('Preference','SkipSyncTests',0)
rInit({'screenMode','local','showWarnings',true});

% some string manipulation
str{1} = 'This is my test.';
str{2} = 'Please enjoy it tremendously.';

[wn_, sr_, ppd_, fr_] = rGraphicsGetScreenAttributes;
fontsize = 30;
lnsp = -1;  

% location of string
for i = 1:length(str)
    textwidth = fontsize*length(str{i})/ppd_;
    x_pos{i} = -0.3*textwidth;
end

y = -ceil(length(str)/2):floor(length(str)/2);
if length(y)>length(str)
    y = y(1:length(str));
end
y = y*lnsp;

indices     = rAdd('dXtext', length(str), ...
    'visible', true, ...
    'x', x_pos, 'y', num2cell(y), ...
    'size', fontsize, ...
    'font', 'Courier', ...
    'bold', true, ...
    'color', [1 1 1]*255, ...
    'string', str );
rGraphicsDraw(2000);
rGraphicsBlank;

str{1} = 'Here''s some more for your viewing pleasure.';
str{2} = 'Once again, enjoy.';

rSet('dXtext',indices,'string',str,'visible',true);
rGraphicsDraw(2000);
rGraphicsBlank;

WaitSecs(1);

% show some dots
myTarg      = rAdd('dXtarget',1,'visible',false,'diameter',3.000000e-001,'penWidth',24,'color',[255 255 0]);
dotsIdx     = rAdd('dXdots', 1, 'color', [255 255 255], 'direction',0,'coherence',10, 'diameter',10,'size',floor(rGet('dXscreen', 1, 'pixelsPerDegree')*0.15),'loops',3,'density',20,'speed',7,'lifetimeMode','random', 'visible',false);
rSet('dXdots',dotsIdx,'direction',0,'visible',true);
rSet('dXtarget',myTarg,'visible',true);
rGraphicsDraw(4000,0);
rGraphicsBlank;

rDone;