function plotPsychometric(subject,sess,plotColor,notHoldOff)
% function plotPsychometric(subject,sess,plotColor,notHoldOff);
% plot the psychometric function from data collected in
% experiment_eeg.m
% color = 'b'   - line color
% notHoldOff - when set to 1, the graphs will not hold off, so you
% can add future data points to it (default =0)

if ~exist('subject','var')
    subject = 11;
end
if ~exist('sess','var')
    sess = 1;
end
if ~exist('plotColor','var')
    plotColor = 'b';
end
if ~exist('notHoldOff','var')
    notHoldOff = 0;
end


plotErr         = 1;    % whether to plot errorbars or simple lines
adFac           = 0.5;
twoDirections   = 0;    % when set to 1, fit the leftward motion as negative coherences
plotLog         = 0;    % whether to plot everything as a function of log-coherence
% cdf_type = 1 for normcdf
% cdf_type = 2 for weibull
% cdf_type = 3 for gamma funtion
cdf_type        = 3;

filename = sprintf ('subject%d_ses%s.mat', subject, sess);
load(['~/Documents/MATLAB/EEGexperiment/data/subj' num2str(subject) '/' filename]);

coherVec = unique(coherenceVec);

acc     = zeros(length(coherVec),1);
meanRT  = zeros(length(coherVec),1);
accErr  = zeros(length(coherVec),1);
varRT   = zeros(length(coherVec),1);

for c = 1:length(coherVec)
    if twoDirections
        % if leftward...
        if coherVec(c) < 0 
          thisCoherIndex    = intersect(find(coherenceVec == -coherVec(c)), find(RDir==76));
          acc(c)            = mean(ERpsych(thisCoherIndex));
          
        % if rightward...
        else 
          thisCoherIndex    = intersect(find(coherenceVec == coherVec(c)),  find(RDir==82));
          acc(c)            = 1-mean(ERpsych(thisCoherIndex));
        end
    else
        thisCoherIndex      = find(coherenceVec==coherVec(c));
        acc(c)              = 1-mean(ERpsych(thisCoherIndex));
    end
    accErr(c)   = sqrt(acc(c)*(1-acc(c)))/sqrt(length(thisCoherIndex));
    meanRT(c)   = mean(RTpsych(thisCoherIndex));
    varRT(c)    = std(RTpsych(thisCoherIndex));
end

% Accuracy plot
figure(1)
if plotErr
    if plotLog
        errorbar(log(coherVec), acc, accErr, ['s' plotColor], 'MarkerFaceColor', plotColor); 
    else
        errorbar(coherVec,      acc, accErr, ['s' plotColor], 'MarkerFaceColor', plotColor);    
    end
else
    if plotLog
        plot(log(coherVec),acc,['s' plotColor],'MarkerFaceColor',plotColor);
    else
        plot(coherVec,acc,['s' plotColor],'MarkerFaceColor',plotColor);
    end
end

if plotLog
    set(gca,'XTick'     ,log(coherVec));
    set(gca,'XTickLabel',coherVec);
end  
hold on
xlabel('coherence (%)');
ylabel('accuracy');

% RT plot
figure(2)
if plotErr
    if plotLog
        errorbar(log(coherVec), meanRT, varRT, ['v' plotColor], 'MarkerFaceColor', plotColor, 'MarkerSize', 10);  
    else
        errorbar(coherVec,      meanRT, varRT, ['v' plotColor], 'MarkerFaceColor', plotColor, 'MarkerSize', 10);    
    end
else
    if plotLog
        plot(log(coherVec), meanRT, ['v' plotColor], 'MarkerFaceColor', plotColor, 'MarkerSize', 10);
    else
        plot(coherVec,      meanRT, ['v' plotColor], 'MarkerFaceColor', plotColor, 'MarkerSize', 10);      
    end
end
if plotLog
    set(gca,'XTick',      log(coherVec));
    set(gca,'XTickLabel', coherVec);
end
line(xlim,[1 1]);  % mark where the response onset begins
hold on
xlabel('coherence (%)');
ylabel('RT');

display(acc);
display(meanRT);

% fit a psychometric function to these data (NEED TO RESCALE THE DATA BEFORE FITTING?)
try
    params = fminunc(@(x) psychometric_error_function(x, coherVec, acc', cdf_type), [1,1]);
catch
    params = zeros(1,length(coherVec));
end

% plot the fitted function
figure(1)
hold on
if plotLog
    if cdf_type == 1
        plot(log(coherVec(1):0.5:coherVec(end)),normcdf(params(1)*[coherVec(1):0.5:coherVec(end)]+params(2)),'color',plotColor);
    elseif cdf_type == 2
        plot(log(coherVec(1):0.5:coherVec(end)),wblcdf([coherVec(1):0.5:coherVec(end)]-coherVec(1),params(1),params(2)),'color',plotColor);
    elseif cdf_type == 3
        plot(log(coherVec(1):0.5:coherVec(end)),gamcdf([coherVec(1):0.5: coherVec(end)],params(1),params(2)),'color',plotColor);
    end
else
    if cdf_type == 1
        plot(coherVec(1):0.5:coherVec(end),normcdf(params(1)*[coherVec(1):0.5:coherVec(end)]+params(2)),'color',plotColor);
    elseif cdf_type == 2
        plot(coherVec(1):0.5:coherVec(end),wblcdf([coherVec(1):0.5:coherVec(end)]-coherVec(1),params(1),params(2)),'color',plotColor);
    elseif cdf_type == 3
        plot(coherVec(1):0.5:coherVec(end),gamcdf([coherVec(1):0.5: coherVec(end)],params(1),params(2)),'color',plotColor);
    end
end
  
if ~notHoldOff
    figure(1)
    hold off
    figure(2)
    hold off
end
