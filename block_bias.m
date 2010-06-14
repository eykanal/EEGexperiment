function [ST, irrelDir, ST_time, RT, ER, RDir, PiDirBl, score, premie_t, premie_d ] = block_bias (D, RSI_poss,shape, PI, coh, blockdur,dotsIdx, targetIdx, triangleIdx,blackTargetIdx, textIdx_Score, ppd_, lkey, rkey, money, salary, wdwPtr, pahandle_correct, pahandle_antic, daq,contrast_factor)
% function [ST, irrelDir, ST_time, RT, ER, RDir, PiDirBl, score, premie_t, premie_d ] = block_bias (D, RSI_poss,shape, bias, coh, blockdur,dotsIdx, targetIdx, triangleIdx,blackTargetIdx, textIdx_Score, ppd_, lkey, rkey, money, salary, wdwPtr, pahandle_correct, pahandle_antic, daq,contrast_factor)
%
% Block of experiment
% Inputs:
%  coh - coherence of dots
%  blockdur - duration of the block in seconds
%  lkey - correct key for dots moving left
%  rkey - correct key for dots moving right
%  D - Response Stimulus Interval
% RSI_poss - possibilities for RSIs
% shape - shape parameters for distribution of RSIs
% bias - bias for this block
% coh = coherence for this block
% blockdur = block duration in seconds
% dotsIdx, targetIdx, triangleIdx, blackTargetIdx, textIdx_Score:
% dotsX objects to be displayed
% ppd_ = resolution
% lkey, rkey = keys for left- and rightward motion
% money = how much money the participant has already made
% salary = how much money per point
% wdwPtr = display parameter
% Outputs: vectors as long as number of trials
%  ST - sequnece of stimuli: 0 - small number of stars, 1 - high number of stars
%  RT - reaction times [in seconds]
%  ER - errors during trials: error = 1, correct = 0
%  score - amount of points earned at the end of the trial

timeSt = GetSecs;
ntrial = 0;

% 2/19/04: Adding a randomization of the direction favored by bias, so that it 
% isn't always toward the right:
biasdir = rand(1);
if biasdir < 0.5
  PiDirBl = 'R';
else
  PiDirBl = 'L';
end

rSet('dXtarget',targetIdx,'penWidth',24,'diameter',0.3);
rSet('dXdots',dotsIdx,'coherence',coh);
score = 0;

% Need an initial delay before first trial:
% 10/27/08: Now making a gamma-distributed RSI, with shape and mean
% parameters sent by the calling function: 
scale = D/shape;
RSI = gamrnd(shape,scale);
rGraphicsBlank;
rSet('dXtarget',targetIdx,'visible',true);
rSet('dXtarget',blackTargetIdx,'visible',true);
rGraphicsDraw;
WaitSecs(RSI);

% MAIN TRIAL-CALLING LOOP:
while GetSecs - timeSt < blockdur
  % for i = 1 : length(timing_row)
  ntrial = ntrial + 1;
  
  if biasdir < 0.5
    ST_bool = (rand(1) < PI);
  else
    ST_bool = (rand(1) > PI );
  end

  if ST_bool
    [RT(ntrial), ER(ntrial), RDir(ntrial), score, premie_t{ntrial},premie_d{ntrial},ST_time(ntrial), a, b, c, irrelDirNumerical ] =trial_arrow (dotsIdx, targetIdx, triangleIdx,blackTargetIdx, textIdx_Score, ppd_, 0, rkey,lkey,rkey,D, shape, score, ntrial, money, salary,wdwPtr, 'd', pahandle_correct, pahandle_antic, daq,contrast_factor,0);
    ST(ntrial) = 'R';
  else
    [RT(ntrial), ER(ntrial), RDir(ntrial), score, premie_t{ntrial},premie_d{ntrial},ST_time(ntrial), a, b, c, irrelDirNumerical ] = trial_arrow (dotsIdx, targetIdx, triangleIdx,blackTargetIdx, textIdx_Score, ppd_, 180, lkey,lkey,rkey,D, shape, score, ntrial, money, salary,wdwPtr, 'd', pahandle_correct, pahandle_antic, daq,contrast_factor,0);
    ST(ntrial) = 'L';
  end
   
  % Keep track of direction of irrelevant motion on arrow trials
  % (equals actual motion direction on motion trials):
  if irrelDirNumerical == 0
    irrelDir(ntrial) = 'R';
  else
    irrelDir(ntrial) = 'L';
  end
  
end

