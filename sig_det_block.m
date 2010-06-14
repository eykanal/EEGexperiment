function [ST, ST_time, RT, ER, score, premie_t, premie_d] = ...    sig_det_block (D, shape, coher, blockdur, respdir, ...    dotsIdx, targetIdx, blackTargetIdx, textIdx_Score, ppd_, lkey, rkey, money, salary, ...    pahandle_correct, pahandle_antic, daq, contrast_factor)% function [ST, RT, ER, score] = block (coher, blockdur, lkey, rkey, D, PI)%% 7/16/07: Converting this entirely to the DotsX code.%% Block of experiment% Inputs:%  coher - coherence of dots%  blockdur - duration of the block in seconds%  lkey - correct key for dots moving left%  rkey - correct key for dots moving right%  D - Response Stimulus Interval% %  Dpen - Additional Delay after making an error% Outputs: vectors as long as number of trials%  ST - sequnece of stimuli: 0 - small number of stars, 1 - high number of stars%  RT - reaction times [in seconds]%  ER - errors during trials: error = 1, correct = 0%  score - amount of points earned at the end of the trial%  opponent - amount of points earned by imaginary opponent%% 10/28/08: Adapting for fMRI expt.% % rInit ('visible', 1);	%initializes screen and makes it visible% % windowptr = screen('Windows');% % screen (windowptr, 'TextFont', 'Courier New');wartime = 5;		%how long should be the warning before the trial% [rect] = screen (windowptr, 'Rect');PI = 0.5; % Always do 50/50 in a signal detection block.% % 7/17/07: Get the pixels-per-degree for DotsX:% ppd_ = rGet('dXscreen', 1, 'pixelsPerDegree');feedback = 1;   % Always give feedback now% fontsize = 36;% str = 'Get Ready';% textwidth = fontsize*length(str)/ppd_;% x_pos = -0.3*textwidth;% seconds_idx = rAdd('dXtext', 1, 'visible', true, ...%     'x', x_pos, 'y', 1, ...%     'size', fontsize, ...%     'font', 'Courier',  ...%     'bold', true, ...%     'color', [1 1 1]*255, ...%     'string', str);% % % str = sprintf ('Block starts in %d seconds', wartime);% textwidth = fontsize*length(str)/ppd_;% x_pos = [];% x_pos = -0.3*textwidth;% seconds_idx = rAdd('dXtext', 1, 'visible', true, ...%     'x', x_pos, 'y', 0, ...%     'size', fontsize, ...%     'font', 'Courier',  ...%     'bold', true, ...%     'color', [1 1 1]*255, ...%     'string', str);% % fontsize = 20;% str = [];% str = sprintf ('Remember: "%c" - left; "%c" - right', lkey, rkey);% textwidth = [];% textwidth = fontsize*length(str)/ppd_;% x_pos = [];% x_pos = -0.3*textwidth;% rAdd('dXtext', 1, 'visible', true, ...%     'x', x_pos, 'y', -2, ...%     'size', fontsize, ...%     'font', 'Courier',  ...%     'bold', true, ...%     'color', [1 1 1]*255, ...%     'string', str);% % rGraphicsDrawNoInterrupt(1000);% % % SetMouse (rect(3), rect(4));% for i = wartime-1:-1:1%     str = sprintf ('Block starts in %d seconds', i);% %     rSet('dXtext',seconds_idx,'string',str);%     rGraphicsDrawNoInterrupt(1000);% % end% rClear;rGraphicsBlank;timeSt = GetSecs;ntrial = 0;score = 0;opponent = 0;fontsize = 20;% str = sprintf ('Score: %d', score);str = ' ';textwidth = fontsize*length(str)/ppd_;x_pos = -0.3*textwidth;textIdx = rAdd('dXtext', 1, 'visible', false, ...    'x', x_pos, 'y', 0, ...    'size', fontsize, ...    'font', 'Courier',  ...    'color', [1 1 1]*255, ...    'string', str);% 2/19/04: Adding a randomization of the direction favored by bias, so that it % isn't always toward the right:biasdir = rand(1);if biasdir < 0.5	PiDirbl = 'R';else	PiDirbl = 'L';end% Need an initial delay before first trial:% 10/27/08: Now making a gamma-distributed RSI, with shape and mean% parameters sent by the calling function: scale = D/shape;RSI = gamrnd(shape,scale);% rGraphicsBlank;rSet('dXtarget',targetIdx,'visible',true,'penWidth',24,'diameter',0.3);rSet('dXtarget',blackTargetIdx,'visible',true);rGraphicsDraw;WaitSecs(RSI);while GetSecs - timeSt < blockdur   ntrial = ntrial + 1;      if biasdir < 0.5	   ST_bool = (rand(1) < PI);   else	   ST_bool = (rand(1) > PI );   end   if ST_bool%        [RT(ntrial), ER(ntrial), RDir(ntrial), score, premie_t{ntrial},premie_d{ntrial},ST_time(ntrial)] = ...%            sig_det_trial (dotsIdx, targetIdx, blackTargetIdx, textIdx, ppd_, 0, rkey, RSI, shape, score, money, salary, ntrial, ...%            pahandle_correct, pahandle_antic, respdir, daq, contrast_factor);        % 2/3/2009: I think that I set RSI according to a gamma        % distribution based on D and shape above, and then fed RSI instead        % of D into the trial function. That produced radically different        % average RSI's in two different calls to sig_det_block.m.       [RT(ntrial), ER(ntrial), RDir(ntrial), score, premie_t{ntrial},premie_d{ntrial},ST_time(ntrial)] = ...           sig_det_trial (dotsIdx, targetIdx, blackTargetIdx, textIdx, ppd_, 0, rkey, D, shape, score, money, salary, ntrial, ...           pahandle_correct, pahandle_antic, respdir, daq, contrast_factor);       ST(ntrial) = 'R';   else%        [RT(ntrial), ER(ntrial), RDir(ntrial), score, premie_t{ntrial},premie_d{ntrial},ST_time(ntrial)] = ...%            sig_det_trial (dotsIdx, targetIdx, blackTargetIdx, textIdx, ppd_, 180, lkey, RSI, shape, score, money, salary, ntrial, ...%            pahandle_correct, pahandle_antic, respdir, daq, contrast_factor);       [RT(ntrial), ER(ntrial), RDir(ntrial), score, premie_t{ntrial},premie_d{ntrial},ST_time(ntrial)] = ...           sig_det_trial (dotsIdx, targetIdx, blackTargetIdx, textIdx, ppd_, 180, lkey, D, shape, score, money, salary, ntrial, ...           pahandle_correct, pahandle_antic, respdir, daq, contrast_factor);       ST(ntrial) = 'L';   endendrGraphicsBlank;