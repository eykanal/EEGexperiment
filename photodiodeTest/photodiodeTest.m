function photodiodeTest( varargin )

% Initialize the USB device:
global daq;

if length(varargin) > 0
    filename = varargin(1);
else
    filename = '';
end

% close all open images
close all;

% set up box for MEG
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
    warning('photodiode:noDaqDevice','No Daq device detected. If scanning, ensure that all settings are correct.');
end

Screen('Preference','SkipSyncTests',0);
rInit({'screenMode','local','showWarnings',true});

% Identify computer based on display type
[s,w] = unix('system_profiler SPDisplaysDataType');
% First look for Mac Pro, then projector, then color LCD. Do in this order 
% because projector and LCD will probably both be present when projector
% plugged in.
if strfind(w, 'B223W')  % mac pro

    monitorWidth    = 47.5;
    viewingDistance = 63.5;

elseif strfind(w, 'LE1901w')  % MEG recording room
    
    monitorWidth    = 93;
    viewingDistance = 118;

elseif strfind(w, 'Color LCD')  % laptop w/o external
    
    monitorWidth    = 28.5;
    viewingDistance = 60;
   
else

    monitorWidth    = rGet('dXscreen', 'monitorWidth');
    viewingDistance = rGet('dXscreen', 'viewingDistance');
    
end

rSet('dXscreen', 1, 'monitorWidth',    monitorWidth);
rSet('dXscreen', 1, 'viewingDistance', viewingDistance);

% Put up the localizer dot
direction   = 0;
coherence   = 25;
diameter    = 1;
size        = 25;
loops       = 3;
density     = 20000;
speed       = 7;

localizer = rAdd( ...
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
    'recordToMEG', true ...
);

spacekey = 44;
rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);
rGraphicsBlank;
rClear;

WaitSecs(1);

% Set up actual dots
size        = floor(0.15 * rGet('dXscreen', 1, 'pixelsPerDegree'));;
direction   = 0;
coherence   = 25;
diameter    = 10;
loops       = 3;
density     = 20;
speed       = 7;

testDisplay = rAdd( ...
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

% Reset the rand state so we always get the same dots pattern
c = RandStream.create('mt19937ar');  % twister, seed 0
RandStream.setDefaultStream(c);
c.reset;

% Draw stuff
[dot_history dot_timeHistory] = rGraphicsDraw(5000);

rGraphicsBlank;

% stored upside-down; reverse the y axis
dot_history (2,:,:) = 1 - dot_history (2,:,:);
% normalize time history s.t. t_0 = 0;
dot_timeHistory = dot_timeHistory - min(dot_timeHistory);

finishedSaving = false;
while finishedSaving == false
    fname = sprintf( 'photodiodeTestData_%s.mat', filename );
    if ~exist(fname, 'file')
        save(fname, 'direction', 'coherence', 'diameter', 'size', 'loops', 'density', 'speed', 'dot_history', 'dot_timeHistory');
        finishedSaving = true;
    else
        if ~strcmp( input( sprintf( 'File exists! (%s) Overwrite? (Y/n): ', fname ), 's' ), 'n' )
            delete(fname);
            save(fname, 'direction', 'coherence', 'diameter', 'size', 'loops', 'density', 'speed', 'dot_history', 'dot_timeHistory');
            finishedSaving = true;
        else
            if ~strcmp( input( 'Save with new name? (Y/n): ', 's' ), 'n' )
                filename = input ( 'New file name: ', 's' );
            else
                finishedSaving = true;
            end
        end
    end
end

rDone;

x = -1:0.01:1;
y = sqrt(1-x.^2);

x = (x+1)/2;
y = (y+1)/2;

figure(1);
scatter(x,y);
hold on;
scatter(x,-y+1);
scatter(dot_history(1,:,1),dot_history(2,:,1));

figure(2);
plot(dot_timeHistory);

end
