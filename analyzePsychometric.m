% analyze the data from psychometric_block.m
subject = 1;
sess = 1;
plotErr = 1; %whether to plot errorbars or simple lines
adFac = 0.5;
twoDirections = 0; %when set to 1, fit the leftward motion as
                   %negative coherences
plotLog= 1; %whether to plot everything as a function of log-coherence
% cdf_type = 1 for normcdf
% cdf_type = 2 for weibull
% cdf_type = 3 for gamma funtion
cdf_type = 3;

filename = sprintf ('subject%d_psychomses%d.mat', subject, sess);
load(filename);


cohLevels = unique(allCoh);
if twoDirections
  cohLevels = [-cohLevels cohLevels];
end
%numblocks = 2; %divide up in fewer blocks: estimates more reliable?
blockLength = length(RT)/numblocks;
colorVec= {'r','g','b','y','k'};
paramsVec = zeros(numblocks,2);

for b = 1:numblocks
  % plot the participant's accuracy as a function of coherence
  acc = zeros(length(cohLevels),1);
  meanRT = zeros(length(cohLevels),1);
  accErr = zeros(length(cohLevels),1);
  varRT = zeros(length(cohLevels),1);
  blockER = ER((b-1)*blockLength+1:b*blockLength);
  blockRT = RT((b-1)*blockLength+1:b*blockLength);
  blockCoh = allCoh((b-1)*blockLength+1:b*blockLength);
  blockDir  = RDir((b-1)*blockLength+1:b*blockLength);
  % RDir ==82: rightward motion
  % RDir==76: leftward motion
  
  for c = 1:length(cohLevels)
    if twoDirections
      if cohLevels(c)<0 %left-ward
	thisCoherIndex = intersect(find(blockCoh==-cohLevels(c)),find(RDir==76));
          acc(c) = mean(blockER(thisCoherIndex));
      else % right-ward
	thisCoherIndex = intersect(find(blockCoh==cohLevels(c)),find(RDir==82));
	acc(c) = 1-mean(blockER(thisCoherIndex));
      end
    else
      thisCoherIndex = find(blockCoh==cohLevels(c));
      acc(c) = 1-mean(blockER(thisCoherIndex));
    end
    %accErr(c) = std(1-blockER(thisCoherIndex));
    % binomial error
    accErr(c) = sqrt(acc(c)*(1-acc(c)))/sqrt(length(thisCoherIndex));
    meanRT(c) = mean(blockRT(thisCoherIndex));
    varRT(c) = std(blockRT(thisCoherIndex));
  end
  figure(1)
  if plotErr
    if plotLog
      errorbar(log(cohLevels),acc,accErr,['s' colorVec{b}],'MarkerFaceColor',colorVec{b}); 
    else
      errorbar(cohLevels,acc,accErr,['s' colorVec{b}],'MarkerFaceColor',colorVec{b});    
    end
  else
    if plotLog
      plot(log(cohLevels),acc,['s' colorVec{b}],'MarkerFaceColor',colorVec{b});
    else
      plot(cohLevels,acc,['s' colorVec{b}],'MarkerFaceColor',colorVec{b});
    end
  end
  if plotLog
    set(gca,'XTick',log(cohLevels));
    set(gca,'XTickLabel',cohLevels);
  end  
  if b==1
    hold on
  end
  xlabel('coherence (%)');
  ylabel('accuracy');
  publishfig
  title(sprintf('block %d',b),'FontSize',20);
  figure(2)
  if plotErr
    if plotLog
      errorbar(log(cohLevels),meanRT,varRT,['v' colorVec{b}],'MarkerFaceColor',colorVec{b},'MarkerSize',10);  
    else
      errorbar(cohLevels,meanRT,varRT,['v' colorVec{b}],'MarkerFaceColor',colorVec{b},'MarkerSize',10);    
    end
  else
    if plotLog
      plot(log(cohLevels),meanRT,['v' colorVec{b}],'MarkerFaceColor',colorVec{b},'MarkerSize',10);
    else
      plot(cohLevels,meanRT,['v' colorVec{b}],'MarkerFaceColor',colorVec{b},'MarkerSize',10);      
    end
  end
  if plotLog
    set(gca,'XTick',log(cohLevels));
    set(gca,'XTickLabel',cohLevels);
  end
  if b==1
    hold on
  end  
  xlabel('coherence (%)');
  ylabel('RT');
  publishfig
  title(sprintf('block %d',b),'FontSize',20);
  acc'
  meanRT'
  % fit a psychometric function to these data (NEED TO RESCALE THE
  % DATA BEFORE FITTING?)
  all_cdf = setdiff(1:3,cdf_type);
  try
    params = fminunc(@(x) psychometric_error_function(x,cohLevels,acc',cdf_type),[1,1])
  catch
    cdf_type = all_cdf(1);
    all_cdf = setdiff(all_cdf,cdf_type);
    try
      fprintf('trying cdf_type %d...\n',cdf_type);
      params = fminunc(@(x) psychometric_error_function(x,cohLevels,acc',cdf_type),[1,1])      
    catch
      cdf_type = all_cdf;
      fprintf('trying cdf_type %d...\n',cdf_type);
      params = fminunc(@(x) psychometric_error_function(x,cohLevels,acc',cdf_type),[1,1])      
    end
  end
  paramsVec(b,:) = params;
  keyboard
  % plot the fitted function
  figure(1)
  hold on
  if plotLog
    if cdf_type == 1
      plot(log(cohLevels(1):0.5:cohLevels(end)),normcdf(params(1)*[cohLevels(1):0.5:cohLevels(end)]+params(2)),colorVec{b});
    elseif cdf_type == 2
      plot(log(cohLevels(1):0.5:cohLevels(end)),wblcdf([cohLevels(1):0.5:cohLevels(end)]-cohLevels(1),params(1),params(2)),colorVec{b});
    elseif cdf_type == 3
      plot(log(cohLevels(1):0.5:cohLevels(end)),gamcdf([cohLevels(1):0.5: cohLevels(end)],params(1),params(2)),colorVec{b});
    end
  else
    if cdf_type == 1
      plot(cohLevels(1):0.5:cohLevels(end),normcdf(params(1)*[cohLevels(1):0.5:cohLevels(end)]+params(2)),colorVec{b});
    elseif cdf_type == 2
      plot(cohLevels(1):0.5:cohLevels(end),wblcdf([cohLevels(1):0.5:cohLevels(end)]-cohLevels(1),params(1),params(2)),colorVec{b});
    elseif cdf_type == 3
      plot(cohLevels(1):0.5:cohLevels(end),gamcdf([cohLevels(1):0.5: cohLevels(end)],params(1),params(2)),colorVec{b});
    end
  end
  
  pause
end
figure(1)
%hold off



% estimate the 90% and 70% correct coherence levels for this
% participant using the mean parameters of the psychometric
% function
% meanPars = mean(paramsVec);
% if cdf_type==1
%   plot(cohLevels(1):.5:cohLevels(end),normcdf(meanPars(1)*[cohLevels(1):0.5:cohLevels(end)]+meanPars(2)),'k');  
% else
%   plot(cohLevels(1):.5:cohLevels(end),gamcdf([cohLevels(1):0.5:cohLevels(end)],meanPars(1),meanPars(2)),'k');
% end
% hold off

coh80perc=  zeros(numblocks,1);
coh60perc = zeros(numblocks,1);
for c = 1:numblocks
  switch cdf_type
   case 1
    coh80perc(c) = (norminv(0.8)-paramsVec(c,2))/paramsVec(c,1);
    coh60perc(c) = (norminv(0.6)-paramsVec(c,2))/paramsVec(c,1);
   case 2
    coh80perc(c) = wblinv(0.8,paramsVec(c,1),paramsVec(c,2));
    coh60perc(c) = wblinv(0.6,paramsVec(c,1),paramsVec(c,2));
   case 3
    coh80perc(c) = gaminv(0.8,paramsVec(c,1),paramsVec(c,2));
    coh60perc(c) = gaminv(0.6,paramsVec(c,1),paramsVec(c,2));
  end %switch
end

figure(1); hold off; figure(2); hold off

% remaining questions:
% 1) are the psychometric functions reliable enough? need more
% trials per condition or different coherences?
% 2) how do these results relate to the QUEST estimates?
% 3) how to best fit the psychometric function? (maybe use MLE to
% get something like a BIC/AIC?)
