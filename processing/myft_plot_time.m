function myft_plot_time(data, varargin)
% 
% function myft_plot_time(data)
%
% Plot averaged general activity with variance

% Get optional inputs
xlim    = keyval('ylim',    varargin); if isempty(xlim),    xlim = 'maxmin';                end
ylim    = keyval('ylim',    varargin); if isempty(ylim),    ylim = [-4.25e-13 4.25e-13];    end
average = keyval('average', varargin); if isempty(average), average = 1;                    end
chans   = keyval('chans',   varargin); if isempty(chans),   chans = {'all'};                end

% don't average if already averaged; ruins the variance data
if average
    cfg.channel         = {'M*'};
    cfg.keeptrials      = 'no';
    cfg.covariance      = 'yes';
    data_timelock   = ft_timelockanalysis(cfg, data);
else
    data_timelock   = data;
end

% calculate variances
data_timelockU      = data_timelock;
data_timelockD      = data_timelock;
data_timelockU.avg  = data_timelock.avg + sqrt(data_timelock.var);
data_timelockD.avg  = data_timelock.avg - sqrt(data_timelock.var);

% plot
if ~iscell(chans), chans = {chans}; end

if strcmp(chans{1},'all')
    cfg                 = [];
    cfg.layout          = 'neuromag306all.lay';
    cfg.showlabels      = 'no';
    cfg.graphcolor      = [0 0 1; 0.6 0.6 1; 0.6 0.6 1];
    cfg.ylim            = ylim;
    figure();
    ft_multiplotER(cfg, data_timelock, data_timelockU, data_timelockD);
else
    for n=1:length(chans)
        cfg                 = [];
        cfg.channel         = chans{n};
        cfg.graphcolor      = [0 0 1; 0.6 0.6 1; 0.6 0.6 1];
        cfg.xlim            = xlim;
        cfg.ylim            = ylim;
        figure();
        ft_singleplotER(cfg, data_timelock, data_timelockU, data_timelockD);

        line(get(gca,'xlim'), [0 0], 'Color', [0 0 0]);
        title(chans{n});
    end
end
