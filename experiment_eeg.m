function money = experiment_eeg (subject,Behavioral,coherence_array,RTfile)

% function money = experiment_eeg (subject,Behavioral,lowCoh,highCoh,RTfile)
%
% The low and high coherence inputs are only required for EEG
% sessions--in behavioral sessions the low and high coherence will
% be determined from the psychometric session.
%
% Each trial consists of the onset of a moving dots stimulus, followed by
% freezing. There will always be a fixation point in the middle. As soon as
% the dots stop moving, the participant is supposed to press a right or
% left button indicating whether right or left motion was observed. If they
% are correct, the fixation circle turns Green; if they are incorrect, it
% turns Red.
%
% After every miniblock, the total score (number correct) is displayed in
% the center of the screen.
%

cd(sprintf('~/Documents/MATLAB/EEGExperiment/data/subj%i/', subject));

%#################################
%####                         ####
%#### INITIALIZATION ROUTINES ####
%####                         ####
%#################################

% Default to fMRI settings if no behavioral flag set in the input params:
if nargin < 2
    Behavioral = 0;
end

% Before doing anything, let the user confirm that this subject number is the right one:
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

% increment the filename number based on what previous files are there
SessionsCompleted = 0;
filename = 'foo';
% check for both regular sessions (that won't have the "_\d" appended) and
% MEG sessions
while SessionsCompleted < 1 || exist(strcat(filename, '.mat'),'file') || exist(strcat(filename, '_1.mat'),'file')
    SessionsCompleted = SessionsCompleted + 1;
    filename = sprintf ('subject%d_ses%d', subject, SessionsCompleted);
end
filename = strcat( filename, '.mat' );

% set coherence_array to always be a three-length vector
if ~exist('coherence_array','var')
    coherence_array = zeros(1,3);
elseif length(coherence_array) == 2
    coherence_array = [coherence_array(1) 0 coherence_array(3)];
end

if ~Behavioral
    % flag to skip coherence setting routine
    doQuest = 0; 
  
    % if not behavioral, experiment must be called with coherence values
    if ~exist('coherence_array','var') || length(coherence_array) ~= 3
        fprintf('Please call this experiment with a 2- or 3-entry coherence vector\n');
        return
    end
    
    numRuns = 5;    % number of runs
    blockdur = 120; % 2-minute blocks (for fMRI/EEG)
    waitdur = 30;   % 30 second blank period

% if behavioral, check if coherences provided... if not, set to defaults
else
    % flag to execute coherence setting routine
    doQuest = 1; 

    numRuns = 1;    % number of runs
	blockdur = 240; % duration of a single block in seconds (4 min for Behavioral)
    waitdur = 30;   % 30 second blank period

end

% load number of sessions completed
fid = fopen( sprintf('subject%d_order.mat', subject) );
if fid == -1
    subj_order_file = sprintf( 'subject%d_order', subject );
    SessionsCompleted = 0;
else
    fclose( fid );
    subj_order_file = sprintf( 'subject%d_order', subject );
    load( subj_order_file );
end

% In this experiment, we're covarying (1) two RSI levels, (2) two motion
% coherence levels, and (3) two trial types (1: normal dot-motion
% discrimination; 2: cued-response with a salient arrow cue, dot-motion is
% irrelevant)
RSI_poss   = [ 2 2  ];  % Mean RSI ("poss" means possibility)
Shape_poss = [ 10 10 ];  % Gamma pdf shape parameter for individual RSI
                        % (scale = mean/shape)

if exist('RTfile','var') % Check to make sure there IS an RTfile
    load(RTfile);
    % RTfile contains:
    % RT_t     D_t  CueType_t   TrialCoh_t
    RT_struct.fast_arrow_RT = RT_t(find(D_t==RSI_poss(1) & CueType_t=='a'));
    if ~isempty(find(D_t==RSI_poss(2)))
        RT_struct.slow_arrow_RT = RT_t(find(D_t==RSI_poss(2) & CueType_t=='a'));
    else
        RT_struct.slow_arrow_RT = RT_struct.fast_arrow_RT; 
    end
    
    % This collapses over coherence during arrow trials, which is likely to
    % be 0, although it was not for some of my own behavioral
    % sessions.
    
    % I have set the low coherence to 0 and the high coherence to 1

    RT_struct.fast_low_dots_RT  = RT_t(find(D_t==RSI_poss(1) & CueType_t=='d' & TrialCoh_t==0));
    RT_struct.fast_high_dots_RT = RT_t(find(D_t==RSI_poss(1) & CueType_t=='d' & TrialCoh_t==1));

    RT_struct.slow_low_dots_RT  = RT_t(find(D_t==RSI_poss(2) & CueType_t=='d' & TrialCoh_t==0));
    RT_struct.slow_high_dots_RT = RT_t(find(D_t==RSI_poss(2) & CueType_t=='d' & TrialCoh_t==1));

else
    % Make fake data using a gamma distribution with mean decision time
    % = 800 msec, and mean signal detection time = 300 msec:
    RT_struct.fast_arrow_RT = normrnd(0.35,0.05*ones(1,1000));
    RT_struct.slow_arrow_RT = normrnd(0.35,0.05*ones(1,1000));

    % This collapses over coherence during arrow trials, which is likely to
    % be 0, although it was not for some of my own behavioral sessions.
    RT_shape = 5;
    RT_scale = 0.8/5;

    RT_struct.fast_low_dots_RT  = gamrnd(RT_shape,RT_scale*ones(1,1000));
    RT_struct.fast_high_dots_RT = gamrnd(RT_shape,RT_scale*ones(1,1000));

    RT_struct.slow_low_dots_RT  = gamrnd(RT_shape,RT_scale*ones(1,1000));
    RT_struct.slow_high_dots_RT = gamrnd(RT_shape,RT_scale*ones(1,1000));
end

% money earned by subjects for correct decision [in cents]
salary      = 1;    
money_psych = 0;

% Response keys:
keys = [ KbName('Z'), KbName('M') ];
lkey = keys(1);
rkey = keys(2);

global daq;

% Initialize the USB device:
devices = PsychHID('Devices');
daq = DaqDeviceIndex;

% if running an experiment using the USB box
if ~isempty( daq )
    
    % fix for macbook "bug" (has two output ports, use the second one)
    if length(daq) > 1
        daq = daq(2);
    end
    errA = DaqDConfigPort(daq, 0, 0);   % Port A will send data out
    errB = DaqDConfigPort(daq, 1, 1);   % Port B will receive data
    
    DaqDOut(daq, 0, 0);  % Reset the daq line

    % Initialize parallel computing
    ptr = fopen( '/tmp/resp.txt', 'w' );  % put empty file in /tmp so I can check for it
    fclose( ptr );

    obj = createJob();
    set( obj, 'FileDependencies', {'jobStartup.m', 'GetPadResp.m', 'KbCheckMulti.m'});  % Add psychtoolbox to worker path

    task = createTask(obj, @GetPadResp, 1, {daq});

    submit(obj);                   % Submit the job
    waitForState(task,'running');  % Wait for the task to start running

% if behavioral
else
    daq = -1;
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
    viewingDistance = 66;
   
else

    monitorWidth    = rGet('dXscreen', 'monitorWidth');
    viewingDistance = rGet('dXscreen', 'viewingDistance');
    
end
    
rSet('dXscreen', 1, 'monitorWidth',    monitorWidth);
rSet('dXscreen', 1, 'viewingDistance', viewingDistance);

% need access to the window pointer for freeze-framing dots.
wdwPtr = rWinPtr;

% Initialize sound
InitializePsychSound;

expdir              = fileparts(which('experiment_eeg.m'));
[y, freq, nbits]    = wavread(fullfile(expdir,'SOUND16'));
wavedata            = y';
nrchannels          = size(wavedata,1);
pahandle_correct    = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
PsychPortAudio('FillBuffer', pahandle_correct, wavedata);

[y, freq, nbits]    = wavread(fullfile(expdir,'errorsound'));
wavedata            = y';
nrchannels          = size(wavedata,1);
pahandle_antic      = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
PsychPortAudio('FillBuffer', pahandle_antic, wavedata);

% Initialize the KbCheck routine:
KbCheckMulti;                   % Initialize keyboard check routine
triggercode         = KbName('LEFTSHIFT');  % Nope, LEFTSHIFT instead of !

RT = [];
bl = 1;
score = 0;
ppd_ = rGet('dXscreen', 1, 'pixelsPerDegree');

% Dots features from motion_localizer_translational.m:
contrast_factor     = 1;        % The percentage of 256 for color saturation (0.1 used in fixed-viewing version)
blank_time          = 1000;     % 1000 msec blank time at the end
pix_degree_size     = 0.15;     % This sets pixels to .15 degrees visual angle for a given screen
aperture_diam       = 10;       % Degrees covered by aperture
target_diam         = 0.3;      % Degrees covered by target
black_annulus_diam  = 2;        % A black target behind the visible target for preventing dot-tracking at fixation
density             = 20;       % dots/degree^2 Downing-Movshon says dots/degree^2/sec -- I don't get why sec is relevant
speed               = 7;        % Dot-speed in deg/sec
loops               = 3;        % A low-level drawing feature of DotsX code
motion_dur          = 500;      % Motion stimulus duration in msec (fixed viewing time)
pixelsize           = floor(pix_degree_size * ppd_);

% if in scanner, reduce contrast to remove afterimage effect (see 2/9 notes
% in VoodooPad)
if Behavioral == 0
    contrast_factor = 0.5;
end

% The black target imitates the annulus idea in the Kastner lab motion
% localizer code, presumably to prevent tracking of individual dots that
% move through the fixation point.
blackTargetIdx  = rAdd( ...
    'dXtarget', 1, ...
    'color',    contrast_factor*[0 0 0], ...
    'penWidth', 24, ...
    'diameter', black_annulus_diam, ...
    'visible',  false);
% add some dots and a target
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
    'coherence',coherence_array(1), ...
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

font_degrees  = 0.7;
str           = sprintf('Score: %d', score);
textwidth     = font_degrees*length(str);
x_pos         = -0.3*textwidth;
textIdx_Score = rAdd( ...
    'dXtext',   1, ...
    'visible',  false, ...
    'x',        x_pos,  ...
    'y',        0,  ...
    'size',     floor(font_degrees*ppd_),  ...
    'font',     'Courier',  ...
    'color',    contrast_factor*[1 1 1]*255,  ...
    'string',   str);

%############################
%####                    ####
%#### BEHAVIORAL ROUTINE ####
%####                    ####
%############################

% if behavioral...
if doQuest
    if SessionsCompleted == 0
        trainingIntro;
    else
        str = {};
        str{1} = 'Some things to remember:                        ';
        str{2} = '- Respond with M (rightward motion) and Z       ';
        str{3} = '  (leftward motion)                             ';
        str{4} = '- You''ll hear a tone when you answer correctly.';
        str{5} = '- You''ll be shown your score every 5 trials.   ';
        str{6} = '- Keep your head still.                         ';
        str{7} = '- Keep your gaze on the center of the screen.   ';
        str{8} = '- Respond only after the fixation changes from  ';
        str{9} = '  white to blue.                                ';
        str{10} = '';
        str{11} = 'To begin the task, press the ''Space'' key.';
        showText(str);
    end
        
    % do a quest block to establish the correct coherence
    tmp_coherence = 5;  % coherence is irrelevant because it will be varied in 
                        %   the quest blocks--left in for consistency
    RSIconst = 1;       % response-stimulus interval (fixed for quest blocks)
    PIconst = 0.5;      % bias is fixed to 0.5 (no bias)
    NpsychTrials = 80;  % 80 psych trials take about 17 minutes

    coherVec = [2.5 5 8 12.5 25];
    
    % use a psychometric block instead of a quest block
    [STpsych, ST_timePsych, RTpsych, ERpsych, RDirPsych, PiDirPsych, ...
        SubScore, score, premie_t, premie_e, coherenceVec, coherence_array ] = ...
     psychometric_block ...
        ( RSIconst, Shape_poss(1), coherVec, ...
        NpsychTrials, dotsIdx, targetIdx, blackTargetIdx, ...
        textIdx_Score, lkey, rkey, PIconst, 1, salary, wdwPtr, ...
        pahandle_correct, pahandle_antic, daq);
    save (filename, 'blank_time', 'pix_degree_size', 'aperture_diam', ...
        'pixelsize', 'target_diam', 'black_annulus_diam', 'ppd_', ...
        'density', 'speed', 'loops', 'waitdur', 'blockdur', 'lowCoh', ...
        'highCoh', 'STpsych', 'ST_timePsych', 'RTpsych', 'ERpsych', ...
        'RDirPsych','PiDirPsych','coherenceVec','RSI_poss','Shape_poss');
    
    % correct for the possibility that the estimation algorithm is totally 
    % off the wall
    if ( coherence_array(1) > 8 )  || ( coherence_array(1) < 0 )
        coherence_array(1) = 8;
    end
    if ( coherence_array(2) > 11 )  || ( coherence_array(2) < 0 )
        coherence_array(2) = 11;
    end
    if ( coherence_array(3) > 15 ) || ( coherence_array(3) < 0 )
        coherence_array(3) = 15;
    end
end

% Define the ordering matrices
RSIs = [ RSI_poss(1) RSI_poss(2) RSI_poss(2) RSI_poss(1) RSI_poss(2) RSI_poss(1); ...
         RSI_poss(2) RSI_poss(1) RSI_poss(1) RSI_poss(2) RSI_poss(1) RSI_poss(2); ];
Shapes = [ Shape_poss(1) Shape_poss(2) Shape_poss(2) Shape_poss(1) Shape_poss(2) Shape_poss(1); ...
           Shape_poss(2) Shape_poss(1) Shape_poss(1) Shape_poss(2) Shape_poss(1) Shape_poss(2); ];
Cohs = [ coherence_array(1) coherence_array(2) coherence_array(3) coherence_array(1) coherence_array(2) coherence_array(3); ...
         coherence_array(1) coherence_array(2) coherence_array(3) coherence_array(3) coherence_array(2) coherence_array(1); ...
         coherence_array(3) coherence_array(1) coherence_array(2) coherence_array(2) coherence_array(3) coherence_array(1); ];
% 'd': dots; 'a': arrow
% EK (10/26/10) - removed all arrow ('a') trials
Cues = [ 'd' 'd' 'd' 'd' 'd' 'd'; ...
         'd' 'd' 'd' 'd' 'd' 'd';];    

% At this point, check if coherence_array was set; if not, either wasn't set at
% beginning of experiment, or wasn't set correctly during psychometric training.
if ~exist('coherence_array','var') || length(coherence_array) ~= 3 || sum(coherence_array) == 0
    coherence_array = [8 11 15];
end
     
%######################
%####              ####
%#### MAIN ROUTINE ####
%####              ####
%######################

str = {};
str{1} = 'Now your task is to gain as many points';
str{2} = 'as possible. The experiment has a fixed';
str{3} = 'duration, so the faster you go, the more';
str{4} = 'money you can make. It''s OK to be greedy!';
str{5} = '';
str{6} = '(Press the ''Space'' key to continue.)  ';    
showText(str);

str = {};
str{1} = 'Your task is to indicate the direction of the';
str{2} = 'motion or arrows (depending on the block) with';
str{3} = 'Z for left ';
str{4} = 'M for right';
str{5} = '';
str{6} = '(Press the ''Space'' key to continue.)';
showText(str);

str = {};
str{1} = 'When you score a point, you''ll hear a';
str{2} = 'sound, and the circle or triangle will';
str{3} = 'turn green. For an error it will turn';
str{4} = 'red. You''ll see your current score every';
str{5} = '5 trials.';
str{6} = '';
str{7} = '(Press the ''Space'' key to continue.)';
showText(str);

str = {};
str{1} = 'Do whatever necessary to make as much money';
str{2} = 'as possible.';
str{3} = 'Z = left ';
str{4} = 'M = right';
str{5} = '';
str{6} = '(Press the ''Space'' key to continue.)';
showText(str);

str = {};
str = {'Press ''Space'' to start,','then fixate on the central circle'};
showText(str);

if ~exist('runsDone','var')
	runsDone = 0;
end

% the main experimental loop
for runNo = (runsDone +1):numRuns

    % set the filename for the saved .mat file for this run
    filename = regexprep( filename, 'ses(\d+)(_\d+)?.mat', strcat( 'ses$1_', num2str(runNo), '.mat'));
    % get rid of data from last run
    clear ( 'arrow_direction', ...
		'arrow_dur', ...
		'arrow_offset', ...
		'arrow_onset', ...
		'blocknum', ...
		'cohVec', ...
		'cueVec', ...
		'D', ...
		'ER', ...
		'PI', ...
		'PiDir', ...
		'Premie_d', ...
		'Premie_t', ...
		'RDir', ...
		'RT', ...
		'shapeVec', ...
		'ST_time', ...
		'ST', ...
		'trialnum' );    

    RT = [];
    money = 0;

    if runNo > 1
        % Tell subject to wait while we reset the scanner
        str = {'Saving MEG data, please wait...'};
        showText(str);
    end

    % introduce the run
    str = {};
    str{1} = sprintf('RUN: %d / %d', runNo, numRuns );
    str{2} = '';
    str{3} = '(Press the ''Space'' key to continue.)';
    showText(str);

    % Decide on the random order of the conditions
    % Now just pick a value of 1 or 2 for each of these features:
    RSI_row = floor(rand(1)+1.5);
    Coh_row = floor(rand(1)+1.5);
    Cue_row = floor(rand(1)+1.5);

    % The next lines isolate one row from the above data structures. These
    % can be indexed by the block-number in the main experiment loop below.
    RSI         = RSIs(RSI_row,:);
    Shape       = Shapes(RSI_row,:);
    coherence   = Cohs(Coh_row,:);
    cue_type    = Cues(Cue_row,:);
    numblocks   = length(RSI);
    
    if (runNo == numRuns) && (~Behavioral)
        addBlock = 2;
    else
        addBlock=0;
    end

    % Using Rafal's names for trial-indexing of the returned data:
    % 'ib' refers to 'index beginning' 
    % 'ie' refers to 'index end'
    % 'bl' is the block number

    % execute each block
    for bl = 1 : numblocks
        % some formatting
        if cue_type(bl) == 'a'
            this_block_type = '**';
        else
            this_block_type = coherence(bl);
        end
        
        fprintf(1, 'This block (%d/%d): ''%s-%02d''', bl, numblocks, cue_type(bl), this_block_type);
        
        resting_arrow(numblocks - bl + 1 + addBlock, money, cue_type(bl) );
        
        [STbl, irrelDirbl, ST_timebl, arrow_onsetbl, arrow_durbl, ...
            arrow_offsetbl,RTbl, ERbl, RDirbl, PiDirbl, score, ...
            premie_t,premie_d,arrow_direction] = ...
        block ( ...
            RSI(bl), RSI_poss,Shape(bl), coherence(bl), ...
            coherence_array, cue_type(bl), blockdur, dotsIdx, targetIdx,...
            triangleIdx, blackTargetIdx, textIdx_Score, ppd_, lkey,rkey,...
            money, salary,wdwPtr, pahandle_correct, pahandle_antic, daq,...
            contrast_factor, RT_struct);
        
        ib                  = length(RT) + 1; %index of the begining of inserted block
        ie                  = length(RT) + length(RTbl);	%index of the end of inserted block
        
        ST(ib:ie)           = STbl;
        irrelDir(ib:ie)     = irrelDirbl;   % Direction of irrelevant motion on arrow trials (will equal ST on motion trials)
        ST_time(ib:ie)      = ST_timebl;
        arrow_onset(ib:ie)  = arrow_onsetbl;
        arrow_direction(ib:ie) = arrow_direction;
        arrow_dur(ib:ie)    = arrow_durbl;
        arrow_offset(ib:ie) = arrow_offsetbl;	
        shapeVec(ib:ie)     = Shape(bl);
        cohVec(ib:ie)       = coherence(bl);
        cueVec(ib:ie)       = cue_type(bl);
        RT(ib:ie)           = RTbl;
        ER(ib:ie)           = ERbl;
        RDir(ib:ie)         = RDirbl;
        blocknum(ib:ie)     = bl + numblocks*(runNo-1);
        trialnum(ib:ie)     = 1:length(RTbl);
        D(ib:ie)            = RSI(bl);
        PI(ib:ie)           = 0.5;
        PiDir(ib:ie)        = PiDirbl; % For 50:50 stimuli, this variable is meaningless
        Premie_t(ib:ie)     = premie_t;
        Premie_d(ib:ie)     = premie_d;	

        money = money + score * salary;
        
        % display average performance for this block, for all blocks up to
        % now
        cur_perform = 100 * (1 - (sum(ERbl)/length(ERbl)));
        cum_perform = 100 * (1 - (sum(ER(cueVec == cue_type(bl) & cohVec == coherence(bl)))/length(ER(cueVec == cue_type(bl) & cohVec == coherence(bl)))));
        cur_rt      = mean(RTbl);
        cur_rt_sd   = std (RTbl);
        cum_rt      = mean(RT(cueVec == cue_type(bl) & cohVec == coherence(bl)));
        cum_rt_sd   = std (RT(cueVec == cue_type(bl) & cohVec == coherence(bl)));
        fprintf(1, ', Cur/cum performance: %3.0f%%/%3.0f%%,\tcurr/cum RT (sd): %1.3f(%1.3f) / %1.3f(%1.3f)\n', cur_perform, cum_perform, cur_rt, cur_rt_sd, cum_rt, cum_rt_sd);
	 
        if bl==numblocks
            runsDone = runsDone + 1;
        end
        
        % save the data
        if doQuest
            save (filename, 'runsDone', 'ST', 'ST_time','RT', 'ER', ...
                'RDir', 'blocknum', 'trialnum','D', 'PI','cohVec', ...
                'cueVec','shapeVec','PiDir', 'money','Premie_t', ...
                'Premie_d', 'contrast_factor','blank_time', ...
                'pix_degree_size', 'aperture_diam','pixelsize', ...
                'target_diam','black_annulus_diam','ppd_','density', ...
                'speed','loops', 'waitdur','blockdur','numblocks', ...
                'STpsych','ST_timePsych','RTpsych','ERpsych', ...
                'RDirPsych','PiDirPsych','coherence_array', ...
                'arrow_onset','arrow_dur','arrow_offset','RSI_poss', ...
                'Shape_poss','coherenceVec');     
        else
            save (filename, 'runsDone', 'ST', 'ST_time','RT', 'ER', ...
                'RDir', 'blocknum', 'trialnum','D', 'PI','cohVec', ...
                'cueVec','shapeVec', 'PiDir', 'money','Premie_t', ...
                'Premie_d', 'contrast_factor', 'blank_time', ...
                'pix_degree_size', 'aperture_diam','pixelsize', ...
                'target_diam','black_annulus_diam','ppd_','density', ...
                'speed','loops', 'waitdur','blockdur','numblocks', ...
                'coherence_array','arrow_onset','arrow_dur', ...
                'arrow_offset','RSI_poss','Shape_poss','arrow_direction');    
        end
    end
end

% Only do sigdet routine if in scanner
if ~Behavioral
    resting (2, money);

    %#####################################
    %####                             ####
    %#### SIGNAL DETECT SPEED ROUTINE ####
    %####                             ####
    %#####################################

    % Now add in two blocks that test signal detection speed, each of 2.5 minutes
    % (leading to a total experiment time of 90 minutes):

    str = {};
    str{1} = 'OK, just two shorter blocks left.';
    str{2} = '';
    str{3} = '(Press the ''Space'' key to continue.)';
    showText(str);

    str = {};
    str{1} = 'These two blocks will each last 2 minutes.';
    str{2} = 'In these blocks, simply press the specified';
    str{3} = 'key as soon as you see any dots at all.';
    showText(str);

    str{1} = 'In the first block, always press the Z key';
    str{2} = 'with your left index finger.';
    str{3} = 'In the second block, always press the M key';
    str{4} = 'with your right index finger.';
    str{5} = '';
    str{6} = '(Press the ''Space'' key to continue.)';
    showText(str);

    str = {};
    str{1} = sprintf('You will be paid %d cent for each point.', salary);
    str{2} = 'Try to earn as much as you can.';
    str{3} = '';
    str{4} = '(Press the ''Space'' key to continue.)';
    showText(str);

    str = {};
    str{1} = 'Please rest now.';
    str{2} = 'In this block, always press the Z key.';
    str{3} = 'Whenever you are ready to';
    str{4} = 'continue, press SPACE.';
    str{5} = 'Number of blocks remaining: 2';
    str{6} = sprintf('Total earned: $%.2f', money/100);
    showText(str);

    SDdur = 120;
    [Left_ST, Left_ST_time, Left_RT, Left_ER, score1, Left_premie_t, ...
        Left_premie_d] = ...
    sig_det_block( ...
        RSI_poss(1), Shape_poss(1), coherence_array(1), SDdur, 'Left', ...
        dotsIdx, targetIdx, blackTargetIdx, textIdx_Score, ppd_, lkey, ...
        rkey, money, salary,pahandle_correct, pahandle_antic, daq, ...
        contrast_factor);

    money = money + score1 * salary;

    str = {};
    str{1} = 'Please rest now.';
    str{2} = 'In this block, always press the M key.';
    str{3} = 'Whenever you are ready to';
    str{4} = 'continue, press SPACE.';
    str{5} = 'Number of blocks remaining: 1';
    str{6} = sprintf('Total earned: $%.2f', money/100);
    showText(str);

    [Right_ST, Right_ST_time, Right_RT, Right_ER, score2, Right_premie_t, ...
        Right_premie_d] = ...
    sig_det_block( ...
        RSI_poss(1), Shape_poss(1), coherence_array(1), SDdur, 'Right', ...
        dotsIdx, targetIdx, blackTargetIdx, textIdx_Score, ppd_, lkey, ...
        rkey, money, salary,pahandle_correct, pahandle_antic, daq, ...
        contrast_factor);

    money = money + score2 * salary + money_psych*salary;

    runsDone = 0;

    %Finishing the experiment
    if doQuest
        save (filename,'runsDone', 'ST', 'ST_time', 'RT', 'ER', 'RDir', ...
            'blocknum', 'trialnum', 'D', 'PI', 'PiDir', 'money', 'Left_ST', ...
            'Left_ST_time', 'Left_RT', 'Left_ER', 'Left_premie_t', 'cohVec', ...
            'cueVec','shapeVec','Left_premie_d', 'Right_ST', 'Right_ST_time', ...
            'Right_RT', 'Right_ER', 'Right_premie_t', 'Right_premie_d', ...
            'Premie_t', 'Premie_d', 'contrast_factor','blank_time', ...
            'pix_degree_size', 'aperture_diam','pixelsize', 'target_diam', ...
            'black_annulus_diam','ppd_','density','speed','loops', 'waitdur', ...
            'blockdur','numblocks','coherence_array','arrow_onset','arrow_dur', ...
            'arrow_offset','RSI_poss','Shape_poss','coherenceVec','STpsych', ...
            'ST_timePsych','RTpsych','ERpsych','RDirPsych','PiDirPsych');  
    else
        save (filename,'runsDone', 'ST', 'ST_time', 'RT', 'ER', 'RDir', ...
            'blocknum', 'trialnum', 'D', 'PI', 'PiDir', 'money', 'Left_ST', ...
            'Left_ST_time', 'Left_RT', 'Left_ER', 'Left_premie_t', 'cohVec', ...
            'cueVec','shapeVec','Left_premie_d', 'Right_ST', 'Right_ST_time', ...
            'Right_RT', 'Right_ER', 'Right_premie_t', 'Right_premie_d', ...
            'Premie_t', 'Premie_d', 'contrast_factor','blank_time', ...
            'pix_degree_size', 'aperture_diam','pixelsize', 'target_diam', ...
            'black_annulus_diam','ppd_','density','speed','loops', 'waitdur', ...
            'blockdur','numblocks','coherence_array','arrow_onset', 'arrow_dur',...
            'arrow_offset','RSI_poss','Shape_poss','arrow_direction');  
    end
end
    
% if using daq, destroy and remove the thread
if daq ~= -1
    destroy( obj );
    clear obj;
end

% thankyou (money)
% opponent_money = thankyou (money, opponent_money, score1+score2, salary, windowptr);
% money = 0; opponent_money = 0; salary = 0;
rSet('dXdots',dotsIdx,'visible',false);
rSet('dXtarget',targetIdx,'visible',false);
rSet('dXtarget',blackTargetIdx,'visible',false);
rGraphicsDraw;

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
% save( subj_order_file, 'PI_vals', 'D_vals', 'SessionsCompleted' );
% save( subj_order_file, 'PermutationList', 'SessionsCompleted' );
save( subj_order_file, 'SessionsCompleted' );


thankyou( money );

rDone;
% Close the audio device:
PsychPortAudio('Close', pahandle_correct);
PsychPortAudio('Close', pahandle_antic);

return

% catch
%     Screen('CloseAll');
%     %     psychrethrow(psychlasterror);
%     rethrow(lasterror);
%     PsychPortAudio('Close', pahandle_correct);
%     PsychPortAudio('Close', pahandle_antic);
%     FlushEvents;
% end
