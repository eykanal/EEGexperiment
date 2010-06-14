function [RT, ER, RDir, score, opponent_score,premie_t,premie_d,timeS] = ...	trial (windowptr, direc, corkey, D, scorein, opponent_scorein, ...	money, opponent_money, salary, ntrial, feedback, respdir )% function [RT, ER, score] = trial (windowptr, direc, corkey, D ,Dpen, scorein)% % One experimental trial% Inputs:%  windowptr - pointer to the screen window%  direc - direction of dots%  corkey - correct key for this trial as number by crazy Mac%  D - Response-Stimulus Interval%  Dpen - Additional Delay after making an error%  scorein - starting score of the subject% Outputs:%  RT - reaction time [in seconds]%  ER - error = 1, correct = 0%  score - score after the trial% % 'feedback' -- flag indicating whether feedback should be presented% Change to accepting only responses in respdir direction:if strcmp( 'Left', respdir) == 1	corcode = 7;else	corcode = 47;endrSet ('dots', [1], 'direction', direc);% Set direction of dots movement% Now set the color of the target for the photodiode to detect:	% 12 is the CLUTIndex for white% 	Screen(windowptr,'FillOval',12,[ 50 700 75 725]);	% 10 is the CLUTIndex for grayif direc == 0	target_clut = 12;else	target_clut = 224;endrRecurStart ('dots', [1], [1]);% Puts dots on the list of objects to be displayed recursivelly% Pat-comment, Sept 14, 2005: Moving the timeS below the first while % loop:% timeS = GetSecs;while KbCheck   %empty loop to avoid pressing the button continuouslyendtimeS = GetSecs;while ~KbCheck	rWaitVBL;	% Waits to the refresh of the monitor	rRecur;		% Plots all the objects on the list of recursive objects 	Screen(windowptr,'FillOval',target_clut,[ 50 700 75 725]);endtimeR = GetSecs;% Throwing in a check here to make sure that timeR is not less than % 100 msec. If so, incur a penalty and move to penalizing delay period, % returning the normal statistics that would've been returned (thus % the code that analyzes statistics should take care of RTs of < 100 % msec, by throwing those trials out). Currently this version of the % code does not return the number of premature presses.RT = timeR - timeS;[keydown, secs, keycode] = KbCheck;keynum = find(keycode);if isempty (keynum)	keynum = 0;endER = (keynum(1) ~= corcode);rRecurStop ('dots', [1]);% Stops movement of dots% rRecurStop('target',[1]);Screen(windowptr,'FillRect',255);% Here's the 100 msec check:if RT > 0.1	score = scorein + ~ER;else	score = scorein;end% % % Now, get the opponent's score by centering a normal distribution at the % % % point halfway between the two scores and selecting a score from it:% % diff = (opponent_scorein * salary + opponent_money) - (score*salary + money);% % half = abs(diff)/2;% % % score_increment = 1.5 * randn(1);% % opponent_score = opponent_scorein;% % if diff > 0% % 	opponent_score_tmp = opponent_scorein - half + score_increment;% % else% % 	opponent_score_tmp = opponent_scorein + half + score_increment;% % end% % if opponent_score_tmp > opponent_score% % 	opponent_score = floor(opponent_score_tmp);% % end% % % % Trying a more smoothly varying opponent score:% % Now, get the opponent's score by centering a normal distribution at the % % point halfway between the two scores and selecting a score from it:% diff = (opponent_scorein * salary + opponent_money) - (score*salary + money);% adjust = 0.1 * abs(diff);% % Make the variability depend on the time since the last trial and the delay,% % and make it Chi-squared rather than normal. Also, make the dependence on % % delay not so severe as it was (1/D), because that favors the opponent on % % short delay blocks and favors the subject on long delay blocks:% % score_increment = RT * randn(1)^2 * D^(-0.25);% % OK, the above line really sucked, so let's fix the variance, and just keep % % it simple:% score_increment = 2.5 * abs(randn(1));% % Cap the possible jumps to realistic scores in the RT interval. Since the % % last response, a time D + RT has passed. The opponent could not possibly % % do better than getting a correct response with 0 RT, so the number of % % times that D goes into D+RT is the max they could've scored . . . except % % that their trials may be staggered with respect to the subject's, so they % % could possibly get 1 more than this.% if score_increment > (RT+D)/D% 	score_increment = (RT+D)/D;% end% % opponent_score = opponent_scorein;% if diff > 0% 	opponent_score_tmp = opponent_scorein - adjust + score_increment;% else% 	opponent_score_tmp = opponent_scorein + adjust + score_increment;% end% if opponent_score_tmp > opponent_score% 	opponent_score = floor(opponent_score_tmp);% endopponent_score = 0;% Get the particular direction of this trial:if keynum == 7	RDir = 'L';elseif keynum == 47	RDir = 'R';else	RDir = '-';end% rRecurStop ('dots', [1]);% % Stops movement of dots% 5/2/06: Modifying the normal distribution of RSIs below. Creating a square % pulse hazard rate function instead. This requires generating an exponentially % distributed random variable, then adding that variable to a rest period. Here % the rest period is set at 400 msec, but that could also be a parameter of this% function. Here, we just use a uniform random variable to select one of a preset % number of possible RSIs, distributed with an exponential density + 400 msec. % The preset RSI vector is a parameter of this function, sent by block.m, where % it is calculated once for each condition. Just use the variable D for this % purpose:RSI = D( max(round( rand(1) * length(D) ),1) );if RT > 0.1	if ER		delay = RSI;	elseif feedback		dur = makesound;		delay = RSI - dur;	else		delay = RSI;	end	% Every 10 trials, display feedback for 0.5 seconds:	if (mod( ntrial, 5 ) == 1) & feedback		TextCenter (windowptr, sprintf ('Score: %d', score), 0, 12);% 		TextCenter (windowptr, sprintf ('Opponent: %d', opponent_score), 24, 12);		delay = max( delay, 0.5 );  % Ensure feedback of 0.5 seconds	endelse	% This is a penalty delay, so might as well make it big:	dur = makesound('errorsound');	delay = 4 - dur;end% % Get a normally distributed random increment to add on to D % % in order to vary the stimulus onset for this trial (make sure % % that D + increment is not less than 0):% n = 0.1 * randn( 1 );% if n < -D% 	n = -D + 0.01;% end% % if RT > 0.1% 	% 	% 	TextCenter (windowptr, sprintf ('Score: %d', score), 0, 12);% 	% 	TextCenter (windowptr, sprintf ('Opponent: %d', opponent_score), 24, 12);% 	% 	if ER% 		% 	WaitSecs (D);% 		% 	WaitSecs (D-n);% 		delay = D + n;% 	elseif feedback% 		dur = makesound;% 		%    WaitSecs (D - dur);% 		%    WaitSecs (D-n - dur);% 		delay = D + n - dur;% 	else% 		delay = D + n;% 	end% % 	% Every 10 trials, display feedback for 0.5 seconds:% 	if (mod( ntrial, 5 ) == 1) & feedback% 		TextCenter (windowptr, sprintf ('Score: %d', score), 0, 12);% % 		TextCenter (windowptr, sprintf ('Opponent: %d', opponent_score), 24, 12);% 		delay = max( delay, 0.5 );  % Ensure feedback of 0.5 seconds% 	end% % else% 	delay = D + n;% end% 5/3/06: Starting the timing for the RSI from the offset of the subject's keypress now:% % Get a current time:% start = GetSecs;premie_t = []; premie_d = [];% 5/3/06: Soak up any continuous button pressing and don't do anything during such a time:while KbCheckend% Get a current time for the offset of the subject's keypress:start = GetSecs;% Wait for the RSI to expire. If it does, return. If it doesn't, go to the premie keypress % code below:while ~KbCheck	s = GetSecs - start;	if s >= delay		return	endend% If the function gets to here, then they made a premature keypress, % so penalize them:% dur = makesound;% 	start = GetSecs;% 9/14/05: Could determine inter-premature-press interval here:% premie_t = []; premie_d = [];% 5/3/06: make delay 4 seconds:% This is a penalty delay, so might as well make it big:s = GetSecs;dur = makesound('errorsound');delay = 4 - dur;premie_t = [premie_t, s - start];start = s;keynum = find(keycode);if isempty (keynum)	keynum = 0;endif keynum == 7	premie_d = [premie_d,'L'];elseif keynum == 47	premie_d = [premie_d,'R'];else	premie_d = [premie_d,'-'];endwhile 1% 	n = 0.1 * randn( 1 );% 	if n < -D% 		n = -D + 0.01;% 	end	% Empty loop to absorb continuous pressing:	while KbCheck		;	end	while ~KbCheck		s = GetSecs - start;		if s >= delay			return		end	end	% 	dur = makesound;		% 	start = GetSecs;	% 9/14/05: Could determine inter-premature-press interval here:	s = GetSecs;		% This is a penalty delay, so might as well make it big:	dur = makesound('errorsound');	delay = 4 - dur;% 	premie = s - start;	premie_t = [premie_t, s - start];	start = s;	keynum = find(keycode);	if isempty (keynum)		keynum = 0;	end	if keynum == 7		premie_d = [premie_d,'L'];	elseif keynum == 47		premie_d = [premie_d,'R'];	else		premie_d = [premie_d,'-'];	endend