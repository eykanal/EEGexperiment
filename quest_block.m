function [ST, ST_time, RT, ER, RDir, PiDirbl, SubScore, score, premie_t, premie_d,t,sd,q] = quest_block (D, shape,coher, blockdur, dotsIdx,targetIdx,blackTargetIdx,textIdx_Score,lkey, rkey,  PI, feedback, salary,wdwPtr,pahandle_correct, pahandle_antic, daq)
% function [ST, ST_time, RT, ER, RDir, PiDirbl, SubScore, score, premie_t, premie_d,t,sd,q] = quest_block (D, shape,coher, blockdur, dotsIdx,targetIdx,blackTargetIdx,textIdx_Score,lkey, rkey,  PI, feedback, salary,pahandle_correct, pahandle_antic, daq)
%
% FUNCTION QUEST_BLOCK -estimate the participants' motion coherence
% level for a performance of 75% correct using the QUEST algorithm
%
% Input Args:
%  coher -          coherence of dots
%  blockdur -       number of trials in this block
%  lkey -           correct key for dots moving left
%  rkey -           correct key for dots moving right
%  D -              Response Stimulus Interval
%  PI -             bias in favored direction
%  feedback
%  pahandle_correct
%  pahandle_antic
%  daq              synch pulse
% 
% Outputs: vectors as long as number of trials
%  ST - sequence of stimuli: 0 - small number of stars, 1 - high
%  number of stars
%  ST_time
%  RT - reaction times [in seconds]
%  ER - errors during trials: error = 1, correct = 0
%  RDir
%  PiDirbl - for every trial what the direction is that is favored
%  SubScore
%  OppScore
%  score - amount of points earned at the end of the trial
%  opponent - amount of points earned by imaginary opponent
%  premie_t
%  premie_d

money = 0; 
wartime = 5; %how long should be the warning before the trial
% Get the pixels-per-degree for DotsX:
ppd_ = rGet('dXscreen', 1, 'pixelsPerDegree');


timeSt = GetSecs;
ntrial = 0;
score = 0;

% 2/19/04: Adding a randomization of the direction favored by bias, so that it 
% isn't always toward the right:
biasdir = rand(1);
if biasdir < 0.5
  PiDirbl = 'R';
else
  PiDirbl = 'L';
end

% keep the RSI constant for threshold estimation
RSI_vector = D;

% initialize QUEST
cGuess = log(coher);
cGuessSd = log(coher)*2;
pThreshold = 0.75;
beta = 3; delta = 0.1; gamma = 0.5;
grain = 0.1; range = 50;
q = QuestCreate(cGuess,cGuessSd,pThreshold,beta,delta,gamma,grain,range);
q.normalizePdf=1;


timeZer0 = GetSecs;
subBlockDuration = 1; %number of blocks over which to average performance
for ntrial = 1:subBlockDuration:blockdur
  % Get recommended coherence.  Choose your favorite algorithm.
  cTest=QuestQuantile(q); % Recommended by Pelli (1987), and still our favorite.
  if cTest<0
    cTest = 0;
  end
  % cTest=QuestMean(q);	  % Recommended by King-Smith et al. (1994)  
  if biasdir < 0.5
    ST_bool = (rand(1) < PI);
  else
    ST_bool = (rand(1) > PI );
  end

  % set the coherence for this trial of dots (we assume coherence
  % follows a log scale, so we take the exponential)
  rSet('dXdots',dotsIdx,'coherence',exp(cTest));
  
  for t = ntrial:(ntrial+subBlockDuration-1)
    if ST_bool
      [RT(t), ER(t), RDir(t), score, premie_t{t}, ...
       premie_d{t},ST_time(t)] = trial_fixedview (dotsIdx, targetIdx,blackTargetIdx,textIdx_Score, ppd_, 0, rkey, RSI_vector, shape,score, ntrial, money, salary,wdwPtr,1000,pahandle_correct, pahandle_antic, daq);
      ST(t) = 'R';     
      % Now store trial-by-trial scores:
      SubScore(t) = score;
    else
      [RT(t), ER(t), RDir(t), score, premie_t{t}, ...
       premie_d{t},ST_time(t)] = trial_fixedview (dotsIdx, targetIdx,blackTargetIdx,textIdx_Score, ppd_, 180, lkey, RSI_vector, shape,score, ntrial, money, salary, wdwPtr,1000,pahandle_correct, pahandle_antic, daq);
      ST(t) = 'L';
      % Now store trial-by-trial scores:
      SubScore(t) = score;
      
    end
  end
  % update the pdf  
  if mean(1-ER(ntrial:(ntrial+subBlockDuration-1)))>0.5
    resp = 1;
  else
    resp = 0;
  end
  q=QuestUpdate(q,cTest,resp); 
  % Add the new datum (actual test coherence level and observer
  % response) to the database.
  
end

% Ask Quest for the final estimate of threshold.
t=exp(QuestMean(q));		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=exp(QuestSd(q));
fprintf('\nFinal threshold estimate (meanstd) is %.2f ± %.2f\n',t,sd);


%rClear;
