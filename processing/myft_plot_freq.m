function myft_plot_freq(data)
%
% function plot_freq(data)
%
% plot frequency data

cfg             = [];
cfg.method      = 'mtmfft';
cfg.output      = 'pow';
cfg.calcdof     = 'yes';
cfg.taper       = 'hanning';
cfg.foilim      = [1 40];
data_freq       = ft_freqanalysis( cfg, data );

cfg             = [];
cfg.layout      = 'neuromag306all.lay';
cfg.showlabels  = 'no';
cfg.ylim        = [0 3e-27];
figure();
ft_multiplotER( cfg, data_freq );