%
% Initialize parallel computing
%

% put empty file in /tmp so I can check for it
ptr = fopen( '/tmp/resp.txt', 'w' );
fclose( ptr );

obj = createJob();
set( obj, 'FileDependencies', {'jobStartup.m', 'GetPadResp.m', 'KbCheckMulti.m'});  % Add psychtoolbox to worker path

daq = DaqDeviceIndex;
% if using USB device and two ports show up, use second
if length( daq ) > 1
    daq = daq(2);

% if empty, no daq, define as -1 so KbCheckMulti works correctly
elseif isempty( daq )
    daq = -1;
end

task = createTask(obj, @GetPadResp, 1, {daq});

%
% Initialize DotsX
%
    
% init Screen
Screen('Preference','SkipSyncTests',0);
rInit({'screenMode','local','showWarnings',true});

% create the dots object, same as I do in experiment_eeg.m
ppd_ = rGet('dXscreen', 1, 'pixelsPerDegree');

contrast_factor = 1;        % The percentage of 256 for color saturation (0.1 used in fixed-viewing version)
blank_time = 1000;          % 1000 msec blank time at the end
pix_degree_size = 0.15;     % This sets pixels to .15 degrees visual angle for a given screen
aperture_diam = 10;         % Degrees covered by aperture
target_diam = 0.3;          % Degrees covered by target
black_annulus_diam = 2;     % A black target behind the visible target for preventing dot-tracking at fixation
density = 20;               % dots/degree^2 Downing-Movshon says dots/degree^2/sec -- I don't get why sec is relevant
speed = 7;                  % Dot-speed in deg/sec
loops = 3;                  % A low-level drawing feature of DotsX code
motion_dur = 500;           % Motion stimulus duration in msec (fixed viewing time)
pixelsize = floor(pix_degree_size * ppd_);

blackTargetIdx  = rAdd( ...
    'dXtarget', 1, ...
    'color',    contrast_factor*[0 0 0], ...
    'penWidth', 24, ...
    'diameter', black_annulus_diam, ...
    'visible',  false);
targetIdx       = rAdd( ...
    'dXtarget', 1, ...
    'color',    contrast_factor*[255 255 255], ...
    'penWidth', 24, ...
    'diameter', target_diam, ...
    'visible',  false);
dotsIdx         = rAdd( ...
    'dXdots',   1, ...
    'color',    contrast_factor*[255 255 255], ...
    'direction',0, ...
    'coherence',15, ...
    'diameter', aperture_diam, ...
    'size',     pixelsize, ...
    'loops',    loops, ...
    'density',  density, ...
    'speed',    speed, ...
    'lifetimeMode', 'random', ...
    'visible',  false);
triangleIdx     = rAdd( ...
    'dXpolygon',1, ...
    'visible',  false, ...
    'color',    contrast_factor*[255 255 255], ...
    'pointList',0.65*target_diam*[-1 1; 1 1; 0 -1]);

% run threads & draw stuff
submit(obj);                   % Submit the job
waitForState(task,'running');  % Wait for the task to start running

rGraphicsBlank;
rSet('dXtarget', targetIdx, 'visible', true);  % fixation is always visible

beginTime = GetSecs;

while GetSecs - beginTime < 10

    rSet('dXtarget', targetIdx,      'color',  [0 255 0]);
    rSet('dXtarget', targetIdx,      'visible',true);
    rGraphicsDraw;
    WaitSecs(1);

    rSet('dXtarget', targetIdx,      'color',  [255 255 255]);
    rSet('dXdots',   dotsIdx,        'visible',true);
    rSet('dXtarget', blackTargetIdx, 'visible',true);

    [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti( inf, [] );

    rSet('dXdots',   dotsIdx,        'visible', false);
    rSet('dXtarget', blackTargetIdx, 'visible', false);
    rGraphicsDraw;

end

destroy(obj);

rDone;
rClear;

