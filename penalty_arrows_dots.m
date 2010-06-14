function penalty_semicircle_dots(subject_id,scanner,dots_only,arrows_only,arrows_RT_file)

% function pulsed_dots;
%
% 4/2/09: This function tests the ability of the DotsX code to handle rapid
% onset and offset of dot display within a trial, as well as rapid shifting
% of coherence within a trial.
%
% 4/9/09: Adding two blocks without pulses, and with very low coherence.
%
% 4/13/09: This version of pulsed_dots2.m gets rid of the pulsing and
% simply focuses on the effect of low coherence and varying reward/penalty
% payoffs for achieving long RTs and reasonable accuracies. It begins with
% a pot of money that can be decremented down to 0. Maybe when they hit 0,
% it should be a reflecting boundary, so that you can't go deep in the
% hole.
%
% 7/18/09: Now modifying this code to incorporate the dots vs. arrows
% design, but with a semicircle instead of an arrow to indicate signal
% detection responding. BTW, we should probably just use a semicircle
% 'Signal detection' task to get the RTs for arrows -- it's not really
% signal detection after all, but choice among two salient options. I think
% we now need 4 4-minute blocks, 2 of which are dots, and 2 of which are
% semicircles. We could however, do scans with only dots as well, so I'll
% make a flag argument for only dots: 'dots_only'.
%
% 8/07/09: OK, semicircles leave an awful after-image, and they also
% encourage looking at the outside circle/semicircle rather than the dots.
% So we're back to arrows as the control task. We are also now combining
% arrows, long RSIs, and most importantly, penalties, in one experiment.
% That means we need to lengthen blocks to 4 minutes, as described above.
% We need one arrows block with RTs selected from the preceding dots block.
% Thus, although coherence is zero in both arrows blocks, the arrow-onset
% times will be different on average in the two arrows blocks. Oh, also,
% now the arrows will be much smaller to fit within
%
% 8/10/09: 'arrows_only' allows for two blocks of only arrows. If only
% arrows are present, then there will be no RTs to select from a dots
% block. So we need to create fake RTs for arrow onset times.





if nargin < 2
    scanner = 0;    % Default to behavioral keycodes instead of fMRI button-box codes
end

if nargin < 3       % Default to dots and arrows both, rather than just dots
    dots_only = 0;
end

if nargin < 4
    arrows_only = 0; 
end


% Now load up a file of RTs from a previous session of arrows-only trials,
% to use in determining the arrow onset times in this session:
if nargin > 4
    load(arrows_RT_file);
    arrow_idx = find(DataStruct.ArrowTrial);
    arrowsRT = median( DataStruct.RT(arrow_idx) - DataStruct.ArrowOnsets(arrow_idx) );
    clear DataStruct;
else
    arrowsRT = 400;
end

DataStruct.scanner = scanner;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE Screen and DotsX objects:
% Screen('Preference','SkipSyncTests')
% rInit('local'); % 7/16/07 -- shifting to DotsX code
rInit({'screenMode', 'local', 'showWarnings', true});
% Screen('Preference','SkipSyncTests')

% 7/19/08: need access to the window pointer for freeze-framing dots.
wdwPtr = rWinPtr;



% Get window dimensions to allow a big red screen to flash upon
% anticipatory responses:
[w_width, w_height]=WindowSize(wdwPtr);
antic_rect_X = [0; 0; w_width; w_width];
antic_rect_Y = [0; w_height; w_height; 0];
antic_rect = [antic_rect_X, antic_rect_Y];




% Also initialize the KbCheck routine:
KbCheckMulti;                   % Initialize keyboard check routine



% Get new random number generator initializations:
rand ('state', sum(100*clock));
randn ('state', sum(100*clock));




% DEFINE THE BASIC STIMULUS OBJECTS IN DOTSX:

ppd_ = rGet('dXscreen', 1, 'pixelsPerDegree');

% Dots features from motion_localizer_translational.m:
contrast_factor = 1;   % The percentage of 256 for color saturation (0.1 used in fixed-viewing version)
blank_time = 1000;      % 1000 msec blank time at the end
blank_time = 2000;
blank_time = 10000;     % 2/9/2009: 10 second blank time at end
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

% coherence = 6;
% coherence = 12;
coherence = 25; % Need to initialize the dots object just below to some coherence, although this value will change later

% The black target imitates the annulus idea in the Kastner lab motion
% localizer code, presumably to prevent tracking of individual dots
% that move through the fixation point.
% Apparently, adding the triangle fixation point before the black target is
% critical for having the triangle displayed on top of the black target (I
% think). Interestingly, it's OK to add the circular white target AFTER the
% black target to get the white target to show up.
triangleIdx = rAdd('dXpolygon', 1, 'visible', false, ...
    'color', contrast_factor*[255 255 255], ...
    'pointList', 0.65*target_diam*[-1 1; 1 1; 0 -1]);
leftArrowIdx = rAdd('dXpolygon', 1, 'visible', false, ...
    'color', contrast_factor*[255 255 0], ...
    'pointList', target_diam*[-1 0; 0 -1; 0 -0.5; 1 -0.5; 1 0.5; 0 0.5; 0 1]);
rightArrowIdx = rAdd('dXpolygon', 1, 'visible', false, ...
    'color', contrast_factor*[255 255 0], ...
    'pointList', target_diam*[1 0; 0 -1; 0 -0.5; -1 -0.5; -1 0.5; 0 0.5; 0 1]);
blackTargetIdx = rAdd('dXtarget', 1, 'color', contrast_factor*[0 0 0],'penWidth',24,'diameter',black_annulus_diam,'visible',false);
% add some dots and a target
targetIdx = rAdd('dXtarget', 1, 'color', contrast_factor*[255 255 255],'penWidth',24,'diameter',target_diam,'visible',false);
dotsIdx = rAdd('dXdots', 1, 'color', contrast_factor*[255 255 255], 'direction',0,'coherence',coherence,...
    'diameter',aperture_diam,'size',pixelsize,'loops',loops,'density',density,'speed',speed,'lifetimeMode','random', ...
    'visible',false);




% num_blocks = 1;

num_trials = 5;
num_trials = 500;





% Define Responses:
% Press Z for left, M for right:
if ~scanner
    keys = [ KbName('Z'), KbName('M') ];
else
    keys = [ KbName('9('), KbName('6^') ];  % 2/4/2009: Inverting mapping for new button box, which you have to hold upside down
    % 4/22/09: for M08MA020782, switching to single-handed responding:
    %     keys = [ KbName('4$'), KbName('3#') ];  % 2/4/2009: Inverting mapping for new button box, which you have to hold upside down
end
lkey = keys(1);
rkey = keys(2);






Score = 0;      % Initialize cumulative score to 0

Score = 5;     % 4/13/09: Start them out at $10.00


% Set Screen preferences regarding font sizes for reward feedback:
if ~scanner
    Screen('TextFont',wdwPtr, 'Arial');
    Screen('TextSize',wdwPtr, 50);
else
    Screen('TextFont',wdwPtr, 'Arial');
    Screen('TextSize',wdwPtr, 25);
end




% Define the RSI and Block statistics:
RSI_mean = 5;    % 5 second RSI average
RSI_shape = 5;
RSI_scale = RSI_mean/RSI_shape;

RestDuration = 30;
EndBlankTime = 10;

if ~scanner
    BlockDuration = 4*60;   % 4 minute block duration
else
    %     BlockDuration = 2*60;
    % 7/19/09: Making 4 minute blocks in the scanner now too
    BlockDuration = 4*60;
end
% For debugging
BlockDuration = 20;
RestDuration = 2;
EndBlankTime = 2;


DataStruct.RestDuration = RestDuration;
DataStruct.EndBlankTime = EndBlankTime;

% coherence = [ 12 25 ];
% Reward = 0.01;  % 5 cents for every correct, -5 for every error
% Penalty = 0;

InstructionDuration = 2;    % Don't display the stimulus for the entire RSI
DataStruct.InstructionDuration = InstructionDuration;


% Data structure for saving the data:
DataStruct.RT = [];
DataStruct.ER = [];
DataStruct.Score = [];
DataStruct.Coherence = [];
DataStruct.RSI = [];
DataStruct.RSI_mean = RSI_mean;
DataStruct.RSI_shape = RSI_shape;
DataStruct.VisibilityFlag = [];
DataStruct.CoherenceFlag = [];
DataStruct.IncreasingDurationFlag = [];
DataStruct.Stimulus = [];
DataStruct.BlockNumber = [];
DataStruct.TrialNumber = [];

DataStruct.RewardMagnitude = [];
DataStruct.PenaltyMagnitude = [];

DataStruct.ArrowTrial = [];

DataStruct.BlockStartTime = [];
DataStruct.BlockEndTime = [];
DataStruct.TrialStartTime = [];

DataStruct.contrast_factor = contrast_factor;   % The percentage of 256 for color saturation (0.1 used in fixed-viewing version)
DataStruct.blank_time = blank_time;     % 2/9/2009: 10 second blank time at end
DataStruct.pix_degree_size = pix_degree_size;  % This sets pixels to .15 degrees visual angle for a given screen
DataStruct.aperture_diam = aperture_diam;     % Degrees covered by aperture
DataStruct.target_diam = target_diam;      % Degrees covered by target
DataStruct.black_annulus_diam = black_annulus_diam;     % A black target behind the visible target for preventing dot-tracking at fixation
DataStruct.pixelsize = pixelsize;
DataStruct.density = density;           % dots/degree^2 Downing-Movshon says dots/degree^2/sec -- I don't get why sec is relevant
DataStruct.speed = speed;              % Dot-speed in deg/sec
DataStruct.loops = loops;              % A low-level drawing feature of DotsX code
DataStruct.motion_dur = motion_dur;       % Motion stimulus duration in msec (fixed viewing time)
DataStruct.BlockDuration = BlockDuration;

DataStruct.ArrowOnsets = [ ];   % Save arrow onset times (set to inf if not an arrows block)
DataStruct.PrematureOnTrial = [ ];  % 8/10/09: An array of trial numbers indicating trials on which one or more anticipatory responses occurred
DataStruct.PrematureOnBlock = [ ];  % Indicates which block the premature trial was in
DataStruct.PrematureRT = [ ];


spacekey = KbName('SPACE');

ExperimentStartTime = GetSecs;
DataStruct.ExperimentStartTime = ExperimentStartTime;

% coh = [ 12 25 ];
coh = [6 12];
% Subject 21177:
coh = [1.5 2.5];
coh = [2 2];    % Subject 21177
coh = [2 4];  % Subject 21177
% % % Subject 72:
% coh = [3 6];
% coh = [4 7];
% coh = [2 4];
coh = [3 5];

coh = [ 5 8 ];
% coherence_array = [ coh(1) coh(2) coh(2) coh(1) coh(2) coh(1) coh(1) coh(2) ];

% % 7/18/09: Now using an alternating pattern of dots, semicircle (the new
% % replacement for arrows), dots, semicircle. Coherence should be set to 0
% % on every semicircle block. Randomize ordering of the two coherence
% % levels, as long as they have the pattern of dots/semicircles that
% coherence_array = [ coh(1) 0 0 coh(2) coh(1) 0 0 coh(2) ];
%
% Also, we probably don't need as much semicircle data. Leigh will say that
% we need the same amount of dots and semicircles to do contrasts I bet.
% But at long RSIs, and long RTs, 2 minute blocks are not long enough. I
% think they have to be 4 minutes long. But then Leigh won't like the
% susceptibility of the design to low-frequency scanner drift. I see no way
% around it:
idx = randperm(2);
coherence_array = [ coh(idx(1)) 0 coh(idx(2)) 0 ];
if arrows_only
    coherence_array = [ 0 0 ];
end


% 8/07/09: Determine which blocks are pure dots and which involve arrows:
if ~dots_only
    arrows_array = [ 0 1 0 1 ];
else
    arrows_array = [ 0 0 0 0 ];
end
if arrows_only
    arrows_array = [ 1 1 ];
end
DataStruct.arrows_array = arrows_array;


num_blocks = 4;
if arrows_only
    num_blocks = 2;
end


Reward = .01;
% Penalty = [ .01 .02 ];  % Subject 21177
% Penalty = [ .01 .03 ];  % Subject 72
% Penalty = [ .02 .02 ];  % Subject 21177
Penalty = 0.02;
% Reward_array = Reward*ones(1,8);
Reward_array = Reward*ones(1,4);
if arrows_only
    Reward_array = Reward*[1 1];
end
% % Mimicking visibility_array's arrangement:
% Penalty_array = [ Penalty(1) Penalty(2) Penalty(1) Penalty(2) Penalty(2) Penalty(1) Penalty(2) Penalty(1) ];

Penalty_array = Penalty*ones(1,4);
if arrows_only
    Penalty_array = Penalty*[1 1];
end




% Get window dimensions to allow a big red screen to flash upon
% anticipatory responses:
[w_width, w_height]=WindowSize(wdwPtr);
antic_rect_X = [0; 0; w_width; w_width];
antic_rect_Y = [0; w_height; w_height; 0];
antic_rect = [antic_rect_X, antic_rect_Y];





if ~scanner
    % NEW INSTRUCTIONS FOR penalty_dots.m:
    % Intro instructions:
    % Display instructions and enforce the rest period:
    str = 'DOTS   DOTS   DOTS\n\nPress Z for leftward motion, M for rightward motion.\n\n';
    str = [str, sprintf('Rewards for corrects: $%1.2f\n\nPenalties for errors: -$%1.2f\n\n',Reward,Penalty) ];
    str = [str, sprintf('You''ll begin with $%1.2f on top of show-up.\n\n',Score) ];
    DrawFormattedText( wdwPtr, [str,'Press the Space key when \n you are ready to continue.'], 'center', 'center', [255 255 255], 0 );
    Screen('Flip',wdwPtr);
    while true
        %     [ keyIsDown, secs, keyCode, deltaSecs ] = KbCheck;
        [ keyIsDown, secs, keyCode ] = KbCheckMulti;
        if keyIsDown
            if find(keyCode) == spacekey
                break;
            end
        end
        WaitSecs(0.004);
    end
    % KbWait;
    % while KbCheck; end; % I assume this line absorbs continuous key pressing
    Screen('FillRect',wdwPtr,[0 0 0]); %NNO shouldn't we have a mask here?
    Screen('Flip',wdwPtr);

    WaitSecs(0.2);  % No idea why, but the first trial of every increasing_duration block has crazy short RTs.
end



% Get a filename for saving data:
idx=0;
logfn='foofoofoofoofoofoofoo';
while idx < 1 || exist(logfn) %make subsequent log files with postfix _0, _1, etc
    logfn = sprintf('penalty_arrows_dots_subject%d_ses%d.mat',subject_id,idx);
    %     logfn=sprintf('logGoodGuysBadGuys_%s_%d.mat',subjid_str,idx);
    idx=idx+1;
end



if scanner
    % Wait for scanner trigger if this is an fMRI session:
    triggercode = KbName('LEFTSHIFT');  % Nope, LEFTSHIFT instead of !
    % Wait for scanner trigger:
    while 1
        %         while KbCheckMulti; end
        [ keyIsDown, seconds, keyCode ] = KbCheckMulti;
        %     [ keyIsDown, seconds, keyCode ] = KbCheck;
        if keyIsDown
            if keyCode(triggercode)
                TriggerTime = GetSecs;
                DataStruct.TriggerTime = TriggerTime;
                break
            end
        end
        %         WaitSecs(0.02);
    end
else
    DataStruct.TriggerTime = GetSecs;
end




for i = 1 : num_blocks

    coherence = coherence_array(i);
%     coherence_flag = ~visibility_flag;
    coherence_flag = 1;

    Reward = Reward_array(i);
    Penalty = Penalty_array(i);



    % Display instructions and enforce the rest period:
    str = sprintf('%d blocks to go. \n\n Current Score: $%1.2f \n\n',num_blocks - i + 1,Score);
    %     str = [str, sprintf('New reward for correct: $%1.2f\n\nNew penalty for error: -$%1.2f\n\n',Reward,Penalty)];
    str = [str, sprintf('Reward for correct: $%1.2f\n\nPenalty for error: -$%1.2f\n\n',Reward,Penalty)];
    if scanner
        DrawFormattedText( wdwPtr, str, 'center', 'center', [255 255 255], 0 );
        Screen('Flip',wdwPtr);

        %         WaitSecs(RestDuration);  % Display instructions during rest period inside the scanner.
        % 7/19/09: For debugging, slowing down the rest duration:
        WaitSecs(2);
        Screen('FillRect',wdwPtr,[0 0 0]);
        Screen('Flip',wdwPtr);
    else
        DrawFormattedText( wdwPtr, [str,'Press the Space key when \n you are ready to continue.'], 'center', 'center', [255 255 255], 0 );

        Screen('Flip',wdwPtr);
        while true
            %         [ keyIsDown, secs, keyCode, deltaSecs ] = KbCheck;
            [ keyIsDown, secs, keyCode ] = KbCheckMulti;
            if keyIsDown
                if find(keyCode) == spacekey
                    break;
                end
            end
            WaitSecs(0.004);
        end
        % KbWait;
        % while KbCheck; end; % I assume this line absorbs continuous key pressing
        Screen('FillRect',wdwPtr,[0 0 0]); %NNO shouldn't we have a mask here?
        Screen('Flip',wdwPtr);

        WaitSecs(0.2);  % No idea why, but the first trial of every increasing_duration block has crazy short RTs.
    end



    BlockStartTime = GetSecs;
    DataStruct.BlockStartTime(end+1) = BlockStartTime-ExperimentStartTime;


    
    % 8/07/09: OK, if a new block is starting that involves arrows, select
    % a bunch of arrow onset times from the RTs in the previous block
    % (which is assumed to be a dots block).
    if ~arrows_only
        if arrows_array(i)
            arrow_onset_times = DataStruct.RT(find(DataStruct.BlockNumber == i-1)) - arrowsRT;
            arrow_onset_times = repmat(arrow_onset_times,1,3); % Boost total number of RTs so that we don't run out of RTs to use
            arrow_onset_times = arrow_onset_times(randperm(length(arrow_onset_times)));
        end
    else
        arrow_onset_times = max(0.1,gamrnd(RSI_shape*ones(1,500),RSI_mean/RSI_shape)); 
        % Gives onset times like RSIs, with mean equal to RSI_mean, and a bigger shape parameter makes it more narrow & normal
    end
    
    
    
    % Loop over trials within a block:
    for j = 1 : num_trials

        % Terminate block if it has almost exceeded the BlockDuration:
        tmp_time = GetSecs;
        if tmp_time - BlockStartTime + RSI_mean > BlockDuration
            DataStruct.BlockEndTime(end+1) = tmp_time-ExperimentStartTime;
            break
        end

        if coherence_flag
            DataStruct.CoherenceFlag(end+1) = 1;
        else
            DataStruct.CoherenceFlag(end+1) = 0;
        end

        DataStruct.Coherence(end+1) = coherence;
        DataStruct.BlockNumber(end+1) = i;
        DataStruct.TrialNumber(end+1) = j;
        DataStruct.RewardMagnitude(end+1) = Reward;
        DataStruct.PenaltyMagnitude(end+1) = Penalty;
        if arrows_array(i)
            DataStruct.ArrowOnsets = [ DataStruct.ArrowOnsets, arrow_onset_times(j) ];
        else
            DataStruct.ArrowOnsets = [ DataStruct.ArrowOnsets, inf ];
        end
            
        % Pick a trial's motion direction randomly:
        if rand(1) < 0.5
            direc = 0;
            DataStruct.Stimulus(end+1) = 'R';
        else
            direc = 180;
            DataStruct.Stimulus(end+1) = 'L';
        end

        TrialStartTime = GetSecs;
        DataStruct.TrialStartTime(end+1) = TrialStartTime;


        tmp_code = [];  % Initialize the keypress code variable to empty



        
        rSet('dXdots',dotsIdx,'coherence',coherence);

        rSet('dXdots',dotsIdx,'direction',direc,'visible',true);
        if arrows_array(i) == 0
            rSet('dXtarget',targetIdx,'visible',true);
            rSet('dXpolygon',triangleIdx,'visible',false);
        else
            rSet('dXtarget',targetIdx,'visible',false);
            rSet('dXpolygon',triangleIdx,'visible',true);
        end
        rSet('dXtarget',blackTargetIdx,'visible',true);


        

        abort_trial = 0;    % Flag for aborting trial after anticipatory response
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % PRESENT THE STIMULUS:
        ramp_flag = 1;
        DataStruct.ramp_flag = ramp_flag;
        
        if arrows_array(i)
            DataStruct.ArrowTrial(end+1) = 1;
            if ramp_flag
                % Rapidly ramp up the dot contrast if ramp flag set:
                rSet('dXdots',dotsIdx,'color',0.05*[255 255 255]);
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.034,[],[lkey rkey]);
                rSet('dXdots',dotsIdx,'color',0.1*[255 255 255]);
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.034,[],[lkey rkey]);
                rSet('dXdots',dotsIdx,'color',0.2*[255 255 255]);
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.034,[],[lkey rkey]);
                rSet('dXdots',dotsIdx,'color',0.4*[255 255 255]);
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.034,[],[lkey rkey]);
                rSet('dXdots',dotsIdx,'color',[255 255 255]);
            end
            %             [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*arrow_onset_times(j),[],[lkey rkey]); % Need times in msec, not sec
            DotsStartTime = GetSecs;
            while true
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*arrow_onset_times(j),[],[lkey rkey]);

                tmp_code = find(myKeyCode,1);
                % 8/10/09:
                % Throw in a check for premature responding here.
                if ~isempty(tmp_code)
                    DataStruct.PrematureOnTrial = [ DataStruct.PrematureOnTrial, j ];
                    DataStruct.PrematureOnBlock = [ DataStruct.PrematureOnBlock, i ];
                    PrematureRT = mySecs - DotsStartTime;
                    DataStruct.PrematureRT = [ DataStruct.PrematureRT, PrematureRT ];
                    % Try flashing a red rectangle now:
                    Screen('FillPoly', wdwPtr, [255 0 0], antic_rect);
                    DrawFormattedText( wdwPtr, 'PENALTY DELAY \n\n WAIT UNTIL STIMULUS APPEARS', 'center', 'center', [255 255 255], 0 );
                    Screen('Flip', wdwPtr);
                    WaitSecs(2);
                    Screen('FillPoly', wdwPtr, [0 0 0], antic_rect);
                    Screen('Flip', wdwPtr);
                    rSet('dXdots',dotsIdx,'visible',false);
                    rSet('dXpolygon',triangleIdx,'visible',true);
                    rGraphicsDraw;
                    WaitSecs(4);
                    abort_trial = 1;
                else
                    break   % 8/10/09: OK, no premature response made, so continue with the trial 
                end
            end

            
            % If anticipatory response occurs, then abort trial, save
            % placeholder data to keep all the data arrays the same length,
            % and go on to the next trial:
            if abort_trial
                DataStruct.RT(end+1) = inf;
                DataStruct.ER(end+1) = inf;
                DataStruct.Score(end+1) = Score;
                DataStruct.RSI(end+1) = inf;
                continue
            end
            
            
            if direc == 180
                rSet('dXpolygon',leftArrowIdx,'visible',true);
                rSet('dXpolygon',rightArrowIdx,'visible',false);
            else
                rSet('dXpolygon',leftArrowIdx,'visible',false);
                rSet('dXpolygon',rightArrowIdx,'visible',true);
            end
            rSet('dXpolygon',triangleIdx,'visible',false);
            [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],[lkey rkey]);
            rSet('dXpolygon',leftArrowIdx,'visible',false);
            rSet('dXpolygon',rightArrowIdx,'visible',false);
            rSet('dXpolygon',triangleIdx,'visible',true);
        else
            DataStruct.ArrowTrial(end+1) = 0;
            if ramp_flag
                % Rapidly ramp up the dot contrast if ramp flag set:
                rSet('dXdots',dotsIdx,'color',0.05*[255 255 255]);
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.034,[],[lkey rkey]);
                rSet('dXdots',dotsIdx,'color',0.1*[255 255 255]);
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.034,[],[lkey rkey]);
                rSet('dXdots',dotsIdx,'color',0.2*[255 255 255]);
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.034,[],[lkey rkey]);
                rSet('dXdots',dotsIdx,'color',0.4*[255 255 255]);
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.034,[],[lkey rkey]);
                rSet('dXdots',dotsIdx,'color',[255 255 255]);
            end
            [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],[lkey rkey]);
        end
        tmp_code = find(myKeyCode,1);
        if ~isempty(tmp_code)
            DataStruct.RT(end+1) = mySecs - TrialStartTime;


            % 8/10/09: 
            % Throw in a check for premature responding here. 
            if DataStruct.RT(end) < 0.1
                
                % Try flashing a red rectangle now:
                Screen('FillPoly', wdwPtr, [255 0 0], antic_rect);
                DrawFormattedText( wdwPtr, [str,'PENALTY DELAY \n\n WAIT UNTIL STIMULUS APPEARS'], 'center', 'center', [255 255 255], 0 );
                Screen('Flip', wdwPtr);
                WaitSecs(2);
                Screen('FillPoly', wdwPtr, [0 0 0], antic_rect);
                Screen('Flip', wdwPtr);
                rSet('dXdots',dotsIdx,'visible',false);
                if arrows_array(i)
                    rSet('dXpolygon',triangleIdx,'visible',true);
                    rSet('dXpolygon',leftArrowIdx,'visible',false);
                    rSet('dXpolygon',rightArrowIdx,'visible',false);
                else
                    rSet('dXpolygon',targetIdx,'visible',true);
                    rSet('dXpolygon',leftArrowIdx,'visible',false);
                    rSet('dXpolygon',rightArrowIdx,'visible',false);
                end
                rGraphicsDraw;
                WaitSecs(4);
                % If anticipatory response occurs, then abort trial, save
                % placeholder data to keep all the data arrays the same length,
                % and go on to the next trial:
                DataStruct.RT(end+1) = inf;
                DataStruct.ER(end+1) = inf;
                DataStruct.Score(end+1) = Score;
                DataStruct.RSI(end+1) = inf;
                continue
            end
            
            
            % Compute error/correct feedback and store accuracy data:
            if tmp_code==lkey
                if direc==180
                    % Flash green for correct:
                    %                         rSet('dXtarget',targetIdx,'color',[0 255 0]);
                    %                         ER(j) = 0;
                    DataStruct.ER(end+1) = 0;
                    Score = Score + Reward;
                    DataStruct.Score(end+1) = Score;
                    %                         Reward(j+1) = max(0.01,min(1,Reward(j)*(1+rwd_factor_delta)));
                    rSet('dXdots',dotsIdx,'visible',false);
                    rGraphicsDraw;


                    DrawFormattedText( wdwPtr, sprintf('CORRECT \n\n +$%1.2f \n\n Total: $%1.2f', Reward, Score ), 'center', 'center', [0 255 0], 0 );
                    Screen('Flip',wdwPtr);
                    WaitSecs(InstructionDuration);
                    rGraphicsDraw;
                    %                         Screen('FillPoly', wdwPtr, 0.2*[0 255 0], antic_rect);


                else
                    % Flash red for error:
                    %                         rSet('dXtarget',targetIdx,'color',[255 0 0]);
                    %                         ER(j) = 1;
                    DataStruct.ER(end+1) = 1;
                    %                         Reward(j+1) = max(0.01,min(1,Reward(j)*(1-rwd_factor_delta)));
                    %                         Score = Score - Reward;
                    %                         Score = Score - Penalty;
                    Score = max(0,Score - Penalty);
                    DataStruct.Score(end+1) = Score;
                    rSet('dXdots',dotsIdx,'visible',false);
                    rGraphicsDraw;



                    DrawFormattedText( wdwPtr, sprintf('ERROR \n\n -$%1.2f \n\n Total: $%1.2f', Penalty, Score ), 'center', 'center', [255 0 0], 0 );
                    Screen('Flip',wdwPtr);
                    WaitSecs(InstructionDuration);
                    rGraphicsDraw;
                end

                
            elseif tmp_code==rkey
                if direc==0
                    % Flash green for correct:
                    %                         rSet('dXtarget',targetIdx,'color',[0 255 0]);
                    DataStruct.ER(end+1) = 0;
                    Score = Score + Reward;
                    DataStruct.Score(end+1) = Score;
                    %                         Reward(j+1) = max(0.01,min(1,Reward(j)*(1+rwd_factor_delta)));
                    rSet('dXdots',dotsIdx,'visible',false);
                    rGraphicsDraw;
                    DrawFormattedText( wdwPtr, sprintf('CORRECT \n\n +$%1.2f \n\n Total: $%1.2f', Reward, Score ), 'center', 'center', [0 255 0], 0 );
                    Screen('Flip',wdwPtr);
                    WaitSecs(InstructionDuration);
                    rGraphicsDraw;
                else
                    % Flash red for error:
                    %                         rSet('dXtarget',targetIdx,'color',[255 0 0]);
                    DataStruct.ER(end+1) = 1;
                    %                         Score = Score - Reward;
                    %                         Score = Score - Penalty;
                    Score = max(0,Score - Penalty);
                    DataStruct.Score(end+1) = Score;
                    %                         Reward(j+1) = max(0.01,min(1,Reward(j)*(1-rwd_factor_delta)));
                    rSet('dXdots',dotsIdx,'visible',false);
                    rGraphicsDraw;
                    DrawFormattedText( wdwPtr, sprintf('ERROR \n\n -$%1.2f \n\n Total: $%1.2f', Penalty, Score ), 'center', 'center', [255 0 0], 0 );
                    Screen('Flip',wdwPtr);
                    WaitSecs(InstructionDuration);
                    rGraphicsDraw;
                end

            end
            
            
            % Define an RSI and enforce it:
            %                     tmp_RSI = RSI + rand(1);
            tmp_RSI = max(0.1,gamrnd(RSI_shape,RSI_mean/RSI_shape)-InstructionDuration); % Gives an RSI with mean equal to RSI_mean, and a bigger shape parameter makes it more narrow & normal
            %                 WaitSecs(tmp_RSI);
            DataStruct.RSI(end+1) = tmp_RSI;
            rSet('dXtarget',targetIdx,'color',[255 255 255]);
            rGraphicsDraw;
            RSIStartTime = GetSecs;
            while true
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*tmp_RSI,[],[lkey rkey]);

                tmp_code = find(myKeyCode,1);
                % 8/10/09:
                % Throw in a check for premature responding here.
                if ~isempty(tmp_code)
                    DataStruct.PrematureOnTrial = [ DataStruct.PrematureOnTrial, j ];
                    DataStruct.PrematureOnBlock = [ DataStruct.PrematureOnBlock, i ];
                    PrematureRT = mySecs - RSIStartTime;
                    % Try flashing a red rectangle now:
                    Screen('FillPoly', wdwPtr, [255 0 0], antic_rect);
                    DrawFormattedText( wdwPtr, 'PENALTY DELAY \n\n WAIT UNTIL STIMULUS APPEARS', 'center', 'center', [255 255 255], 0 );
                    Screen('Flip', wdwPtr);
                    WaitSecs(2);
                    Screen('FillPoly', wdwPtr, [0 0 0], antic_rect);
                    Screen('Flip', wdwPtr);
                    if arrows_array(i)
                        rSet('dXpolygon',triangleIdx,'visible',true);
                        rSet('dXpolygon',leftArrowIdx,'visible',false);
                        rSet('dXpolygon',rightArrowIdx,'visible',false);
                    else
                        rSet('dXpolygon',targetIdx,'visible',true);
                        rSet('dXpolygon',leftArrowIdx,'visible',false);
                        rSet('dXpolygon',rightArrowIdx,'visible',false);
                    end
                    rGraphicsDraw;
                    WaitSecs(4);
                else
                    break
                end
            end

        end
        % End of accuracy computation if-else



    end
    % End of trial loop

    fprintf('Saving log file as %s', logfn);
    save(logfn,'DataStruct');
    fprintf(' ... completed.\n');

end
% End of block loop



% THANK YOU:
% Display instructions and enforce the rest period:
if Score > 0
    str = 'Best performance I''ve ever seen!\n\n';
else
    str = 'Ouch. We''ll have to tweak the task parameters.\n\n';
end
str = [str, sprintf( 'You earned: $%1.2f.\n\n', Score )];
str = [str, 'Thank you! Come again!'];
DrawFormattedText( wdwPtr, str, 'center', 'center', [255 255 255], 0 );
Screen('Flip',wdwPtr);
if scanner
    WaitSecs(EndBlankTime);
else
    while true
        %     [ keyIsDown, secs, keyCode, deltaSecs ] = KbCheck;
        [ keyIsDown, secs, keyCode ] = KbCheckMulti;
        if keyIsDown
            if find(keyCode) == spacekey
                break;
            end
        end
        WaitSecs(0.004);
    end
end


rDone;


% save(sprintf('Subject%d_Data',subject_id),'DataStruct');

keyboard
