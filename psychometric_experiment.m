function money = psychometric_experiment (subject)
% function money = psychometric_experiment( subject )
%
% Find the psychometric function for this participant

% Before doing anything, let the user confirm that this subject number
% is the right one:
fprintf( 1, '\n The following information relating to subject %d currently exists: \n\n', subject );
% Read in all the files related to subject:
d = dir;
indices = strmatch( sprintf( 'subject%d_', subject ), { d(:).name } );
if isempty( indices )
  fprintf( 1, 'New subject: no files related to subject %d in the directory. \n\n', subject );
else
  for i = 1 : length(indices)
    fprintf( 1, '%s\t\t%s\n', d(indices(i)).name, d(indices(i)).date );
  end
end
continue_response = input( '\nContinue? Type ''y'' if yes, ''n'' if no.\n', 's' );
if strcmp( continue_response, 'y' ) ~= 1
  return
end

salary = 1;		%money earned by subjects for correct decision [in cents]
keys = [KbName('Z'),KbName('M')];	%keys used for responses
%blockdur = 50;		%number of trials per coherence
blockdur = 90;

numblocks = 1;
% checking existence of the datafile
SessionsCompleted = 0;
filename = sprintf ('subject%d_psychomses%d.mat', subject, SessionsCompleted + 1);
fid = fopen (filename, 'r');
if fid ~= -1
  fclose (fid);
  disp ('File with the data for this subject already exists. Do you want to replace it (y/n)');
  answer = GetChar;
  if answer == 'n' | answer == 'N'
    disp ('So please run function experiment with another subject number');
    return
  end
end

lkey = keys(1);
hkey = keys(2);
rand ('state', sum(100*clock));
randn ('state', sum(100*clock));


% Initialize the USB device:
devices = PsychHID('Devices');
daq = DaqDeviceIndex;

rInit('local'); % 7/16/07 -- shifting to DotsX code

wdwPtr = rWinPtr;

% 7/17/07: A bunch of PTB sound manipulation code needs to be initialized:
% Perform basic initialization of the sound driver:
fprintf('initializing sound...\n');
InitializePsychSound;
% Read WAV file from filesystem:
[y, freq, nbits] = wavread('SOUND16');
wavedata = y';
nrchannels = size(wavedata,1); % Number of rows == number of channels.

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
pahandle_correct = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', pahandle_correct, wavedata);


% Now open a channel for the anticipatory error sound:
[y, freq, nbits] = wavread('errorsound');
wavedata = y';
nrchannels = size(wavedata,1); % Number of rows == number of channels.

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
pahandle_antic = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', pahandle_antic, wavedata);


% Dots features from motion_localizer_translational.m:
ppd_ = rGet('dXscreen', 1, 'pixelsPerDegree');
contrast_factor = 1;   % The percentage of 256 for color saturation (0.1 used in fixed-viewing version)
blank_time = 1000;      % 1000 msec blank time at the end
pix_degree_size = 0.15;  % This sets pixels to .15 degrees visual angle for a given screen
aperture_diam = 25;     % Degrees covered by aperture
aperture_diam = 10;
target_diam = 0.3;      % Degrees covered by target
black_annulus_diam = 2;     % A black target behind the visible target for preventing dot-tracking at fixation
pixelsize = floor(pix_degree_size * ppd_);
density = 20;           % dots/degree^2 Downing-Movshon says dots/degree^2/sec -- I don't get why sec is relevant
speed = 7;              % Dot-speed in deg/sec
loops = 3;              % A low-level drawing feature of DotsX code
motion_dur = 500;       % Motion stimulus duration in msec (fixed viewing time)

blackTargetIdx = rAdd('dXtarget', 1, 'color', contrast_factor*[0 0 0],'penWidth',24,'diameter',black_annulus_diam,'visible',false);
% add some dots and a target
targetIdx = rAdd('dXtarget', 1, 'color', contrast_factor*[255 255 255],'penWidth',24,'diameter',target_diam,'visible',false);
dotsIdx = rAdd('dXdots', 1, 'color', contrast_factor*[255 255 255], 'direction',0,'coherence',7, 'diameter',aperture_diam,'size',pixelsize,'loops',loops,'density',density,'speed',speed,'lifetimeMode','random', 'visible',false);


fontsize = 20;
font_degrees = 0.7;
score = 0;
str = sprintf ('Score: %d', score);
%     textwidth = fontsize*length(str)/ppd_;
textwidth = font_degrees*length(str);
x_pos = -0.3*textwidth;
textIdx_Score = rAdd('dXtext', 1, 'visible', false, 'x', x_pos, 'y', 0, 'size', floor(font_degrees*ppd_), 'font', 'Courier', 'color', contrast_factor*[1 1 1]*255, 'string', str);




RT = []; ST =[]; ST_time = []; ER = []; RDir = []; blocknum = [];
trialnum = []; allCoh = [];
bl = 1;

welcome_quest;


money = 0;
coherenceVec = [2.5 5 12.5 25 50];
coherenceVec = [2.5 5 8 12.5 25];
RSI = 1; % response-stimulus interval (fixed for quest blocks)
PIconst = 0.5; % bias is fixed to 0.5 (no bias)
feedback_flags = ones(numblocks,1); %always give feedback


for bl = 1:numblocks
  if bl > 1
    resting_arrow (numblocks -bl, money,'d' );
  end
  [STbl, ST_timebl, RTbl, ERbl, RDirbl, PiDirbl, SubScore, score, premie_t,premie_d,trialCoh] = ...
      psychometric_block (RSI,5,coherenceVec, blockdur, dotsIdx,targetIdx,blackTargetIdx,textIdx_Score,lkey, hkey, PIconst, feedback_flags(bl), salary, wdwPtr,pahandle_correct, pahandle_antic, daq);
  ib = length(RT) + 1;		%index of the begining of inserted block
  ie = length(RT) + length(RTbl);	%index of the end of inserted block
  ST(ib:ie) = STbl;
  ST_time(ib:ie) = ST_timebl;
  RT(ib:ie) = RTbl;
  ER(ib:ie) = ERbl;
  RDir(ib:ie) = RDirbl;
  blocknum(ib:ie) = bl;
  trialnum(ib:ie) = 1:length(RTbl);
  D(ib:ie) = RSI;
  PI(ib:ie) = PIconst;
  PiDir(ib:ie) = PiDirbl;
  allCoh(ib:ie) = trialCoh;
  Feed(ib:ie) = feedback_flags(bl);
  % 9/19/05: Keeping track of premature responses with an array of cell arrays of time & direction vectors:
  Premie_t(ib:ie) = premie_t;
  Premie_d(ib:ie) = premie_d;	
  money = money + score * salary;
  save (filename, 'ST', 'ST_time', 'RT', 'ER', 'RDir', 'blocknum', 'trialnum','D', 'PI', 'PiDir', 'SubScore', 'money','allCoh','numblocks');

end


thankyou (money, 10);
