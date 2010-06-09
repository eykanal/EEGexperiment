function [RT, ER, RDir, score, premie_t,premie_d,timeS, irrelevantMotionDir] = trial_fixedview (dotsIdx, targetIdx, blackTargetIdx, textIdx, ppd_, direc, corcode, D, shape, scorein, ntrial,money, salary, wdwPtr, viewDuration, pahandle_correct, pahandle_antic, daq,lkey,rkey )% 10/27/08: Modified for free-response fMRI experiment.% function [RT, ER, RDir, score, premie_t,premie_d,timeS, irrelevantMotionDir] = trial_fixedview (dotsIdx, targetIdx, blackTargetIdx, textIdx, ppd_, direc, corcode, D, shape, scorein, ntrial,money, salary, wdwPtr, viewDuration, pahandle_correct, pahandle_antic, daq )% this trial has a fixed viewing time% % One experimental trial% Inputs:%  windowptr - pointer to the screen window%  direc - direction of dots%  corkey - correct key for this trial as number by crazy Mac%  D - Response-Stimulus Interval%  Dpen - Additional Delay after making an error%  scorein - starting score of the subject% viewDuration - how long we want the participant to view the dots% stimulus (in milliseconds)% Outputs:%  RT - reaction time [in seconds]%  ER - error = 1, correct = 0%  score - score after the trial% % 'feedback' -- flag indicating whether feedback should be presented% if corkey == 'Z'	%Mac has strange representation of keys: z=7, m=47% % 	corcode = 7;%     corcode = 29;% else% % 	corcode = 47;%     corcode = 16;% end% pull in vars from global spaceBehavioral  = evalin('caller','Behavioral');u           = evalin('caller','u');parport     = evalin('caller','parport');irrelevantMotionDir = direc;args{1} = {@rSet,'dXdots',dotsIdx,'direction',direc,'visible',true};args{2} = {@rSet,'dXtarget',targetIdx,'visible',true,'color',[255 255 255]};args{3} = {@rSet,'dXtarget',blackTargetIdx,'visible',true};for n = 1:3    execute_code(Behavioral,args,u{n});endif ~exist('lkey','var')  lkey = 38;endif ~exist('rkey','var')  rkey = 35;endif daq ~= -1    if direc == 0        putvalue(parport.Line(1:8), 10); % 10 volt is for Rightward motion    else        putvalue(parport.Line(1:8), 5); % 5 volts is for Leftward motion    endendtimeS = GetSecs;% add in fixed viewing timeargs = {@rGraphicsDrawNoInterrupt,viewDuration};execute_code(Behavioral,args,u);% turn the stimulus offargs = {@rSet,'dXdots',dotsIdx,'visible',false};execute_code(Behavioral,args,u);args = {@rSet,'dXtarget',targetIdx,'color',[0 0 255]}; %turn the fixation cue blue execute_code(Behavioral,args,u);%rGraphicsDraw;if daq ~= -1    putvalue(parport.Line(1:8), 0);end% now wait for a button pressif Behavioral    [ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],[lkey rkey]);else    args = {@rGraphicsDrawSelectiveBreakMulti,inf,[],[lkey rkey]};    execute_code(Behavioral,args,u,{'mySecs','myKeyCode'});end%[ mySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],[38 35]);timeR = mySecs;RT = timeR - timeS;keynum = find(myKeyCode);if isempty (keynum)	keynum = 0;endER = (keynum(1) ~= corcode);% Here's the 100 msec check:score = scorein + ~ER;% Get the particular direction of this trial:% if keynum == 7if keynum == lkey%if keynum == 38    RDir = 'L';    % elseif keynum == 47 elseif keynum == rkey%elseif keynum == 35    RDir = 'R';else    RDir = '-';endfeedback = 1;% 10/27/08: Now making a gamma-distributed RSI, with shape and mean% parameters sent by the calling function: scale = D/shape;RSI = gamrnd(shape,scale);if ER    delay = RSI;    args = {@rSet,'dXtarget',targetIdx,'color',[255 0 0]};    execute_code(Behavioral,args,u);    execute_code(Behavioral,u,{@rGraphicsDraw});elseif feedback    args = {@rSet,'dXtarget',targetIdx,'color',[0 255 0]};    execute_code(Behavioral,args,u);    execute_code(Behavioral,u,{@rGraphicsDraw});    dur = makesound2(pahandle_correct);    delay = RSI - dur;else    delay = RSI;end% Every 10 trials, display feedback for 0.5 seconds:if (mod( ntrial, 5 ) == 1) && feedback    execute_code(Behavioral,u,{@rGraphicsDraw});    fontsize = 20;    str = sprintf ('Score: %d', score);    textwidth = fontsize*length(str)/ppd_;    x_pos = -0.3*textwidth;    args = {@rSet, ...        'dXtext',textIdx, ...        'string',str, ...        'visible',true, ...        'x', x_pos, 'y', 0, ...        'size', fontsize};    execute_code(Behavioral,args,u);    args = {@rGraphicsDraw,delay};    execute_code(Behavioral,args,u);endpremie_t = []; premie_d = [];% 5/3/06: Soak up any continuous button pressing and don't do anything during such a time:while KbCheckMulti    WaitSecs(0.001);end% Get a current time for the offset of the subject's keypress:start = GetSecs;% Wait for the RSI to expire. If it does, return. If it doesn't, go to the premie keypress % code below:while ~KbCheckMulti  s = GetSecs - start;  WaitSecs(0.001);  if s >= delay        %         rDone;    execute_code(Behavioral,{@rGraphicsBlank},u);        return  endend% If the function gets to here, then they made a premature keypress, % so penalize them:% dur = makesound;% 	start = GetSecs;% 9/14/05: Could determine inter-premature-press interval here:% premie_t = []; premie_d = [];% 5/3/06: make delay 4 seconds:s = GetSecs;% This is a penalty delay, so might as well make it big:% dur = makesound('errorsound');dur = makesound2(pahandle_antic);delay = 4 - dur;premie_t = [premie_t, s - start];start = s;keynum = find(myKeyCode);if isempty (keynum)	keynum = 0;end% if keynum == 7% if keynum == 29if keynum == lkey    premie_d = [premie_d,'L'];    % elseif keynum == 47    % elseif keynum == 16elseif keynum == rkey    premie_d = [premie_d,'R'];else    premie_d = [premie_d,'-'];endwhile 1% 	n = 0.1 * randn( 1 );% 	if n < -D% 		n = -D + 0.01;% 	end	% Empty loop to absorb continuous pressing:	while KbCheckMulti		WaitSecs(0.001);	end	while ~KbCheckMulti		s = GetSecs - start;        WaitSecs(0.001);		if s >= delay            execute_code(Behavioral,{@rGraphicsBlank},u);			return		end	end	% 	dur = makesound;		% 	start = GetSecs;	% 9/14/05: Could determine inter-premature-press interval here:	s = GetSecs;	% This is a penalty delay, so might as well make it big:	% 	dur = makesound('errorsound');	dur = makesound2(pahandle_antic);	delay = 4 - dur;	premie_t = [premie_t, s - start];	start = s;	keynum = find(myKeyCode);	if isempty (keynum)        keynum = 0;    end    % 	if keynum == 7    % 	if keynum == 29    if keynum == lkey        premie_d = [premie_d,'L'];        % 	elseif keynum == 47        %     elseif keynum == 16    elseif keynum == rkey        premie_d = [premie_d,'R'];    else        premie_d = [premie_d,'-'];    endend