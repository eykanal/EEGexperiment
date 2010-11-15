% Initialize the USB device:
global daq;

close all;

devices = PsychHID('Devices');
daq = DaqDeviceIndex;

if daq > 0
    % fix for macbook bug
    if length(daq) > 1
        daq = 4;
    end
    errA = DaqDConfigPort(daq, 0, 0);   % Port A will send data out
    errB = DaqDConfigPort(daq, 1, 1);   % Port B will receive data
else
    error('Please plug in the Daq device!');
end

Screen('Preference','SkipSyncTests',0);
rInit({'screenMode','local','showWarnings',true});

direction   = 0;
coherence   = 25;
diameter    = 10;
size        = 5;
loops       = 1;
density     = 20;
speed       = 7;

dotsIdx         = rAdd( ...
    'dXdots',   1, ...
    'color',    [255 255 255], ...
    'direction',direction, ...
    'coherence',coherence, ...
    'diameter', diameter, ...
    'size',     size, ...
    'loops',    loops, ...
    'density',  density, ...
    'speed',    speed, ...
    'lifetimeMode', 'random', ...
    'visible',  true, ...
    'debugSavePts', true, ...
    'recordToMEG', true ...
);

dot_history = rGraphicsDraw(5000);

% stored upside-down; reverse the y axis
dot_history (2,:,:) = 1 - dot_history (2,:,:);
save('photodiodeTestData.mat','direction', 'coherence', 'diameter', 'size', 'loops', 'density', 'speed', 'dot_history');

rDone;

x = -1:0.01:1;
y = sqrt(1-x.^2);

x = (x+1)/2;
y = (y+1)/2;

figure(1);
scatter(x,y);
hold on;
scatter(x,-y+1);

% scatter(a(1,:,time),a(2,:,time)) plots all points for a given frame
