function money = experiment_eeg (subject,Behavioral,lowCoh,highCoh,RTfile)% function money = experiment_eeg (subject,Behavioral,lowCoh,highCoh,RTfile)%% The low and high coherence inputs are only required for EEG% sessions--in behavioral sessions the low and high coherence will% be determined from the psychometric session.%% Each trial consists of the onset of a moving dots stimulus, followed by% freezing. There will always be a fixation point in the middle. As soon as% the dots stop moving, the participant is supposed to press a right or% left button indicating whether right or left motion was observed. If they% are correct, the fixation circle turns Green; if they are incorrect, it% turns Red.%% After every miniblock, the total score (number correct) is displayed in% the center of the screen.%%#################################%####                         ####%#### INITIALIZATION ROUTINES ####%####                         ####%#################################% initialize the random seedrand('state',sum(100*clock)); % resets generator to a new staterandn('state',sum(100*clock)); % resets generator to a new state% Default to fMRI settings if no behavioral flag set in the input params:if nargin < 2    Behavioral = 0;end% Before doing anything, let the user confirm that this subject number is% the right one:fprintf( 1, '\n The following information relating to subject %d currently exists: \n\n', subject );% Read in all the files related to subject:d = dir;indices = strmatch( sprintf( 'subject%d_', subject ), { d(:).name } );if isempty( indices )    fprintf( 1, 'New subject: no files related to subject %d in the directory. \n\n', subject );else    for i = 1 : length(indices)        fprintf( 1, '%s\t\t%s\n', d(indices(i)).name, d(indices(i)).date );    endenduser_comment = input('\nDo you want to enter a comment on this run? Answer will be saved as a string. Press return if no comment desired.\n','s');continue_response = input( '\nContinue? Type ''y'' if yes, ''n'' if no.\n', 's' );if strcmp( continue_response, 'y' ) ~= 1    returnend% increment the filename number based on what previous files are thereSessionsCompleted = 0;filename = 'foo';while SessionsCompleted < 1 || exist(filename,'file')     SessionsCompleted = SessionsCompleted + 1;    filename = sprintf ('subject%d_ses%d.mat', subject, SessionsCompleted);endif ~Behavioral    % flag to skip coherence setting routine    doQuest = 0;       % if not behavioral, experiment must be called with coherence values    if ~exist('lowCoh','var') || ~exist('highCoh','var')        fprintf('please call this experiment with a low and high coherence\n');        return    end        numRuns = 4;    % number of runs    blockdur = 120; % 2-minute blocks (for fMRI/EEG)	waitdur = 30;   % 30 second blank period    daq = 0;        % set up USB (legacy; kept for compatibility)    % set up UDP messaging socket    localIP = '10.1.1.3';    remoteIP = '10.1.1.2';    port = 6665;    u = udp(remoteIP, port);    fopen(u);% if behavioral, check if coherences provided... if not, set to defaultselse    % flag to execute coherence setting routine    doQuest = 1;     if ~exist('lowCoh','var') || isempty(lowCoh)        lowCoh = 10;    end    if ~exist('highCoh','var') || isempty(highCoh)        highCoh = 20;    end        numRuns = 1;    % number of runs	blockdur = 240; % duration of a single block in seconds (4 min for Behavioral)	waitdur = 30;   % Should not be relevant for Behavioral sessions    daq = -1;       % no USB (legacy; kept for compatibility)end% 11/5/08: Not doing the following stuff anymore . . .% Now a permutation exists in Vector2. For each subject, save the % particular ordering. There should be a unique permutation for each session% for each subject. The odds of generating two identical permutations are% extremely small. For that reason, you can generate the permutations on% the fly before each session. Then you can just save them at the start of% each session.fid = fopen( sprintf('subject%d_order.mat', subject) );if fid == -1    subj_order_file = sprintf( 'subject%d_order', subject );    SessionsCompleted = 0;else    fclose( fid );    subj_order_file = sprintf( 'subject%d_order', subject );    load( subj_order_file );end% In this experiment, we're covarying (1) two RSI levels, (2) two motion% coherence levels, and (3) two trial types (1: normal dot-motion% discrimination; 2: cued-response with a salient arrow cue, dot-motion is% irrelevant)RSI_poss   = [ 2 2  ];  % Mean RSI ("poss" means possibility)Shape_poss = [ 5 10 ];  % Gamma pdf shape parameter for individual RSI                        % (scale = mean/shape)coherence_array = [lowCoh highCoh];  % Coherence levels: 3 should be hard,                                     % 8 should be easierif exist('RTfile','var') % Check to make sure there IS an RTfile    load(RTfile);    % RTfile contains:    % RT_t     D_t  CueType_t   TrialCoh_t    % BE CAREFUL! If the saved variables have the same name as the ones    % in this script (i.e., the ones changing during the experiment),    % everything will get screwed up. As such, the RT file should store    % variables with different names, which can be done by a    % post-processing step after the original data is collected. This will    % require RTs for every one of the 4 dots conditions, and every one of    % the 4 arrow conditions (really 2, since coherence is 0 in those    % blocks). We'll want one RT for each block, along with an identifier    % of RSI, coherence, and cue-type. Well, if desired, we can just do the    % extraction of these subtypes from the RTfile.    % OK, adding a "_t" to the end of all relevant variables.    RT_struct.fast_arrow_RT = RT_t(find(D_t==RSI_poss(1) & CueType_t=='a'));    if ~isempty(find(D_t==RSI_poss(2)))        RT_struct.slow_arrow_RT = RT_t(find(D_t==RSI_poss(2) & CueType_t=='a'));    else        RT_struct.slow_arrow_RT = RT_struct.fast_arrow_RT;     end        % This collapses over coherence during arrow trials, which is likely to    % be 0, although it was not for some of my own behavioral    % sessions.        % I have set the low coherence to 0 and the high coherence to 1    RT_struct.fast_low_dots_RT  = RT_t(find(D_t==RSI_poss(1) & CueType_t=='d' & TrialCoh_t==0));    RT_struct.fast_high_dots_RT = RT_t(find(D_t==RSI_poss(1) & CueType_t=='d' & TrialCoh_t==1));    RT_struct.slow_low_dots_RT  = RT_t(find(D_t==RSI_poss(2) & CueType_t=='d' & TrialCoh_t==0));    RT_struct.slow_high_dots_RT = RT_t(find(D_t==RSI_poss(2) & CueType_t=='d' & TrialCoh_t==1));else    % Make fake data using a gamma distribution with mean decision time    % = 800 msec, and mean signal detection time = 300 msec:    RT_struct.fast_arrow_RT = normrnd(0.35,0.05*ones(1,1000));    RT_struct.slow_arrow_RT = normrnd(0.35,0.05*ones(1,1000));    % This collapses over coherence during arrow trials, which is likely to    % be 0, although it was not for some of my own behavioral sessions.    RT_shape = 5;    RT_scale = 0.8/5;    RT_struct.fast_low_dots_RT  = gamrnd(RT_shape,RT_scale*ones(1,1000));    RT_struct.fast_high_dots_RT = gamrnd(RT_shape,RT_scale*ones(1,1000));    RT_struct.slow_low_dots_RT  = gamrnd(RT_shape,RT_scale*ones(1,1000));    RT_struct.slow_high_dots_RT = gamrnd(RT_shape,RT_scale*ones(1,1000));end% money earned by subjects for correct decision [in cents]salary      = 1;    money_psych = 0;% Response keys:keys = [ KbName('Z'), KbName('M') ];lkey = keys(1);rkey = keys(2);% reset the random seedrand ('state', sum(100*clock));randn ('state', sum(100*clock));if Behavioral    Screen('Preference','SkipSyncTests',0)    rInit({'screenMode','local','showWarnings',true});end% Get the window pointer (for freeze-framing dots)if Behavioral    wdwPtr = rWinPtr;else    fprintf(u, 'wdwPtr = rWinPtr;');end% Perform basic initialization of the sound driver:InitializePsychSound;% Read WAV file from filesystem:expdir = fileparts(which('experiment_eeg.m'));[y, freq, nbits] = wavread(fullfile(expdir,'SOUND16'));wavedata = y';nrchannels = size(wavedata,1); % Number of rows == number of channels.% Open the default audio device [], with default mode [] (==Only playback),% and a required latency class of zero 0 == no low-latency mode, as well as% a frequency of freq and nrchannels sound channels.% This returns a handle to the audio device:pahandle_correct = PsychPortAudio('Open', [], [], 0, freq, nrchannels);% Fill the audio playback buffer with the audio data 'wavedata':PsychPortAudio('FillBuffer', pahandle_correct, wavedata);% Now open a channel for the anticipatory error sound:[y, freq, nbits] = wavread(fullfile(expdir,'errorsound'));wavedata = y';nrchannels = size(wavedata,1); % Number of rows == number of channels.pahandle_antic = PsychPortAudio('Open', [], [], 0, freq, nrchannels);PsychPortAudio('FillBuffer', pahandle_antic, wavedata);% Also initialize the KbCheck routine:KbCheckMulti;                   % Initialize keyboard check routinetriggercode = KbName('LEFTSHIFT');  % Nope, LEFTSHIFT instead of !RT = [];bl = 1;score = 0;ppd_ = rGet('dXscreen', 1, 'pixelsPerDegree');% Dots features from motion_localizer_translational.m:contrast_factor = 1;    % The percentage of 256 for color saturation (0.1 used in fixed-viewing version)blank_time = 1000;      % 1000 msec blank time at the endpix_degree_size = 0.15; % This sets pixels to .15 degrees visual angle for a given screenaperture_diam = 10;     % Degrees covered by aperturetarget_diam = 0.3;      % Degrees covered by targetblack_annulus_diam = 2; % A black target behind the visible target for preventing dot-tracking at fixationdensity = 20;           % dots/degree^2 Downing-Movshon says dots/degree^2/sec -- I don't get why sec is relevantspeed = 7;              % Dot-speed in deg/secloops = 3;              % A low-level drawing feature of DotsX codemotion_dur = 500;       % Motion stimulus duration in msec (fixed viewing time)pixelsize = floor(pix_degree_size * ppd_);% The black target imitates the annulus idea in the Kastner lab motion% localizer code, presumably to prevent tracking of individual dots that% move through the fixation point.blackTargetIdx  = rAdd( ...    'dXtarget', 1, ...    'color',    contrast_factor*[0 0 0], ...    'penWidth', 24, ...    'diameter', black_annulus_diam, ...    'visible',  false);% add some dots and a targettargetIdx       = rAdd( ...    'dXtarget', 1, ...    'color',    contrast_factor*[255 255 255], ...    'penWidth', 24, ...    'diameter', target_diam, ...    'visible',  false);dotsIdx         = rAdd( ...    'dXdots',   1, ...    'color',    contrast_factor*[255 255 255], ...    'direction',0, ...    'coherence',coherence_array(1), ...    'diameter', aperture_diam, ...    'size',     pixelsize, ...    'loops',    loops, ...    'density',  density, ...    'speed',    speed, ...    'lifetimeMode', 'random', ...    'visible',  false);triangleIdx     = rAdd( ...    'dXpolygon',1, ...    'visible',  false, ...    'color',    contrast_factor*[255 255 255], ...    'pointList',0.65*target_diam*[-1 1; 1 1; 0 -1]);fontsize      = 20;font_degrees  = 0.7;str           = sprintf('Score: %d', score);textwidth     = font_degrees*length(str);x_pos         = -0.3*textwidth;textIdx_Score = rAdd( ...    'dXtext',   1, ...    'visible',  false, ...    'x',        x_pos,  ...    'y',        0,  ...    'size',     floor(font_degrees*ppd_),  ...    'font',     'Courier',  ...    'color',    contrast_factor*[1 1 1]*255,  ...    'string',   str);RT = [];%############################%####                    ####%#### BEHAVIORAL ROUTINE ####%####                    ####%############################% if behavioral...if doQuest    welcome_quest;        % do a quest block to establish the correct coherence    tmp_coherence = 5;  % coherence is irrelevant because it will be varied in                         %   the quest blocks--left in for consistency    RSIconst = 1;       % response-stimulus interval (fixed for quest blocks)    PIconst = 0.5;      % bias is fixed to 0.5 (no bias)    NpsychTrials = 80;  % 80 psych trials take about 17 minutes    if SessionsCompleted==0        coherVec = [2.5 5 8 12.5 25];    else        coherVec = [1.5 2.5 5 8 12.5];    end        % use a psychometric block instead of a quest block    [STpsych, ST_timePsych, RTpsych, ERpsych, RDirPsych, PiDirPsych, ...        SubScore, score, premie_t, premie_e, coherenceVec, lowCoh, ...        highCoh] = ...     psychometric_block ...        ( RSIconst, Shape_poss(1), coherVec, ...        NpsychTrials, dotsIdx, targetIdx, blackTargetIdx, ...        textIdx_Score, lkey, rkey, PIconst, 1, salary, wdwPtr, ...        pahandle_correct, pahandle_antic, daq);    save (filename, 'blank_time', 'pix_degree_size', 'aperture_diam', ...        'pixelsize', 'target_diam', 'black_annulus_diam', 'ppd_', ...        'density', 'speed', 'loops', 'waitdur', 'blockdur', 'lowCoh', ...        'highCoh', 'STpsych', 'ST_timePsych', 'RTpsych', 'ERpsych', ...        'RDirPsych','PiDirPsych','coherenceVec','RSI_poss','Shape_poss');        % correct for the possibility that the estimation algorithm is totally     %   off the wall    if (lowCoh>8) || (lowCoh<0)        lowCoh=8;    end    if (highCoh>15) || (highCoh<0)        highCoh = 15;    endendcoherence_array = [ lowCoh highCoh ];    % Leigh didn't like my previous scheme, since it can fall prey to agressive% high-pass filtering (with a really high lower-frequency cutoff). So we% now pick two variations on an RSI ordering, two variations on a coherence% ordering, and two variations on a cue-type ordering. Then we are free to% mix together one ordering of each, for 8 unique condition orderings. % RSI order: A B B A B A A B; or B A A B A B B A% Coherence order: C D C D D C D C; or D C D C C D C D % Cue order: E F F E E F F E; or F E E F F E E FRSIs = [ RSI_poss(1) RSI_poss(2) RSI_poss(2) RSI_poss(1) ...         RSI_poss(2) RSI_poss(1) RSI_poss(1) RSI_poss(2); ...         RSI_poss(2) RSI_poss(1) RSI_poss(1) RSI_poss(2) ...         RSI_poss(1) RSI_poss(2) RSI_poss(2) RSI_poss(1) ];Shapes = [ Shape_poss(1) Shape_poss(2) Shape_poss(2) Shape_poss(1) ...           Shape_poss(2) Shape_poss(1) Shape_poss(1) Shape_poss(2); ...           Shape_poss(2) Shape_poss(1) Shape_poss(1) Shape_poss(2) ...           Shape_poss(1) Shape_poss(2) Shape_poss(2) Shape_poss(1) ];Cohs = [ coherence_array(1) coherence_array(2) coherence_array(1) coherence_array(2) ...         coherence_array(2) coherence_array(1) coherence_array(2) coherence_array(1); ...         coherence_array(2) coherence_array(1) coherence_array(2) coherence_array(1) ...         coherence_array(1) coherence_array(2) coherence_array(1) coherence_array(2) ];% 'd': dots; 'a': arrowCues = [ 'd' 'a' 'a' 'd' ...         'd' 'a' 'a' 'd'; ...         'a' 'd' 'd' 'a' ...         'a' 'd' 'd' 'a' ];    % Using Rafal's names for trial-indexing of the returned data:% 'ib' refers to 'index beginning' % 'ie' refers to 'index end'% 'bl' is the block number%######################%####              ####%#### MAIN ROUTINE ####%####              ####%######################welcome_main;% Print additional instructionsfontsize = 20;font_degrees = 0.7;if ~exist('runsDone','var')	runsDone = 0;endrunNo = 0;run_str = {};run_str{1} = sprintf('RUN: %d',runNo);run_str{2} = 'Press SPACE to get started';str = {'Press a button to start,','then fixate on the central circle'};textwidth = font_degrees*length(str);x_pos_run = {};for i  = 1:length(run_str)  textwidth = fontsize*length(run_str{i})/ppd_;  x_pos_run{i} = -0.3*textwidth;endtextIdx_Run = rAdd( ...    'dXtext',   length(run_str), ...    'visible',  false, ...    'x',        x_pos_run, ...    'y',        {0 -5}, ...    'size',     fontsize, ...    'font',     'Courier', ...    'color',    contrast_factor*[1 1 1]*255, ...    'string',   run_str);x_pos = {-0.3*textwidth -0.3*textwidth};textIdx_Start = rAdd( ...    'dXtext',   2, ...    'visible',  true, ...    'x',        x_pos, ...    'y',        {1 0}, ...    'size',     floor(font_degrees*ppd_), ...    'font',     'Courier',  ...    'color',    [1 1 1]*255, ...    'string',   str );rGraphicsDrawMulti(inf);rSet('dXtext',textIdx_Start,'visible',false);while KbCheckMulti; endrGraphicsDraw;% the main experimental loop% RT = [];money = 0;for runNo = (runsDone +1):numRuns    % after the second run, the experimenter needs to    % restart the computer; this is so that cogniscan will    % not crash    if runNo == 3        stopStr = {'YOU ARE HALFWAY','PLEASE CALL THE EXPERIMENTER'};        for i = 1:length(stopStr)            textwidth = fontsize*length(stopStr{i})/ppd_;            x_pos_stop{i} = -0.3*textwidth;        end             textIdx_Stop = rAdd( ...            'dXtext',   length(stopStr), ...            'visible',  false, ...            'x',        x_pos_stop, ...            'y',        {5 0 }, ...            'size',     fontsize, ...            'font',     'Courier', ...            'color',    contrast_factor*[1 1 1]*255, ...            'string',   stopStr);        rSet( 'dXtext', textIdx_Stop, 'visible', true );        stopkey = 59; % this is the F2 button (see KbName.m)        [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],stopkey);        while KbCheckMulti            WaitSecs(0.002);        end          rSet('dXtext',textIdx_Stop,'visible',false);        rGraphicsDraw;      end        if runNo>1        % introduce the run (only necessary after the first run)        run_str{1} = sprintf ('RUN: %d', runNo);        rSet('dXtext',textIdx_Run,'string',run_str,'visible',true);        spacekey = 44; % Only accept a space as the command to quit:        [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);        while KbCheckMulti            WaitSecs(0.002);        end        rSet('dXtext',textIdx_Run,'visible',false);        rGraphicsDraw;    end      % Decide on the random order of the conditions    % Now just pick a value of 1 or 2 for each of these features:    RSI_row = floor(rand(1)+1.5);    Coh_row = floor(rand(1)+1.5);    Cue_row = floor(rand(1)+1.5);    % The next lines isolate one row from the above data structures. These can    % be indexed by the block-number in the main experiment loop below.    RSI     = RSIs(RSI_row,:);    Shape   = Shapes(RSI_row,:);    coherence   = Cohs(Coh_row,:);    cue_type    = Cues(Cue_row,:);    numblocks   = length(RSI);        if runNo == numRuns        addBlock = 2;    else        addBlock=0;    end    % execute each block    for bl = 1 : numblocks        resting_arrow(numblocks - bl + 1 + addBlock, money, cue_type(bl) );        [STbl, irrelDirbl, ST_timebl, arrow_onsetbl, arrow_durbl, ...            arrow_offsetbl,RTbl, ERbl, RDirbl, PiDirbl, score, ...            premie_t,premie_d] = ...        block ( ...            RSI(bl), RSI_poss,Shape(bl), coherence(bl), ...            coherence_array, cue_type(bl), blockdur, dotsIdx, targetIdx,...            triangleIdx, blackTargetIdx, textIdx_Score, ppd_, lkey,rkey,...            money, salary,wdwPtr, pahandle_correct, pahandle_antic, daq,...            contrast_factor, RT_struct);                ib = length(RT) + 1; %index of the begining of inserted block        ie = length(RT) + length(RTbl);	%index of the end of inserted block        ST(ib:ie) = STbl;        irrelDir(ib:ie) = irrelDirbl;   % Direction of irrelevant motion on arrow trials (will equal ST on motion trials)        ST_time(ib:ie) = ST_timebl;        arrow_onset(ib:ie) = arrow_onsetbl;        arrow_dur(ib:ie) = arrow_durbl;        arrow_offset(ib:ie) = arrow_offsetbl;	        shapeVec(ib:ie) = Shape(bl);        cohVec(ib:ie) = coherence(bl);        cueVec(ib:ie) = cue_type(bl);        RT(ib:ie) = RTbl;        ER(ib:ie) = ERbl;        RDir(ib:ie) = RDirbl;        blocknum(ib:ie) = bl + numblocks*(runNo-1);        trialnum(ib:ie) = 1:length(RTbl);        D(ib:ie) = RSI(bl);        PI(ib:ie) = 0.5;        PiDir(ib:ie) = PiDirbl; % For 50:50 stimuli, this variable is meaningless        Premie_t(ib:ie) = premie_t;        Premie_d(ib:ie) = premie_d;	        money = money + score * salary;    	         if bl==numblocks            runsDone = runsDone + 1;        end        % save the data        if doQuest            save (filename, 'runsDone', 'ST', 'ST_time','RT', 'ER', ...                'RDir', 'blocknum', 'trialnum','D', 'PI','cohVec', ...                'cueVec','shapeVec','PiDir', 'money','Premie_t', ...                'Premie_d', 'contrast_factor','blank_time', ...                'pix_degree_size', 'aperture_diam','pixelsize', ...                'target_diam','black_annulus_diam','ppd_','density', ...                'speed','loops', 'waitdur','blockdur','numblocks', ...                'STpsych','ST_timePsych','RTpsych','ERpsych', ...                'RDirPsych','PiDirPsych','coherence_array', ...                'arrow_onset','arrow_dur','arrow_offset','RSI_poss', ...                'Shape_poss','coherenceVec');             else            save (filename, 'runsDone', 'ST', 'ST_time','RT', 'ER', ...                'RDir', 'blocknum', 'trialnum','D', 'PI','cohVec', ...                'cueVec','shapeVec', 'PiDir', 'money','Premie_t', ...                'Premie_d', 'contrast_factor', 'blank_time', ...                'pix_degree_size', 'aperture_diam','pixelsize', ...                'target_diam','black_annulus_diam','ppd_','density', ...                'speed','loops', 'waitdur','blockdur','numblocks', ...                'coherence_array','arrow_onset','arrow_dur', ...                'arrow_offset','RSI_poss','Shape_poss');            end    endendresting (2, money);%#####################################%####                             ####%#### SIGNAL DETECT SPEED ROUTINE ####%####                             ####%#####################################% Now add in two blocks that test signal detection speed, each of 2.5 minutes% (leading to a total experiment time of 90 minutes):sig_det_instruction(salary);sig_det_resting( 2, money, 'Left' );% 10/27/08: Using the lowest coherence for the signal detection tasks. No% reason -- just have to pick one of the two currently being used.SDdur = 120;[Left_ST, Left_ST_time, Left_RT, Left_ER, score1, Left_premie_t, ...    Left_premie_d] = ...sig_det_block( ...    RSI_poss(1), Shape_poss(1), coherence_array(1), SDdur, 'Left', ...    dotsIdx, targetIdx, blackTargetIdx, textIdx_Score, ppd_, lkey, ...    rkey, money, salary,pahandle_correct, pahandle_antic, daq, ...    contrast_factor); money = money + score1 * salary;sig_det_resting( 1, money, 'Right' );% [Right_ST, Right_ST_time, Right_RT, Right_ER, score2, Right_premie_t, Right_premie_d] = ...% sig_det_block (coherence_array(1), blockdur/2, lkey, ...% rkey, 0.5, money, salary, 1, pahandle_correct, pahandle_antic, 'Right',daq );[Right_ST, Right_ST_time, Right_RT, Right_ER, score2, Right_premie_t, ...    Right_premie_d] = ...sig_det_block( ...    RSI_poss(1), Shape_poss(1), coherence_array(1), SDdur, 'Right', ...    dotsIdx, targetIdx, blackTargetIdx, textIdx_Score, ppd_, lkey, ...    rkey, money, salary,pahandle_correct, pahandle_antic, daq, ...    contrast_factor);money = money + score2 * salary + money_psych*salary;runsDone = 0;%Finishing the experimentif doQuest    save (filename,'runsDone', 'ST', 'ST_time', 'RT', 'ER', 'RDir', ...        'blocknum', 'trialnum', 'D', 'PI', 'PiDir', 'money', 'Left_ST', ...        'Left_ST_time', 'Left_RT', 'Left_ER', 'Left_premie_t', 'cohVec', ...        'cueVec','shapeVec','Left_premie_d', 'Right_ST', 'Right_ST_time', ...        'Right_RT', 'Right_ER', 'Right_premie_t', 'Right_premie_d', ...        'Premie_t', 'Premie_d', 'contrast_factor','blank_time', ...        'pix_degree_size', 'aperture_diam','pixelsize', 'target_diam', ...        'black_annulus_diam','ppd_','density','speed','loops', 'waitdur', ...        'blockdur','numblocks','coherence_array','arrow_onset','arrow_dur', ...        'arrow_offset','RSI_poss','Shape_poss','coherenceVec','STpsych', ...        'ST_timePsych','RTpsych','ERpsych','RDirPsych','PiDirPsych');  else    save (filename,'runsDone', 'ST', 'ST_time', 'RT', 'ER', 'RDir', ...        'blocknum', 'trialnum', 'D', 'PI', 'PiDir', 'money', 'Left_ST', ...        'Left_ST_time', 'Left_RT', 'Left_ER', 'Left_premie_t', 'cohVec', ...        'cueVec','shapeVec','Left_premie_d', 'Right_ST', 'Right_ST_time', ...        'Right_RT', 'Right_ER', 'Right_premie_t', 'Right_premie_d', ...        'Premie_t', 'Premie_d', 'contrast_factor','blank_time', ...        'pix_degree_size', 'aperture_diam','pixelsize', 'target_diam', ...        'black_annulus_diam','ppd_','density','speed','loops', 'waitdur', ...        'blockdur','numblocks','coherence_array','arrow_onset', ...        'arrow_dur','arrow_offset','RSI_poss','Shape_poss');  end% thankyou (money)% opponent_money = thankyou (money, opponent_money, score1+score2, salary, windowptr);% money = 0; opponent_money = 0; salary = 0;rSet('dXdots',dotsIdx,'visible',false);rSet('dXtarget',targetIdx,'visible',false);rSet('dXtarget',blackTargetIdx,'visible',false);rGraphicsDraw;thankyou (money, score1+score2);% Now update the subject order file. By doing this at the end of the% experiment, interrupted sessions are totally ignored, both from the% perspective of the individual subject's order file and for the master% order file that enables counterbalancing of conditions across subjects% and sessions. This means that starting an interrupted session over% again will repeat the block ordering for the subject. Assuming that% interruptions typically happen early in the session because the% experimenter realized he/she made a mistake, this is not too problematic.% But if a power failure happens near the end of a session, they will get% exactly the same ordering the next time they do the session -- but in% that case, the subject will almost certainly want to come back on% another day and will hopefully forget the ordering, so this seems the% best solution for the problem of interruptions.SessionsCompleted = SessionsCompleted + 1;% save( subj_order_file, 'PI_vals', 'D_vals', 'SessionsCompleted' );% save( subj_order_file, 'PermutationList', 'SessionsCompleted' );save( subj_order_file, 'SessionsCompleted' );rDone;% Close the audio device:PsychPortAudio('Close', pahandle_correct);PsychPortAudio('Close', pahandle_antic);return% catch%     Screen('CloseAll');%     %     psychrethrow(psychlasterror);%     rethrow(lasterror);%     PsychPortAudio('Close', pahandle_correct);%     PsychPortAudio('Close', pahandle_antic);%     FlushEvents;% end