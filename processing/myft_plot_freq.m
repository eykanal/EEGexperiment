function myft_plot_freq(data, varargin)
%
% function plot_freq(data)
%
% plot frequency data

singleChannel   = keyval('singleChannel', varargin);    if isempty(singleChannel); singleChannel = 0;            end
ylim            = keyval('ylim', varargin);             if isempty(ylim);          ylim          = [0 3e-27];    end

cfg             = [];
cfg.method      = 'mtmfft';
cfg.output      = 'pow';
cfg.calcdof     = 'yes';
cfg.taper       = 'hanning';
cfg.foilim      = [1 100];
data_freq       = ft_freqanalysis( cfg, data );

if singleChannel == 0
    % plot whole head
    cfg             = [];
    cfg.layout      = 'neuromag306all.lay';
    cfg.showlabels  = 'no';
    cfg.ylim        = ylim;
    figure();
    ft_multiplotER( cfg, data_freq );
else 
    % plot single channel
    cfg             = [];
    cfg.channel     = singleChannel;
    cfg.ylim        = ylim;
    figure();
    ft_singleplotER( cfg, data_freq );
end
    