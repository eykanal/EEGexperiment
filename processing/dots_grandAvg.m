conds = {'resp','stim'};

for n=1:length(conds)
    
    cond = conds{n};

    % define filenames
    all = { ...
        sprintf('17-preprocessed-%s-coh-h', cond), ...
        sprintf('17-preprocessed-%s-coh-m', cond), ...
        sprintf('17-preprocessed-%s-coh-l', cond), ...
        sprintf('18-preprocessed-%s-coh-h', cond), ...
        sprintf('18-preprocessed-%s-coh-m', cond), ...
        sprintf('18-preprocessed-%s-coh-l', cond), ...
        sprintf('19-preprocessed-%s-coh-h', cond), ...
        sprintf('19-preprocessed-%s-coh-m', cond), ...
        sprintf('19-preprocessed-%s-coh-l', cond), ...
    };

    high = findSubset(all, 'coh-h');
    mid  = findSubset(all, 'coh-m');
    low  = findSubset(all, 'coh-l');

    % load data
    data_grand_high = [];
    data_grand_mid  = [];
    data_grand_low  = [];
    
    for n=1:length(all)

        % load it up
        fprintf('Loading %s\n', all{n})
        load(all{n});

        % run time averaging
        cfg             = [];
        cfg.channel     = {'M*'};
        cfg.keeptrials  = 'no';
        cfg.covariance  = 'yes';
        data_timelock   = ft_timelockanalysis(cfg, data_preprocessed); 

        % run freq analysis
        cfg             = [];
        cfg.method      = 'mtmfft';
        cfg.output      = 'pow';
        cfg.calcdof     = 'yes';
        cfg.taper       = 'hanning';
        cfg.foilim      = [1 100];
        data_freq       = ft_freqanalysis(cfg, data_preprocessed);

        % run tfr analysis
        if strcmp(cond, 'stim')
            toi     = -0.1:0.05:0.7;
        else
            toi     = -0.7:0.05:0.1;
        end
        
        cfg             = [];
        cfg.channel     = {'M*'};
        cfg.output      = 'pow';
        cfg.method      = 'mtmconvol';
        cfg.taper       = 'hanning';
        cfg.foi         = 1:1:100;
        cfg.t_ftimwin   = 5./cfg.foi;
        cfg.toi         = toi;
        cfg.verbose     = 0;
        data_freq_varWind = ft_freqanalysis(cfg, data_preprocessed);

        % save the output (1) to variable for grandaveraging at end, (2) to
        % file for storage
        if ismember(all{n}, high)
            index = length(data_grand_high) + 1;
            data_grand_high(index).data_timelock        = data_timelock;
            data_grand_high(index).data_freq            = data_freq;
            data_grand_high(index).data_freq_varWind    = data_freq_varWind;
        elseif ismember(all{n}, mid)
            index = length(data_grand_mid) + 1;
            data_grand_mid(index).data_timelock         = data_timelock;
            data_grand_mid(index).data_freq             = data_freq;
            data_grand_mid(index).data_freq_varWind     = data_freq_varWind;
        elseif ismember(all{n}, low)
            index = length(data_grand_low) + 1;
            data_grand_low(index).data_timelock         = data_timelock;
            data_grand_low(index).data_freq             = data_freq;
            data_grand_low(index).data_freq_varWind     = data_freq_varWind;
        else
            error('no match! %s', all{n});
        end

        path    = fileparts(which([all{n} '.mat']));
        tokens  = regexp(all{n},'(\d{2})-preprocessed-(stim|resp)-coh-([hml])','tokens');
        tokens  = tokens{1};
        save([path '/' sprintf('%s-timelock-%s-coh-%s.mat',tokens{1},tokens{2},tokens{3})], 'data_timelock');
        save([path '/' sprintf('%s-freq-%s-coh-%s.mat',tokens{1},tokens{2},tokens{3})], 'data_freq');
        save([path '/' sprintf('%s-tf-%s-coh-%s.mat',tokens{1},tokens{2},tokens{3})], 'data_freq_varWind');

        % plot figures, save plots to disk
        num_trials = length(data_preprocessed.trial);

        % time
        data_timelockU      = data_timelock;  % calculate variances
        data_timelockD      = data_timelock;
        data_timelockU.avg  = data_timelock.avg + sqrt(data_timelock.var);
        data_timelockD.avg  = data_timelock.avg - sqrt(data_timelock.var);

        cfg                 = [];
        cfg.showlabels      = 'no';
        cfg.graphcolor      = [0 0 1; 0.6 0.6 1; 0.6 0.6 1];
        cfg.ylim            = [-4.25e-13 4.25e-13];

        h = figure();
        cfg.layout          = 'neuromag306mag.lay';
        ft_multiplotER(cfg, data_timelock, data_timelockU, data_timelockD);
        title(sprintf('Subject %s, %i trials, time series, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-time-mag.pdf',tokens{1},tokens{3})]);
        close(h);

        h = figure();
        cfg.layout          = 'neuromag306planar.lay';
        ft_multiplotER(cfg, data_timelock, data_timelockU, data_timelockD);
        title(sprintf('Subject %s, %i trials, time series, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-time-grad.pdf',tokens{1},tokens{3})]);
        close(h);

        % freq
        cfg             = [];
        cfg.showlabels  = 'no';
        cfg.ylim        = [0 3e-27];

            % 1-100
        cfg.xlim   = [1 100];

        h = figure();
        cfg.layout      = 'neuromag306mag.lay';
        ft_multiplotER( cfg, data_freq );
        title(sprintf('Subject %s, %i trials, frequency, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-freq-1-100-mag.pdf',tokens{1},tokens{3})]);
        close(h);

        h = figure();
        cfg.layout      = 'neuromag306planar.lay';
        ft_multiplotER( cfg, data_freq );
        title(sprintf('Subject %s, %i trials, frequency, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-freq-1-100-grad.pdf',tokens{1},tokens{3})]);
        close(h);

            % 1-40
        cfg.xlim   = [1 40];

        h = figure();
        cfg.layout      = 'neuromag306mag.lay';
        ft_multiplotER( cfg, data_freq );
        title(sprintf('Subject %s, %i trials, frequency, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-freq-1-40-mag.pdf',tokens{1},tokens{3})]);
        close(h);

        h = figure();
        cfg.layout      = 'neuromag306planar.lay';
        ft_multiplotER( cfg, data_freq );
        title(sprintf('Subject %s, %i trials, frequency, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-tf-1-40-grad.pdf',tokens{1},tokens{3})]);
        close(h);

        % tf
        cfg             = [];
        cfg.showlabels  = 'no';	

            % 1-100
        cfg.ylim   = [1 100];
        cfg.zlim        = [-7e-27 7e-27];

        h = figure();
        cfg.layout      = 'neuromag306mag.lay';
        ft_multiplotTFR(cfg, data_freq_varWind);
        title(sprintf('Subject %s, %i trials, time-frequency, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-tf-1-100-mag.pdf',tokens{1},tokens{3})]);
        close(h);

        h = figure();
        cfg.layout      = 'neuromag306planar.lay';
        ft_multiplotTFR(cfg, data_freq_varWind);
        title(sprintf('Subject %s, %i trials, time-frequency, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-tf-1-100-grad.pdf',tokens{1},tokens{3})]);
        close(h);

            % 1-40
        cfg.ylim   = [1 40];
        cfg.zlim        = [-2e-26 2e-26];

        h = figure();
        cfg.layout      = 'neuromag306mag.lay';
        ft_multiplotTFR(cfg, data_freq_varWind);
        title(sprintf('Subject %s, %i trials, time-frequency, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-tf-1-40-mag.pdf',tokens{1},tokens{3})]);
        close(h);

        h = figure();
        cfg.layout      = 'neuromag306planar.lay';
        ft_multiplotTFR(cfg, data_freq_varWind);
        title(sprintf('Subject %s, %i trials, time-frequency, %s coh @ %s, processed',tokens{1},num_trials,tokens{3},tokens{2}));
        saveas(h, [path '/figures/' sprintf('%s-resp-%s-proc-tf-1-40-grad.pdf',tokens{1},tokens{3})]);
        close(h);

        clear data_timelock data_freq data_freq_varWind;
    end
    
    cfg                 = [];
    cfg.keepindividual  = 'yes';
    
    % time
    data_grandAvg_timelock_high = ft_timelockgrandaverage(cfg, data_grand_high(:).data_timelock);
    data_grandAvg_timelock_mid  = ft_timelockgrandaverage(cfg, data_grand_mid(:).data_timelock);
    data_grandAvg_timelock_low  = ft_timelockgrandaverage(cfg, data_grand_low(:).data_timelock);
    % freq
    data_grandAvg_freq_high     = ft_freqgrandaverage(cfg, data_grand_high(:).data_freq);
    data_grandAvg_freq_mid      = ft_freqgrandaverage(cfg, data_grand_mid(:).data_freq);
    data_grandAvg_freq_low      = ft_freqgrandaverage(cfg, data_grand_low(:).data_freq);
    % tf
    data_grandAvg_freq_varWind_high = ft_freqgrandaverage(cfg, data_grand_high(:).data_freq_varWind);
    data_grandAvg_freq_varWind_mid  = ft_freqgrandaverage(cfg, data_grand_mid(:).data_freq_varWind);
    data_grandAvg_freq_varWind_low  = ft_freqgrandaverage(cfg, data_grand_low(:).data_freq_varWind);

    clear data_grand_high data_grand_mid data_grand_low;

    % save to disk
    grandAvg_path = '/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/';

    save(sprintf('%s%s-coh-gAvg-timelock-high.mat', grandAvg_path, cond), 'data_grandAvg_timelock_high');
    save(sprintf('%s%s-coh-gAvg-timelock-mid.mat', grandAvg_path, cond) , 'data_grandAvg_timelock_mid');
    save(sprintf('%s%s-coh-gAvg-timelock-low.mat', grandAvg_path, cond) , 'data_grandAvg_timelock_low');

    save(sprintf('%s%s-coh-gAvg-freq-high.mat', grandAvg_path, cond), 'data_grandAvg_freq_high');
    save(sprintf('%s%s-coh-gAvg-freq-mid.mat', grandAvg_path, cond) , 'data_grandAvg_freq_mid');
    save(sprintf('%s%s-coh-gAvg-freq-low.mat', grandAvg_path, cond) , 'data_grandAvg_freq_low');

    save(sprintf('%s%s-coh-gAvg-freqVarWind-high.mat', grandAvg_path, cond), 'data_grandAvg_freq_varWind_high');
    save(sprintf('%s%s-coh-gAvg-freqVarWind-mid.mat', grandAvg_path, cond) , 'data_grandAvg_freq_varWind_mid');
    save(sprintf('%s%s-coh-gAvg-freqVarWind-low.mat', grandAvg_path, cond) , 'data_grandAvg_freq_varWind_low');

    % plot figures, save plots to disk

    % time
    data_timelockU_grandAvg_high    = data_grandAvg_timelock_high;
    data_timelockD_grandAvg_high    = data_grandAvg_timelock_high;
    data_timelockU_grandAvg_high.avg= data_grandAvg_timelock_high.avg + sqrt(data_grandAvg_timelock_high.var);
    data_timelockD_grandAvg_high.avg= data_grandAvg_timelock_high.avg - sqrt(data_grandAvg_timelock_high.var);
    data_timelockU_grandAvg_mid     = data_grandAvg_timelock_mid;
    data_timelockD_grandAvg_mid     = data_grandAvg_timelock_mid;
    data_timelockU_grandAvg_mid.avg = data_grandAvg_timelock_mid.avg + sqrt(data_grandAvg_timelock_mid.var);
    data_timelockD_grandAvg_mid.avg = data_grandAvg_timelock_mid.avg - sqrt(data_grandAvg_timelock_mid.var);
    data_timelockU_grandAvg_low     = data_grandAvg_timelock_low;
    data_timelockD_grandAvg_low     = data_grandAvg_timelock_low;
    data_timelockU_grandAvg_low.avg = data_grandAvg_timelock_low.avg + sqrt(data_grandAvg_timelock_low.var);
    data_timelockD_grandAvg_low.avg = data_grandAvg_timelock_low.avg - sqrt(data_grandAvg_timelock_low.var);

    cfg             = [];
    cfg.showlabels  = 'no';
    cfg.ylim        = [-4.25e-13 4.25e-13];
    cfg.graphcolor  = [0 0 1; 0.6 0.6 1; 0.6 0.6 1];
    cfg.layout = 'neuromag306mag.lay';
    h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_high, data_timelockU_grandAvg_high, data_timelockD_grandAvg_high);  title('timelock grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_timelock_high-mag.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_mid,  data_timelockU_grandAvg_mid,  data_timelockD_grandAvg_mid );  title('timelock grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_timelock_mid-mag.pdf', grandAvg_path, cond));     close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_low,  data_timelockU_grandAvg_low,  data_timelockD_grandAvg_low );  title('timelock grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_timelock_low-mag.pdf', grandAvg_path, cond));     close(h);
    cfg.layout = 'neuromag306planar.lay';
    h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_high, data_timelockU_grandAvg_high, data_timelockD_grandAvg_high);  title('timelock grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_timelock_high-grad.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_mid,  data_timelockU_grandAvg_mid,  data_timelockD_grandAvg_mid );  title('timelock grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_timelock_mid-grad.pdf', grandAvg_path, cond));     close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_low,  data_timelockU_grandAvg_low,  data_timelockD_grandAvg_low );  title('timelock grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_timelock_low-grad.pdf', grandAvg_path, cond));     close(h);

    % freq
    cfg             = [];
    cfg.showlabels  = 'no';
    cfg.ylim        = [0 3e-27];
        % 1-100
    cfg.xlim   = [1 100];
    cfg.layout = 'neuromag306mag.lay';
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_high        );  title('freq grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_high-mag.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_mid         );  title('freq grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_mid-mag.pdf', grandAvg_path, cond));     close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_low         );  title('freq grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_low-mag.pdf', grandAvg_path, cond));     close(h);
    cfg.layout = 'neuromag306planar.lay';
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_high        );  title('freq grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_high-grad.pdf', grandAvg_path, cond));   close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_mid         );  title('freq grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_mid-grad.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_low         );  title('freq grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_low-grad.pdf', grandAvg_path, cond));    close(h);
        % 1-40
    cfg.xlim   = [1 40];
    cfg.layout = 'neuromag306mag.lay';
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_high        );  title('freq grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_high-mag.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_mid         );  title('freq grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_mid-mag.pdf', grandAvg_path, cond));     close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_low         );  title('freq grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_low-mag.pdf', grandAvg_path, cond));     close(h);
    cfg.layout = 'neuromag306planar.lay';
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_high        );  title('freq grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_high-grad.pdf', grandAvg_path, cond));   close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_mid         );  title('freq grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_mid-grad.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_low         );  title('freq grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_low-grad.pdf', grandAvg_path, cond));    close(h);

    % tf
    cfg             = [];
    cfg.showlabels  = 'no';	
        % 1-100
    cfg.ylim   = [1 100];
    cfg.zlim   = [-7e-27 7e-27];
    cfg.layout = 'neuromag306mag.lay';
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_high);  title('freq grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_varWind_high-mag.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_mid );  title('freq grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_varWind_mid-mag.pdf', grandAvg_path, cond));     close(h);
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_low );  title('freq grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_varWind_low-mag.pdf', grandAvg_path, cond));     close(h);
    cfg.layout = 'neuromag306planar.lay';
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_high);  title('freq grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_varWind_high-grad.pdf', grandAvg_path, cond));   close(h);
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_mid );  title('freq grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_varWind_mid-grad.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_low );  title('freq grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-100_varWind_low-grad.pdf', grandAvg_path, cond));    close(h);
        % 1-40
    cfg.ylim   = [1 40];
    cfg.zlim   = [-2e-26 2e-26];
    cfg.layout = 'neuromag306mag.lay';
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_high);  title('freq grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_varWind_high-mag.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_mid );  title('freq grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_varWind_mid-mag.pdf', grandAvg_path, cond));     close(h);
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_low );  title('freq grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_varWind_low-mag.pdf', grandAvg_path, cond));     close(h);
    cfg.layout = 'neuromag306planar.lay';
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_high);  title('freq grand avg high');   saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_varWind_high-grad.pdf', grandAvg_path, cond));   close(h);
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_mid );  title('freq grand avg mid');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_varWind_mid-grad.pdf', grandAvg_path, cond));    close(h);
    h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_low );  title('freq grand avg low');    saveas(h, sprintf('%sgrandAvg_%s_coh_freq-1-40_varWind_low-grad.pdf', grandAvg_path, cond));    close(h);
end

conds = {'resp','stim'};

% Statistics
for n=1:length(conds)
    
    % redefine constants (for convenience, also defined as "because I'm too
    % lazy to split this into two separate functions right now")
    path    = fileparts(which([all{1} '.mat']));
    grandAvg_path = '/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/';

    cond = conds{n};
    
    load(sprintf('%s%s-coh-gAvg-timelock-high.mat', grandAvg_path, cond), 'data_grandAvg_timelock_high');
    load(sprintf('%s%s-coh-gAvg-timelock-mid.mat', grandAvg_path, cond) , 'data_grandAvg_timelock_mid');
    load(sprintf('%s%s-coh-gAvg-timelock-low.mat', grandAvg_path, cond) , 'data_grandAvg_timelock_low');

    load(sprintf('%s%s-coh-gAvg-freq-high.mat', grandAvg_path, cond), 'data_grandAvg_freq_high');
    load(sprintf('%s%s-coh-gAvg-freq-mid.mat', grandAvg_path, cond) , 'data_grandAvg_freq_mid');
    load(sprintf('%s%s-coh-gAvg-freq-low.mat', grandAvg_path, cond) , 'data_grandAvg_freq_low');

    load(sprintf('%s%s-coh-gAvg-freqVarWind-high.mat', grandAvg_path, cond), 'data_grandAvg_freq_varWind_high');
    load(sprintf('%s%s-coh-gAvg-freqVarWind-mid.mat', grandAvg_path, cond) , 'data_grandAvg_freq_varWind_mid');
    load(sprintf('%s%s-coh-gAvg-freqVarWind-low.mat', grandAvg_path, cond) , 'data_grandAvg_freq_varWind_low');

    
    % tf
    stat_diff_time = [0.15 0.50];
    stat_diff_freq = [8 12];
    labels = {'MEG2011', 'MEG2021', 'MEG2031', 'MEG2041'};
    sig = [];
    
    for m=1:length(labels)
        label = labels{m};
        
        dat1 = data_grandAvg_freq_varWind_high;
        mean_tf_high = squeeze(mean(mean( ...
            dat1.powspctrm( :, strcmp(dat1.label, label), dat1.freq >= 8 & dat1.freq <= 12, dat1.time >= -0.7 & dat1.time <= -0.15 )...
            ,3),1));
        dat2 = data_grandAvg_freq_varWind_low;
        mean_tf_low  = squeeze(mean(mean( ...
            dat2.powspctrm( :, strcmp(dat2.label, label), dat2.freq >= 8 & dat2.freq <= 12, dat2.time >= -0.7 & dat2.time <= -0.15 ) ...
            ,3),1));
        mean_tf_diff = mean_tf_high - mean_tf_low;
        [sig(m).h, sig(m).p, sig(m).ci, sig(m).stats] = ttest(mean_tf_diff, 0, 0.05);
        
        figure();
        plot(dat1.time, squeeze(mean(mean(dat1.powspctrm(:, strcmp(dat1.label, label), dat1.freq >= 8 & dat1.freq <= 12, :),1),3)),'-xb', ...
             dat2.time, squeeze(mean(mean(dat2.powspctrm(:, strcmp(dat2.label, label), dat2.freq >= 8 & dat2.freq <= 12, :),1),3)),'-xr');
        title(label);
    end
    
    cfg = [];
    cfg.method              = 'distance';
    cfg.layout              = 'neuromag306mag.lay';
    neighbours              = ft_neighbourselection(cfg, data_grandAvg_freq_varWind_high);
    
    % non-parametric analysis (from
    % http://fieldtrip.fcdonders.nl/tutorial/cluster_permutation_freq#within_subjects_experiments)
    cfg = [];
    cfg.channel             = 'MEG';
    cfg.latency             = [0.2 0.7];
    cfg.frequency           = [10 10];
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'actvsblT';
    cfg.correctm            = 'cluster';
    cfg.clusteralpha        = 0.05;
    cfg.clusterstatistic    = 'maxsum';
    cfg.minbchan            = 2;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.alpha               = 0.025;
    cfg.numrandomization    = 500;
    cfg.neighbours          = neighbours;
    
    Nsub = 3;
    cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
    cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
    cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
    cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

    stat = ft_freqstatistics(cfg, data_grandAvg_freq_varWind_high, data_grandAvg_freq_varWind_low);

    % difference freq_varWind data
    data_grandAvg_freq_varWind_diff = data_grandAvg_freq_varWind_high;
    data_grandAvg_freq_varWind_diff.powspctrm = data_grandAvg_freq_varWind_high.powspctrm - data_grandAvg_freq_varWind_low.powspctrm;
    
    % make a plot
    cfg = [];
    cfg.style     = 'blank';
    cfg.layout    = 'neuromag306mag.lay';
    cfg.highlight = 'on';
    cfg.highlightchannel = find(stat.mask);
    cfg.comment   = 'no';
    figure; ft_topoplotER(cfg, data_grandAvg_freq_varWind_diff)
    title('Nonparametric: significant with cluster multiple comparison correction')    

    cfg = [];
    cfg.alpha  = 0.45;
    cfg.zparam = 'stat';
    cfg.zlim   = [-10 10];
    cfg.layout= 'neuromag306mag.lay';
    ft_clusterplot(cfg, stat);
    
    % Differencing
    % time
    data_grandAvg_timelock_diff = data_grandAvg_timelock_high;
    data_grandAvg_timelock_diff.avg = data_grandAvg_timelock_high.avg - data_grandAvg_timelock_low.avg;
    data_grandAvg_timelock_diff.var = data_grandAvg_timelock_high.var + data_grandAvg_timelock_low.var;
    % freq
    % run freq analysis
    cfg             = [];
    cfg.method      = 'mtmfft';
    cfg.output      = 'pow';
    cfg.calcdof     = 'yes';
    cfg.taper       = 'hanning';
    cfg.foilim      = [1 100];
    data_grandAvg_freq_diff = ft_freqanalysis(cfg, data_grandAvg_timelock_diff);
    % tfr
    cfg             = [];
    cfg.channel     = {'M*'};
    cfg.output      = 'pow';
    cfg.method      = 'mtmconvol';
    cfg.taper       = 'hanning';
    cfg.foi         = 1:1:100;
    cfg.t_ftimwin   = 5./cfg.foi;
    cfg.toi         = -0.1:0.05:0.7;
    cfg.verbose     = 0;
    data_grandAvg_freq_varWind = ft_freqanalysis(cfg, data_grandAvg_timelock_diff);
    
    
end

% %############################################
% %##            SUBFUNCTIONS                ##
% %############################################
% 
% % average all datafiles together;
% function gAvg = grandAvg(datafiles)
% % Load up all averaged datafiles
% avgs = [];
% for n=1:length(datafiles)
%     avgs(n).avg = load(datafiles{n});
%     avgs(n).avg = avgs(n).avg.data_timelock;
% end
% 
% % Average them into one large grand-averaged file
% cfg = [];
% gAvg = ft_timelockgrandaverage(cfg, avgs(:).avg);
% 
% 
% % perform differencing
% function diffs = differenceAvgs(avg1, avg2)
% diffs = avg1;
% diffs.avg = avg1.avg - avg2.avg;
% 
% % extract relevant datasets
% function subset = findSubset(all, pattern)
% tmp     = (regexp(all, pattern));
% subset  = all(~cellfun(@isempty,tmp));