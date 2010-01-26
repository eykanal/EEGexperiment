function pulsed_dots(subject_id,scanner)

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


if nargin < 2
    scanner = 0;    % Default to behavioral keycodes instead of fMRI button-box codes
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
blackTargetIdx = rAdd('dXtarget', 1, 'color', contrast_factor*[0 0 0],'penWidth',24,'diameter',black_annulus_diam,'visible',false);
% add some dots and a target
targetIdx = rAdd('dXtarget', 1, 'color', contrast_factor*[255 255 255],'penWidth',24,'diameter',target_diam,'visible',false);
dotsIdx = rAdd('dXdots', 1, 'color', contrast_factor*[255 255 255], 'direction',0,'coherence',coherence,...
    'diameter',aperture_diam,'size',pixelsize,'loops',loops,'density',density,'speed',speed,'lifetimeMode','random', ...
    'visible',false);




% num_blocks = 1;

num_trials = 5;
num_trials = 500;




% Mini-window definition code:
mini_window_duration = 14*0.016666;    % 250 msec mini-window used for intermittent display of dots
% mini_window_duration = 0.5;    % 250 msec mini-window used for intermittent display of dots
mini_window_duration = 2*14*0.016666;    % 500 msec mini-window used for intermittent display of dots
mini_window_duration = 2*2*14*0.016666;    % 1000 msec mini-window used for intermittent display of dots

proportion_delta = 0.02;         % Divide mini-window into little segments, and display dots during the first segment or n segments
num_display_deltas = 6;     % Number of segments to display during fixed visibility-proportion mini-windows
proportion_delta = 0.04;
% For debugging the reason that initial trials in the increasing_duration
% blocks have 50 msec RTs:
% proportion_delta = 0.07;
% proportion_delta = 0.2;

num_display_deltas = 4;
% num_display_deltas = 1;

% Save in the Data structure that gets saved during the experiment:
DataStruct.proportion_delta = proportion_delta;
DataStruct.num_display_deltas = num_display_deltas;
DataStruct.mini_window_duration = mini_window_duration;

num_divisions = sum(1:1/proportion_delta); % Maximum number of mini-windows (last one can go for eternity)



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




% The following important parameters are now set by an array of task
% conditions below:
%
% visibility_flag = 1;    % Turn coherent dots ON and OFF during a trial
% 
% coherence_flag = 0;     % Turn coherence UP and DOWN (to 0) during a trial
% 
% increasing_duration_flag = 0;
% 
% ramp_flag = 0;



% That's too much. Leigh suggests we simply penalize for errors, reward for
% corrects. But just in case, and so I can remember, here's the idea:
%
% % Try a growing reward magnitude to incentivize extreme accuracy emphasis.
% % Multiply the current reward magnitude by some factor greater than 1 after
% % every correct, and by a factor of less than 1 after every error. Have to
% % cap at a reasonable maximum, otherwise you could earn thousands of
% % dollars (let's say a max of $1 per correct response).
% rwd_factor_delta = 0.25;
% init_rwd = 0.05;   % Start with 1 cent reward




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
    BlockDuration = 2*60;
end
% % For debugging
% % BlockDuration = 25; 
% BlockDuration = 6;
% RestDuration = 2;



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


spacekey = KbName('SPACE');

ExperimentStartTime = GetSecs;
DataStruct.ExperimentStartTime = ExperimentStartTime;

% coh = [ 12 25 ];
coh = [6 12];
% Subject 21177:
coh = [1.5 2.5];
coh = [2 2];    % Subject 21177
coh = [2 4];  % Subject 21177
coh = [4 8]; % subject 21279
% % % Subject 72:
% coh = [3 6];
% coh = [4 7];
% coh = [2 4];
coh = [3 5];
coherence_array = [ coh(1) coh(2) coh(2) coh(1) coh(2) coh(1) coh(1) coh(2) ];
visibility_array = [ 1 0 1 0 0 1 0 1 ];
% % Reduce coherences in the visibility conditions:
% coherence_array(find(visibility_array)) = coherence_array(find(visibility_array))/2;
increasing_duration_array = [ 1 0 0 1 0 1 1 0 ];

num_blocks = 8;
ramp_flag = 0;


Reward = .01;
Penalty = [ .01 .02 ];  % Subject 21177 
Penalty = [ .01 .03 ];  % Subject 72
Penalty = [ .02 .02 ];  % Subject 21177
Reward_array = Reward*ones(1,8);
% Mimicking visibility_array's arrangement:
Penalty_array = [ Penalty(1) Penalty(2) Penalty(1) Penalty(2) Penalty(2) Penalty(1) Penalty(2) Penalty(1) ];


% % 4/9/09: Adding two more blocks without pulses
% coherence_array = [coherence_array, 2, 1];
% visibility_array = [visibility_array, 0, 0];
% increasing_duration_array = [increasing_duration_array, 0, 0];
% num_blocks = 10;
DataStruct.NoPulse = [];    % Indicate whether you turned pulsing off




% increasing_duration_array = [ 0 0 0 0 0 0 0 0 ];
% visibility_array = [ 1 1 1 1 1 1 1 1 ];



% % Intro instructions:
% % Display instructions and enforce the rest period:
% str = 'DOTS DOTS DOTS\n\nPress Z for leftward motion, M for rightward motion.\n\n';
% str = [str, sprintf('Rewards for corrects: $%1.2f\n\nPenalties for errors: -$%1.2f\n\n',Reward,Penalty) ];
% DrawFormattedText( wdwPtr, [str,'Press the Space key when \n you are ready to continue.'], 'center', 'center', [255 255 255], 0 );
% Screen('Flip',wdwPtr);
% while true
%     [ keyIsDown, secs, keyCode, deltaSecs ] = KbCheck;
%     if keyIsDown
%         if find(keyCode) == spacekey
%             break;
%         end
%     end
%     WaitSecs(0.004);
% end
% % KbWait;
% % while KbCheck; end; % I assume this line absorbs continuous key pressing
% Screen('FillRect',wdwPtr,[0 0 0]); %NNO shouldn't we have a mask here?
% Screen('Flip',wdwPtr);


if ~scanner
    % NEW INSTRUCTIONS FOR penalty_dots.m:
    % Intro instructions:
    % Display instructions and enforce the rest period:
    str = 'DOTS   DOTS   DOTS\n\nPress Z for leftward motion, M for rightward motion.\n\n';
    str = [str, sprintf('Rewards for corrects: $%1.2f\n\nPenalties for errors: -$%1.2f or -$%1.2f\n\n',Reward,Penalty(1),Penalty(2)) ];
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
    logfn = sprintf('penalty_dots_subject%d_ses%d.mat',subject_id,idx);
%     logfn=sprintf('logGoodGuysBadGuys_%s_%d.mat',subjid_str,idx);
    idx=idx+1;
end
% fprintf('Saving log file as %s', logfn);
% save(logfn);
% fprintf(' ... completed.\n');




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




for i = 1 : num_blocks

    coherence = coherence_array(i);
    visibility_flag = visibility_array(i);
    coherence_flag = ~visibility_flag;
    increasing_duration_flag = increasing_duration_array(i);
    
    Reward = Reward_array(i);
    Penalty = Penalty_array(i);
    
    

    % Display instructions and enforce the rest period:
    str = sprintf('%d blocks to go. \n\n Current Score: $%1.2f \n\n',num_blocks - i + 1,Score);
%     str = [str, sprintf('New reward for correct: $%1.2f\n\nNew penalty for error: -$%1.2f\n\n',Reward,Penalty)];
    str = [str, sprintf('Reward for correct: $%1.2f\n\nPenalty for error: -$%1.2f\n\n',Reward,Penalty)];
    if scanner
        DrawFormattedText( wdwPtr, str, 'center', 'center', [255 255 255], 0 );
        Screen('Flip',wdwPtr);

        WaitSecs(RestDuration);  % Display instructions during rest period inside the scanner.
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
    
    %     % Change rewards and penalties for the non-pulsed blocks at the end:
    %     if i > 0
    %         %         Reward = 0.1;
    %         %         Penalty = 0.75; % This drove Mike crazy -- he went negative and then gave up conservativeness
    %         %         Penalty = 0.4;
    %
    %         % Display instructions and enforce the rest period:
    %         %         str = sprintf('Reward Magnitude: $%1.2f\n\nPenalty Magnitude: -$%1.2f\n\n',Reward,Penalty);
    %         str = [];
    %         DrawFormattedText( wdwPtr, [str,'Press the Space key when \n you are ready to continue.'], 'center', 'center', [255 255 255], 0 );
    %         Screen('Flip',wdwPtr);
    %         while true
    %             [ keyIsDown, secs, keyCode, deltaSecs ] = KbCheck;
    %             if keyIsDown
    %                 if find(keyCode) == spacekey
    %                     break;
    %                 end
    %             end
    %             WaitSecs(0.004);
    %         end
    %         % KbWait;
    %         % while KbCheck; end; % I assume this line absorbs continuous key pressing
    %         Screen('FillRect',wdwPtr,[0 0 0]); %NNO shouldn't we have a mask here?
    %         Screen('Flip',wdwPtr);
    %
    %         WaitSecs(0.2);  % No idea why, but the first trial of every increasing_duration block has crazy short RTs.
    %     end
    
    
    BlockStartTime = GetSecs;
    DataStruct.BlockStartTime(end+1) = BlockStartTime-ExperimentStartTime;

    
    % Loop over trials within a block:
    for j = 1 : num_trials

        % Terminate block if it has almost exceeded the BlockDuration:
        tmp_time = GetSecs;
        if tmp_time - BlockStartTime + RSI_mean > BlockDuration
            DataStruct.BlockEndTime(end+1) = tmp_time-ExperimentStartTime;
            break
        end
        
        if visibility_flag
            DataStruct.VisibilityFlag(end+1) = 1;
        else
            DataStruct.VisibilityFlag(end+1) = 0;
        end
        if coherence_flag
            DataStruct.CoherenceFlag(end+1) = 1;
        else
            DataStruct.CoherenceFlag(end+1) = 0;
        end
        if increasing_duration_flag
            DataStruct.IncreasingDurationFlag(end+1) = 1;
        else
            DataStruct.IncreasingDurationFlag(end+1) = 0;
        end

        DataStruct.Coherence(end+1) = coherence;
        DataStruct.BlockNumber(end+1) = i;
        DataStruct.TrialNumber(end+1) = j;
        DataStruct.RewardMagnitude(end+1) = Reward;
        DataStruct.PenaltyMagnitude(end+1) = Penalty;
        DataStruct.NoPulse(end+1) = 1;
        
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
        
        
        RT_recorded = 0;    % Detect when an RT has been collected and flag this condition

        % Loop over mini-windows of stimulus presentation within each
        % trial (using num_division as defined is actually stupid, but
        % works -- I could probably change this to
        % ceil(1/proportion_delta):
        for k = 1:num_divisions

            rSet('dXdots',dotsIdx,'coherence',coherence);

            rSet('dXdots',dotsIdx,'direction',direc,'visible',true);
            rSet('dXtarget',targetIdx,'visible',true);
            rSet('dXtarget',blackTargetIdx,'visible',true);

                        
            % Do the pulsed display only if the block number is less than
            % 9, at which point, switch only to full-on display:
            % 4/13/09: Turning off pulsing altogether:
            %             if k < 1/proportion_delta && i < 9
            if k < 1/proportion_delta && i < 0
                if k > 1
                    % Jitter the pulsed duration, but only if
                    % visibility_flag is 1:
                    if visibility_flag == 1
                        WaitSecs(0.2*rand(1));
                    end
                end
                

                %                 % Rapidly ramp up the dot contrast if ramp flag set:
                %                 if ramp_flag && visibility_flag && ~coherence_flag
                %                     rSet('dXdots',dotsIdx,'color',0.5*[255 255 255]);
                %                     [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.01,[],[lkey rkey]);
                %                     rSet('dXdots',dotsIdx,'color',[255 255 255]);
                %                 end
                
                % Actually display the dots:
                if increasing_duration_flag
                    [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*k*proportion_delta*(mini_window_duration),[],[lkey rkey]);
                else
                    [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*proportion_delta*num_display_deltas,[],[lkey rkey]);
                end
                
                tmp_code = find(myKeyCode,1);
                if ~isempty(tmp_code)
                    if RT_recorded == 0
                        DataStruct.RT(end+1) = mySecs - TrialStartTime;
                        RT_recorded = 1;
                    end
                end
                
                
                %                 % Rapidly ramp down the dot contrast if ramp flag set:
                %                 if ramp_flag && isempty(tmp_code) && ~coherence_flag
                %                     % Ramp down the dot contrast gradually to eliminate energy
                %                     % splatter effects:
                %                     rSet('dXdots',dotsIdx,'color',0.5*[255 255 255]);
                %                     [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*0.01,[],[lkey rkey]);
                %                     rSet('dXdots',dotsIdx,'color',[255 255 255]);
                %                 end
                
                
                if visibility_flag
                    rSet('dXdots',dotsIdx,'direction',direc,'visible',false);
                end
                
                
                if coherence_flag
                    rSet('dXdots',dotsIdx,'coherence',0,'visible',true);
                end
                
                
                
                % Shouldn't the following code only be executed if there
                % wasn't a response during the display period of the
                % mini-window?
                if ~RT_recorded
                    % Draw the dots (or blackness) for the remainder of the
                    % mini-window:
                    if increasing_duration_flag
                        [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*(1-k*proportion_delta)*(mini_window_duration),[],[lkey rkey]);
                    else
                        [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(1000*(1-num_display_deltas*proportion_delta)*(mini_window_duration),[],[lkey rkey]);
                    end

                    tmp_code = find(myKeyCode,1);
                    if ~isempty(tmp_code)
                        if RT_recorded == 0
                            DataStruct.RT(end+1) = mySecs - TrialStartTime;
                            RT_recorded = 1;
                        end
                    end

                end

            else
                % If more than a certain number of mini-windows have been
                % shown, turn display of coherent dots on and leave on:
                [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],[lkey rkey]);
                tmp_code = find(myKeyCode,1);
                if ~isempty(tmp_code)
                    if RT_recorded == 0;
                        DataStruct.RT(end+1) = mySecs - TrialStartTime;
                        RT_recorded = 1;
                    end
                end

            end

            
            
            % Deal with responses:
            tmp_code = find(myKeyCode,1);
            if ~isempty(tmp_code)
                %                 % If you didn't already record an RT (because you didn't
                %                 % hit the key during dot presentation), then record it now:
                %                 % THIS DOESN'T HAPPEN NOW.
                %                 if DataStruct.RT(end) == inf
                %                     DataStruct.RT(end) = GetSecs - TrialStartTime;
                %                 end
                
                
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
                        %                         Screen('FillPoly', wdwPtr, 0.2*[255 0 0], antic_rect);
                    end
                    %                     %                     Screen('Flip', wdwPtr);
                    %                     %                     WaitSecs(0.1);
                    %                     %                     Screen('FillPoly', wdwPtr, [0 0 0], antic_rect);
                    %                     %                     rGraphicsDraw;
                    
                    % Define an RSI and enforce it:
                    %                     tmp_RSI = RSI + rand(1);
                    tmp_RSI = max(0.1,gamrnd(RSI_shape,RSI_mean/RSI_shape)-InstructionDuration); % Gives an RSI with mean equal to RSI_mean, and a bigger shape parameter makes it more narrow & normal
                    WaitSecs(tmp_RSI);
                    DataStruct.RSI(end+1) = tmp_RSI;
                    rSet('dXtarget',targetIdx,'color',[255 255 255]);
                    rGraphicsDraw;
                    break
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
 
                    % Define an RSI and enforce it:
                    %                     tmp_RSI = RSI + rand(1);
                    tmp_RSI = max(0.1,gamrnd(RSI_shape,RSI_mean/RSI_shape)-InstructionDuration); % Gives an RSI with mean equal to RSI_mean, and a bigger shape parameter makes it more narrow & normal
                    WaitSecs(tmp_RSI);
                    DataStruct.RSI(end+1) = tmp_RSI;
                    rSet('dXtarget',targetIdx,'color',[255 255 255]);
                    rGraphicsDraw;
                    break
                end
            end
            % End of accuracy computation if-else

        end
        % End of mini-window loop within trials

    end
    % End of trial loop

    %     fprintf(1,'About to save data . . . ');
    %     save(sprintf('pulsed_dots_subject%d_Data',subject_id),'DataStruct');
    %     fprintf(1,'Save completed.\n');
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

%keyboard
