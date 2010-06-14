function pulsed_dots_plot(subject,session)

% function pulsed_dots_plot(subject)
%
% 4/13/09: This function plots out the payment, accuracy and RT info on a
% trial-by-trial basis for the penalty_dots.m experiment.

% load(sprintf('pulsed_dots_subject%d_Data.mat',subject));
load(sprintf('Data%d/penalty_dots_subject%d_ses%d.mat',subject,subject,session));


figure
hold on
title(sprintf('Penalty Dots, Subject %d',subject));


num_plots = 5;

subplot(num_plots,1,1)
plot(DataStruct.RT,'k--.')
ylabel('RT')
title(sprintf('Penalty Dots, Subject %d',subject));

subplot(num_plots,1,2)
plot(find(DataStruct.ER==1),0,'r.')
hold on
for i = 1:DataStruct.BlockNumber(end)
    plot(find(DataStruct.BlockNumber==i),mean(DataStruct.ER(find(DataStruct.BlockNumber==i))),'k-');
end
ylabel('Error')

subplot(num_plots,1,3)
plot(DataStruct.Score,'g')
ylabel('Score($)')

subplot(num_plots,1,4)
plot(DataStruct.Coherence,'c')
ylabel('Coherence')


subplot(num_plots,1,5)
hold on
% plot(DataStruct.VisibilityFlag,'m')
% plot(1.05*DataStruct.CoherenceFlag,'y')
% plot(1.1*DataStruct.IncreasingDurationFlag,'b')
% legend('Visibility','Coherence','Increasing Duration')
plot(DataStruct.PenaltyMagnitude,'r');
plot(DataStruct.RewardMagnitude,'g');
legend('Penalty','Reward')


xlabel('Trial Number')