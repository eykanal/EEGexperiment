function money = experiment_bias (subject,isBehavioral,coh,runSD)
% function money = experiment_bias (subject,isBehavioral,coh,runSD)
% run an experiment in EEG that examines the effect of bias and RSI
% on behavioral and brain activity
% INPUT Args:
% subject = 1            ; subject index
% isBehavioral = 1       ; whether this is a behavioral or EEG
% session
% coh = 8                ; coherence value used for the trials
% runSD = 1              ; whether to run the signal detection trials
% OUTPUT Args:
% money                  ; how much money the participant made

%% initialize the random seed
rand('state',sum(100*clock)); % resets generator to a new state
randn('state',sum(100*clock)); % resets generator to a new state

% Default to EEG settings if no behavioral flag set in the input params:
if nargin < 2
    isBehavioral = 0;
    runSD = 1;
end

if ~exist('runSD','var')
  runSD = 1;
end

debugMode = 0; %whether to run in debug mode (when set to 1, the
               %expt will be run in debug mode, with very short blocks)

% Before doing anything, let the user confirm that this subject number is
% the right one:
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
user_comment = input('\nDo you want to enter a comment on this run? Answer will be saved as a string. Press return if no comment desired.\n','s');

continue_response = input( '\nContinue? Type ''y'' if yes, ''n'' if no.\n', 's' );
if strcmp( continue_response, 'y' ) ~= 1
  return
end

% increment the filename number based on what previous files are
% there
SessionsCompleted=0;
filename='foo';
while SessionsCompleted < 1 || exist(filename,'file') 
  SessionsCompleted=SessionsCompleted+1;
  filename = sprintf ('subject%d_ses%d.mat', subject,SessionsCompleted);
end

doQuest = 1;
if ~isBehavioral
  doQuest = 0; % whether to do the coherence setting stuff
end
if ~doQuest
  if ~exist('coh','var') 
    fprintf('please call this experiment with a coherence value\n');
    return
  end
end
if ~exist('coh','var') | isBehavioral
  coh = 15;
end

fid = fopen( sprintf('subject%d_order.mat', subject) );
if fid == -1
  subj_order_file = sprintf( 'subject%d_order', subject );
  SessionsCompleted = 0;
else
  fclose( fid );
  subj_order_file = sprintf( 'subject%d_order', subject );
  load( subj_order_file );
end

RSI_poss = [1 2];
% in the first 3 sessions, set no bias
if SessionsCompleted < 3 & isBehavioral
  pi_poss = [0.5 0.5 0.5 0.5];
else
  pi_poss = [0.5 0.6 0.75 0.9];
end
Shape_poss = [5 10 ];   % Gamma pdf shape parameter for individual RSI (scale = mean/shape)

if isBehavioral
  salary = 1.5;%money earned by subjects for correct decision [in cents]
else
  salary = 1;
end
salary_sd = 0.5;
money_psych = 0;
money = 0;

% 10/27/08: Now using behavioral keys:
keys = [ KbName('Z'), KbName('M') ];

if isBehavioral
  blockdur = 240;	%duration of a single block in seconds (4 min for Behavioral)
  waitdur = 30;       % Should not be relevant for Behavioral sessions
  if debugMode
    blockdur = 12;
    waitdur = 10;
  end
else  
  blockdur = 240; 
  waitdur = 30;   % 30 second blank period
  if debugMode
    blockdur = 12;
    waitdur = 10;
  end
end


lkey = keys(1);
rkey = keys(2);

% Initialize the USB device:
devices = PsychHID('Devices');
daq = DaqDeviceIndex;

% % If you want to run this without the USB device, set daq to -1:
if isBehavioral
  daq = -1;
end

Screen('Preference','SkipSyncTests',0)
rInit({'screenMode','local','showWarnings',true});

% 7/19/08: need access to the window pointer for freeze-framing dots.
wdwPtr = rWinPtr;


% 7/17/07: A bunch of PTB sound manipulation code needs to be initialized:
% Perform basic initialization of the sound driver:
InitializePsychSound;
% Read WAV file from filesystem:
% [y, freq, nbits] = wavread(wavfilename);
expdir = fileparts(which('experiment_eeg.m'));
[y, freq, nbits] = wavread(fullfile(expdir,'SOUND16'));
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
[y, freq, nbits] = wavread(fullfile(expdir,'errorsound'));
wavedata = y';
nrchannels = size(wavedata,1); % Number of rows == number of channels.

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
pahandle_antic = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', pahandle_antic, wavedata);


% Also initialize the KbCheck routine:
KbCheckMulti;                   % Initialize keyboard check routine
triggercode = KbName('1!');     % This actually needs to change to '!' for true scanner triggering
triggercode = KbName('LEFTSHIFT');  % Nope, LEFTSHIFT instead of !

RT = [];
bl = 1;
score = 0;
ppd_ = rGet('dXscreen', 1, 'pixelsPerDegree');

% Dots features from motion_localizer_translational.m:
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


% The black target imitates the annulus idea in the Kastner lab motion
% localizer code, presumably to prevent tracking of individual dots
% that move through the fixation point.
blackTargetIdx = rAdd('dXtarget', 1, 'color', contrast_factor*[0 0 0],'penWidth',24,'diameter',black_annulus_diam,'visible',false);
% add some dots and a target
targetIdx = rAdd('dXtarget', 1, 'color', contrast_factor*[255 255 255],'penWidth',24,'diameter',target_diam,'visible',false);
dotsIdx = rAdd('dXdots', 1, 'color', contrast_factor*[255 255 255], 'direction',0,'coherence',coh, 'diameter',aperture_diam,'size',pixelsize,'loops',loops,'density',density,'speed',speed,'lifetimeMode','random', 'visible',false);
triangleIdx = rAdd('dXpolygon', 1, 'visible', false, ...
        'color', contrast_factor*[255 255 255], ...
        'pointList', 0.65*target_diam*[-1 1; 1 1; 0 -1]);

fontsize = 20;
font_degrees = 0.7;
str = sprintf ('Score: %d', score);
textwidth = font_degrees*length(str);
x_pos = -0.3*textwidth;
textIdx_Score = rAdd('dXtext', 1, 'visible', false, 'x', x_pos, 'y', 0, 'size', floor(font_degrees*ppd_), 'font', 'Courier', 'color', contrast_factor*[1 1 1]*255, 'string', str);

if doQuest
  welcome_quest;
end

% do a quest block to establish the correct coherence
tmp_coherence = 15; % coherence is irrelevant because it will be
                   % varied in the quest blocks--left in for consistency
RSIconst = 1; % response-stimulus interval (fixed for quest blocks)
PIconst = 0.5; % bias is fixed to 0.5 (no bias)
% 80 psych trials take about 17 minutes
if debugMode
  NpsychTrials = 5;
else
  NpsychTrials = 80;
end

if doQuest
  if SessionsCompleted==0
    coherVec = [2.5 5 8 12.5 25];
  else
    coherVec = [1.5 2.5 5 8 12.5];
  end
  % use a psychometric block instead of a quest block
  [STpsych,ST_timePsych,RTpsych,ERpsych,RDirPsych,PiDirPsych, ...
   SubScore,score,premie_t,premie_e,coherenceVec,lowCoh,highCoh,params,cdf_type] = psychometric_block(RSIconst,Shape_poss(1),coherVec,NpsychTrials,dotsIdx,targetIdx,blackTargetIdx,textIdx_Score,lkey, rkey,  PIconst, 1, salary,wdwPtr,pahandle_correct, pahandle_antic, daq);
   
  % use params to estimate the 80% correct level
  switch cdf_type
   case 1
    coh80perc = (norminv(0.8)-params(2))/params(1);
   case 2
    coh80perc = wblinv(0.8,params(1),params(2));
   case 3
    coh80perc = gaminv(0.8,params(1),params(2));
  end %switch
  % if totally screwed up, leave coherence at a fixed value
  if (coh80perc < coh) & (coh80perc > 0)
    coh = coh80perc;
  end
  save (filename, 'blank_time', 'pix_degree_size', 'aperture_diam','pixelsize','target_diam','black_annulus_diam','ppd_','density','speed','loops','waitdur','blockdur','coh','STpsych','ST_timePsych','RTpsych','ERpsych','RDirPsych','PiDirPsych','coherenceVec','RSI_poss','Shape_poss');   
  money_psych = sum(~ERpsych);
  money = money + money_psych*salary;
end




RSIs = [ RSI_poss(1) RSI_poss(1) RSI_poss(1) RSI_poss(1) RSI_poss(2) RSI_poss(2) RSI_poss(2) RSI_poss(2); RSI_poss(2) RSI_poss(2) RSI_poss(2) RSI_poss(2) RSI_poss(1) RSI_poss(1) RSI_poss(1) RSI_poss(1) ];
Shapes = [ Shape_poss(1) Shape_poss(2) Shape_poss(2) Shape_poss(1) Shape_poss(2) Shape_poss(1) Shape_poss(1) Shape_poss(2); ...
    Shape_poss(2) Shape_poss(1) Shape_poss(1) Shape_poss(2) Shape_poss(1) Shape_poss(2) Shape_poss(2) Shape_poss(1) ];
PIs = [pi_poss(3) pi_poss(1) pi_poss(2) pi_poss(4) pi_poss(2) pi_poss(3) pi_poss(4) pi_poss(1); pi_poss(3) pi_poss(1) pi_poss(2) pi_poss(4) pi_poss(4) pi_poss(2) pi_poss(3) pi_poss(1)];
Cues = [ 'd' 'd' 'd' 'd' 'd' 'd' 'd' 'd'; ...
    'd' 'd' 'd' 'd' 'd' 'd' 'd' 'd' ];  
coherence_array = coh; %we keep coherence_array for consistency
                       %with previous experiments


welcome_main;

fontsize = 20;
font_degrees = 0.7;

str = {'Press a button to start,','then fixate on the central circle'};
textwidth = font_degrees*length(str);
x_pos = {-0.3*textwidth -0.3*textwidth};
textIdx_Start = rAdd('dXtext', 2, 'visible', true, ...
    'x', x_pos, 'y', {1 0}, ...
    'size', floor(font_degrees*ppd_), ...
    'font', 'Courier',  ...
    'color', [1 1 1]*255, ...
    'string', str);
rGraphicsDrawMulti(inf);
rSet('dXtext',textIdx_Start,'visible',false);
while KbCheckMulti; end
rGraphicsDraw;

% Decide on the random order of the conditions
% Now just pick a value of 1 or 2 for each of these features:
RSI_row = floor(rand(1)+1.5);
pi_row = floor(rand(1)+1.5);

% The next lines isolate one row from the above data structures. These can
% be indexed by the block-number in the main experiment loop below.
RSI = RSIs(RSI_row,:)
Shape = Shapes(RSI_row,:);
bias = PIs(pi_row,:)
numblocks = length(RSI);

% check why we do not get the bias to be constant-- found 

for bl = 1 : numblocks
  resting_arrow(numblocks - bl + 1, money,'d' );
    
  [STbl, irrelDirbl, ST_timebl,RTbl, ERbl, RDirbl, PiDirbl, score, premie_t,premie_d] = block_bias(RSI(bl), RSI_poss,Shape(bl), bias(bl),coh,blockdur,dotsIdx, targetIdx, triangleIdx,blackTargetIdx, textIdx_Score, ppd_, lkey,rkey, money, salary,wdwPtr, pahandle_correct, pahandle_antic, daq,contrast_factor);
  ib = length(RT) + 1;%index of the begining of inserted block
  ie = length(RT) + length(RTbl);	%index of the end of inserted block
  ST(ib:ie) = STbl;
  ST_time(ib:ie) = ST_timebl;
  shapeVec(ib:ie) = Shape(bl);
  cohVec(ib:ie) = coh;
  cueVec(ib:ie) = 'd';
  pi_vec(ib:ie) = bias(bl);
  RT(ib:ie) = RTbl;
  ER(ib:ie) = ERbl;
  RDir(ib:ie) = RDirbl;
  PiDir(ib:ie) = PiDirbl;
  blocknum(ib:ie) = bl;
  trialnum(ib:ie) = 1:length(RTbl);
  D(ib:ie) = RSI(bl);
  PiDir(ib:ie) = PiDirbl; 
  money = money + score * salary;    
  
  % save the data
  if doQuest
    save (filename,'ST', 'ST_time','RT', 'ER', 'RDir', 'blocknum', 'trialnum','D', 'cohVec','PiDir','pi_vec','cueVec','shapeVec','PiDir', 'money','contrast_factor','blank_time', 'pix_degree_size', 'aperture_diam','pixelsize', 'target_diam','black_annulus_diam','ppd_','density','speed','loops','waitdur','blockdur','numblocks','STpsych','ST_timePsych','RTpsych','ERpsych','RDirPsych','PiDirPsych','coh','RSI_poss','Shape_poss','coherence_array','coherenceVec');     
  else
    save (filename, 'ST', 'ST_time','RT', 'ER', 'RDir', 'blocknum', 'trialnum','D', 'cohVec','PiDir','pi_vec','cueVec','shapeVec', 'PiDir', 'money', 'contrast_factor','blank_time', 'pix_degree_size', 'aperture_diam','pixelsize','target_diam','black_annulus_diam','ppd_','density','speed','loops','waitdur','blockdur','numblocks','coh','RSI_poss','Shape_poss','coherence_array');    
  end
  
end



if runSD
  resting (2, money);

  % Now add in two blocks that test signal detection speed, each of 2.5 minutes
  % (leading to a total experiment time of 90 minutes):
  sig_det_instruction(salary_sd);
  sig_det_resting( 2, money, 'Left' );

  SDdur = 120;
  [Left_ST, Left_ST_time, Left_RT, Left_ER, score1, Left_premie_t, Left_premie_d] = sig_det_block(RSI_poss(1), Shape_poss(1), coherence_array(1), SDdur, 'Left',dotsIdx, targetIdx, blackTargetIdx, textIdx_Score, ppd_, lkey, rkey, money, salary_sd,pahandle_correct, pahandle_antic, daq,contrast_factor);
  money = money + score1 * salary_sd;

  sig_det_resting(1,money,'Right');
  [Right_ST, Right_ST_time, Right_RT, Right_ER, score2, Right_premie_t, Right_premie_d] = sig_det_block(RSI_poss(1), Shape_poss(1), coherence_array(1), SDdur, 'Right',dotsIdx, targetIdx, blackTargetIdx, textIdx_Score, ppd_, lkey, rkey, money, salary_sd,pahandle_correct, pahandle_antic, daq,contrast_factor);

  money = money + score2 * salary_sd ;

  %Finishing the experiment
  if doQuest
    save (filename,'ST', 'ST_time', 'RT', 'ER', 'RDir', 'blocknum', 'trialnum','D','PiDir', 'money','Left_ST', 'Left_ST_time', 'Left_RT', 'Left_ER', 'Left_premie_t','cohVec','pi_vec','cueVec','shapeVec','Left_premie_d','Right_ST', 'Right_ST_time', 'Right_RT', 'Right_ER', 'Right_premie_t', 'Right_premie_d', 'contrast_factor','blank_time', 'pix_degree_size', 'aperture_diam','pixelsize', 'target_diam','black_annulus_diam','ppd_','density','speed','loops', 'waitdur','blockdur','numblocks','STpsych','ST_timePsych','RTpsych','ERpsych','RDirPsych','PiDirPsych','coherence_array','RSI_poss','Shape_poss','coherenceVec','salary_sd');
  else
    save (filename,'ST', 'ST_time', 'RT', 'ER', 'RDir', 'blocknum', 'trialnum', 'D', 'PiDir','pi_vec','cohVec','cueVec','shapeVec','money', 'Left_ST', 'Left_ST_time', 'Left_RT', 'Left_ER', 'Left_premie_t', 'Left_premie_d', 'Right_ST', 'Right_ST_time', 'Right_RT', 'Right_ER', 'Right_premie_t', 'Right_premie_d', 'contrast_factor','blank_time', 'pix_degree_size', 'aperture_diam','pixelsize','target_diam','black_annulus_diam','ppd_','density','speed','loops','waitdur','blockdur','numblocks','coherence_array','RSI_poss','Shape_poss','salary_sd');  
  end
end

rSet('dXdots',dotsIdx,'visible',false);
rSet('dXtarget',targetIdx,'visible',false);
rSet('dXtarget',blackTargetIdx,'visible',false);
rGraphicsDraw;
if runSD
  thankyou (money, score1+score2);
else
  thankyou(money);
end


% Now update the subject order file. By doing this at the end of the
% experiment, interrupted sessions are totally ignored, both from the
% perspective of the individual subject's order file and for the master
% order file that enables counterbalancing of conditions across subjects
% and sessions. This means that starting an interrupted session over
% again will repeat the block ordering for the subject. Assuming that
% interruptions typically happen early in the session because the
% experimenter realized he/she made a mistake, this is not too problematic.
% But if a power failure happens near the end of a session, they will get
% exactly the same ordering the next time they do the session -- but in
% that case, the subject will almost certainly want to come back on
% another day and will hopefully forget the ordering, so this seems the
% best solution for the problem of interruptions.
SessionsCompleted = SessionsCompleted + 1;
save( subj_order_file, 'SessionsCompleted' );

rDone;
% Close the audio device:
PsychPortAudio('Close', pahandle_correct);
PsychPortAudio('Close', pahandle_antic);

return
