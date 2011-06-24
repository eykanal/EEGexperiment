function myft_plot_time(data)
% 
% function myft_plot_time(data)
%
% Plot averaged general activity with variance

cfg.channel     = {'M*'};
cfg.keeptrials  = 'no';
cfg.covariance  = 'yes';
data_timelock   = ft_timelockanalysis(cfg, data);

data_timelockU      = data_timelock;
data_timelockD      = data_timelock;
data_timelockU.avg  = data_timelock.avg + sqrt(data_timelock.var);
data_timelockD.avg  = data_timelock.avg - sqrt(data_timelock.var);

cfg                 = [];
cfg.layout          = 'neuromag306all.lay';
cfg.showlabels      = 'no';
cfg.graphcolor      = [0 0 1; 0.75 0.75 1; 0.75 0.75 1];
figure();
ft_multiplotER(cfg, data_timelock, data_timelockU, data_timelockD);