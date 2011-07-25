data = data_preprocessed;
width   = 4;
height  = 10;
trials  = 'all';
channel = 'MEG0623';
plotType= 'time';

figure();
for n=1:width
    for m=1:height
        i = m+(n-1)*height;
        
        switch plotType
            case 'time'
                cfg             = [];
                cfg.channel     = 'MEG0623';
                cfg.ylim        = [-1e-12 1e-12];
                cfg.trials      = i;
                subplot(height, width, i);
                ft_singleplotER(cfg, data);
                title(['trial ' num2str(i)]);

            case 'freq'
                cfg             = [];
                cfg.method      = 'mtmfft';
                cfg.output      = 'pow';
                cfg.calcdof     = 'yes';
                cfg.taper       = 'hanning';
                cfg.foilim      = [1 40];
                cfg.trials      = i;
                data_freq       = ft_freqanalysis( cfg, data );

                cfg             = [];
                cfg.channel     = channel;
                cfg.ylim        = [0 5e-26];
                subplot(height, width, i);
                ft_singleplotER(cfg, data_freq);
                title(['trial ' num2str(i)]);
                
            case 'tf'
                
        end
    end
end
