function [ST, ST_time, RT, ER, RDir, PiDirbl, SubScore, score, premie_t, premie_d,coherenceVec,coh70perc,coh90perc,params,cdf_type] = psychometric_block (D, shape, coher,blockdur, dotsIdx,targetIdx,blackTargetIdx,textIdx_Score,lkey, rkey,  PI, feedback, salary,wdwPtr,pahandle_correct, pahandle_antic, daq)
% function [ST, ST_time, RT, ER, RDir, PiDirbl, SubScore, score,
% premie_t, premie_d,t,sd,q] = psychometric_block (D, shape, coher,blockdur,
% dotsIdx,targetIdx,blackTargetIdx,textIdx_Score,lkey, rkey, PI,
% feedback, salary,pahandle_correct, pahandle_antic, daq)
%
% FUNCTION QUEST_BLOCK -estimate the participants' psychometric
% function for motion coherence
%
% Input Args:
%  coher -          vector with coherences to test, e.g., [2.5 5
%  12.5 25 50]
%  blockdur -       number of trials per coherence, e.g., 50
%  lkey -           correct key for dots moving left
%  rkey -           correct key for dots moving right
%  D -              Response Stimulus Interval
%  PI -             bias in favored direction, e.g., 0.5 (no bias)
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
%  score - amount of points earned at the end of the trial
%  premie_t
%  premie_d

% pull in vars from global space
Behavioral  = evalin('caller','Behavioral');
u           = evalin('caller','u');
parport     = evalin('caller','parport');
ppd_        = evalin('caller','ppd_');

money   = 0; 
wartime = 5; % how long should be the warning before the trial
timeSt  = GetSecs;
ntrial  = 0;
score   = 0;

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

% set up the vector with coherences
coherenceVec = repmat(coher,1,blockdur);
% now randomize the coherences
randind = randperm(length(coherenceVec));
coherenceVec = coherenceVec(randind);

% zero out the variables
RT = zeros(length(coherenceVec),1); ER = zeros(length(coherenceVec),1);
ST_time = zeros(length(coherenceVec),1); RDir = zeros(length(coherenceVec),1);

for n  = 1:length(coherenceVec)
    if biasdir < 0.5
        ST_bool = (rand(1) < PI);
    else
        ST_bool = (rand(1) > PI );
    end  

    % set the coherence for this trial of dots
    args = {@rSet,'dXdots',dotsIdx,'coherence',coherenceVec(n)};
    execute_code(Behavioral,u,args);

    if ST_bool
        [RT(n), ER(n), RDir(n), score, premie_t{n}, premie_d{n}, ...
            ST_time(n)] = ...
        trial_fixedview (dotsIdx, targetIdx, blackTargetIdx, ...
            textIdx_Score, ppd_, 0, rkey, RSI_vector, shape, score, ...
            ntrial, money, salary, wdwPtr, 1000, pahandle_correct, ...
            pahandle_antic, daq, lkey, rkey);
        ST(n) = 'R';     
        % Now store trial-by-trial scores:
        SubScore(n) = score;
    else
        [RT(n), ER(n), RDir(n), score, premie_t{n}, premie_d{n}, ...
            ST_time(n)] = ...
        trial_fixedview (dotsIdx, targetIdx, blackTargetIdx, ...
            textIdx_Score, ppd_, 180, lkey, RSI_vector, shape, score, ...
            ntrial, money, salary, wdwPtr, 1000, pahandle_correct, ...
            pahandle_antic, daq, lkey, rkey);
        ST(n) = 'L';
        % Now store trial-by-trial scores:
        SubScore(n) = score;
    end 
end


% now come up with a coherence for this participant
acc     = zeros(length(coher),1);
meanRT  = zeros(length(coher),1);
accErr  = zeros(length(coher),1);
varRT   = zeros(length(coher),1);
for c = 1:length(coher)
    thisCoherIndex = find(coherenceVec==coher(c));
    acc(c)    = 1-mean(ER(thisCoherIndex));
    % binomial error
    accErr(c) = sqrt(acc(c)*(1-acc(c)))/sqrt(length(thisCoherIndex));
    meanRT(c) = mean(RT(thisCoherIndex));
    varRT(c)  = std(RT(thisCoherIndex));
end
cdf_type = 3; % fit with the gamma function
% sometimes a fit to a psychometric function doesn't work, so we
% embed it in a try-catch loop
try
    params = fminunc(@(x) psychometric_error_function(x,coher,acc',cdf_type),[1,1])
catch
    try 
        cdf_type =1;
        params = fminunc(@(x) psychometric_error_function(x,coher,acc',cdf_type),[1,1])
    catch
        % if it still doesn't work, try the last cdf_type
        cdf_type = 2;
        params = fminunc(@(x) psychometric_error_function(x,coher,acc',cdf_type),[1,1])
    end
end

switch cdf_type
    case 1
        coh90perc = (norminv(0.9)-params(2))/params(1);
        coh70perc = (norminv(0.7)-params(2))/params(1);
    case 2
        coh90perc = wblinv(0.9,params(1),params(2));
        coh70perc = wblinv(0.7,params(1),params(2));
    case 3
        coh90perc = gaminv(0.9,params(1),params(2));
        coh70perc = gaminv(0.7,params(1),params(2));
end %switch

  
%coh80perc = gaminv(0.8,params(1),params(2));
%coh60perc = gaminv(0.6,params(1),params(2));
