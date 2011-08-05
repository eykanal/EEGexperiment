function myft_plot_tf(data, analysisTimes, varargin)
%
% myft_plot_tf(data, analysisTimes)
%
%

layout  = keyval('layout',  varargin);  if isempty(layout),     layout = 'neuromag306mag.lay';  end
zlim    = keyval('zlim',    varargin);  if isempty(zlim),       zlim = [-7e-26 7e-26];          end
zlim_ask= keyval('zlim_ask',varargin);  if isempty(zlim_ask),   zlim_ask = 0;                   end

cfg             = [];
cfg.channel     = {'M*'};
cfg.output      = 'pow';
cfg.method      = 'mtmconvol';
cfg.taper       = 'hanning';
cfg.foi         = 2:1:30;
cfg.t_ftimwin   = 5./cfg.foi;
cfg.toi         = -analysisTimes(1)/1000:0.05:analysisTimes(2)/1000;
data_freq_varWind = ft_freqanalysis(cfg, data);

cfg             = [];
cfg.showlabels  = 'no';	
cfg.layout      = layout;
cfg.zlim        = zlim;
figure();
ft_multiplotTFR(cfg, data_freq_varWind);

if zlim_ask
    tfr_zaxis_size = cfg.zlim;
    while ~isempty(tfr_zaxis_size)
        tfr_zaxis_size = input( 'Input alternate zlim (leave blank to continue): ');
        if ismatrix(tfr_zaxis_size) && ~isempty(tfr_zaxis_size)
            cfg.zlim = tfr_zaxis_size;
            ft_multiplotTFR(cfg, data_freq_varWind);
        end
    end
end
