function myft_plot_tf(data, analysisTimes)
%
% myft_plot_tf(data, analysisTimes)
%
%

cfg             = [];
cfg.channel     = {'M*'};
cfg.output      = 'pow';
cfg.method      = 'mtmconvol';
cfg.taper       = 'hanning';
cfg.foi         = 1:30;
cfg.t_ftimwin   = 2./cfg.foi;
cfg.toi         = -analysisTimes(1)/1000:0.05:analysisTimes(2)/1000;
data_freq_varWind = ft_freqanalysis(cfg, data);

cfg             = [];
cfg.showlabels  = 'no';	
cfg.layout      = 'neuromag306all.lay';
cfg.zlim        = [-7e-26 7e-26];
figure();
ft_multiplotTFR(cfg, data_freq_varWind);

tfr_zaxis_size = cfg.zlim;
while ~isempty(tfr_zaxis_size)
    tfr_zaxis_size = input( 'Input alternate zlim (leave blank to continue): ');
    if ismatrix(tfr_zaxis_size) && ~isempty(tfr_zaxis_size)
        cfg.zlim = tfr_zaxis_size;
        ft_multiplotTFR(cfg, data_freq_varWind);
    end
end
