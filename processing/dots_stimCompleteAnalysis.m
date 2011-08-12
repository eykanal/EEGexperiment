all = { ...
'17-4-1-preprocessed-stim-coh-20.mat', ...
'17-4-1-preprocessed-stim-coh-6.mat', ...
'17-4-1-preprocessed-stim-coh-8.5.mat', ...
'17-4-2-preprocessed-stim-coh-20.mat', ...
'17-4-2-preprocessed-stim-coh-6.mat', ...
'17-4-2-preprocessed-stim-coh-8.5.mat', ...
'17-4-3-preprocessed-stim-coh-20.mat', ...
'17-4-3-preprocessed-stim-coh-8.5.mat', ...
'17-4-4-preprocessed-stim-coh-20.mat', ...
'17-4-4-preprocessed-stim-coh-8.5.mat', ...
'18-5-1-preprocessed-stim-coh-12.mat', ...
'18-5-1-preprocessed-stim-coh-25.mat', ...
'18-5-1-preprocessed-stim-coh-7.mat', ...
'18-6-1-preprocessed-stim-coh-12.mat', ...
'18-6-1-preprocessed-stim-coh-25.mat', ...
'18-6-1-preprocessed-stim-coh-7.mat', ...
'18-6-2-preprocessed-stim-coh-12.mat', ...
'18-6-2-preprocessed-stim-coh-25.mat', ...
'18-6-2-preprocessed-stim-coh-7.mat', ...
'18-6-3-preprocessed-stim-coh-12.mat', ...
'18-6-3-preprocessed-stim-coh-25.mat', ...
'18-6-3-preprocessed-stim-coh-7.mat', ...
'19-6-1-preprocessed-stim-coh-15.mat', ...
'19-6-1-preprocessed-stim-coh-25.mat', ...
'19-6-1-preprocessed-stim-coh-8.mat', ...
'19-6-2-preprocessed-stim-coh-15.mat', ...
'19-6-2-preprocessed-stim-coh-25.mat', ...
'19-6-2-preprocessed-stim-coh-8.mat', ...
'19-6-3-preprocessed-stim-coh-15.mat', ...
'19-6-3-preprocessed-stim-coh-25.mat', ...
'19-6-3-preprocessed-stim-coh-8.mat', ...
};

high = findSubset(all, '-(20|25)\.mat');
mid  = findSubset(all, '-(8.5|12|15)\.mat');
low  = findSubset(all, '-(6|7|8)\.mat');

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
    cfg             = [];
    cfg.channel     = {'M*'};
    cfg.output      = 'pow';
    cfg.method      = 'mtmconvol';
    cfg.taper       = 'hanning';
    cfg.foi         = 1:1:100;
    cfg.t_ftimwin   = 5./cfg.foi;
    cfg.toi         = -0.1:0.05:0.7;
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
    
    path    = fileparts(which(all{n}));
    tokens  = regexp(all{n},'(\d{2})-(\d)-(\d)-preprocessed-stim-coh-(\d{1,2}\.?\d?)\.mat','tokens');
    tokens  = tokens{1};
    save([path '/' sprintf('%s-%s-%s-timelock-stim-coh-%s.mat',tokens{1},tokens{2},tokens{3},tokens{4})], 'data_timelock');
    save([path '/' sprintf('%s-%s-%s-freq-stim-coh-%s.mat',tokens{1},tokens{2},tokens{3},tokens{4})], 'data_freq');
    save([path '/' sprintf('%s-%s-%s-tf-stim-coh-%s.mat',tokens{1},tokens{2},tokens{3},tokens{4})], 'data_freq_varWind');

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
    title(sprintf('Subject %s, session %s, run %s, %i trials, time series, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-time-mag.pdf',tokens{1},tokens{2},tokens{3},tokens{4})]);
    close(h);
    
    h = figure();
    cfg.layout          = 'neuromag306planar.lay';
    ft_multiplotER(cfg, data_timelock, data_timelockU, data_timelockD);
    title(sprintf('Subject %s, session %s, run %s, %i trials, time series, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-time-grad.pdf',tokens{1},tokens{2},tokens{3},tokens{4})]);
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
    title(sprintf('Subject %s, session %s, run %s, %i trials, frequency, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-freq-1-100-mag.pdf',tokens{1},tokens{2},tokens{3},tokens{4})]);
    close(h);

    h = figure();
    cfg.layout      = 'neuromag306planar.lay';
    ft_multiplotER( cfg, data_freq );
    title(sprintf('Subject %s, session %s, run %s, %i trials, frequency, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-freq-1-100-grad.pdf',tokens{1},tokens{2},tokens{3},tokens{4})]);
    close(h);
    
        % 1-40
    cfg.xlim   = [1 40];
    
    h = figure();
    cfg.layout      = 'neuromag306mag.lay';
    ft_multiplotER( cfg, data_freq );
    title(sprintf('Subject %s, session %s, run %s, %i trials, frequency, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-freq-1-40-mag.pdf',tokens{1},tokens{2},tokens{3},tokens{4})]);
    close(h);

    h = figure();
    cfg.layout      = 'neuromag306planar.lay';
    ft_multiplotER( cfg, data_freq );
    title(sprintf('Subject %s, session %s, run %s, %i trials, frequency, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-freq-1-40-grad.pdf',tokens{1},tokens{2},tokens{3},tokens{4})]);
    close(h);

    % tf
    cfg             = [];
    cfg.showlabels  = 'no';	
    cfg.zlim        = [-7e-26 7e-26];
    
        % 1-100
    cfg.ylim   = [1 100];
    
    h = figure();
    cfg.layout      = 'neuromag306mag.lay';
    ft_multiplotTFR(cfg, data_freq_varWind);
    title(sprintf('Subject %s, session %s, run %s, %i trials, time-frequency, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-tf-1-100-mag.pdf', tokens{1},tokens{2},tokens{3},tokens{4})]);
    close(h);

    h = figure();
    cfg.layout      = 'neuromag306planar.lay';
    ft_multiplotTFR(cfg, data_freq_varWind);
    title(sprintf('Subject %s, session %s, run %s, %i trials, time-frequency, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-tf-1-100-grad.pdf',tokens{1},tokens{2},tokens{3},tokens{4})]);
    close(h);
    
        % 1-40
    cfg.ylim   = [1 40];
    
    h = figure();
    cfg.layout      = 'neuromag306mag.lay';
    ft_multiplotTFR(cfg, data_freq_varWind);
    title(sprintf('Subject %s, session %s, run %s, %i trials, time-frequency, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-tf-1-40-mag.pdf', tokens{1},tokens{2},tokens{3},tokens{4})]);
    close(h);

    h = figure();
    cfg.layout      = 'neuromag306planar.lay';
    ft_multiplotTFR(cfg, data_freq_varWind);
    title(sprintf('Subject %s, session %s, run %s, %i trials, time-frequency, coh (%s) @ stim, processed',tokens{1},tokens{2},tokens{3},num_trials,tokens{4}));
    saveas(h, [path '/figures/' sprintf('%s-%s-%s-freq-stim-coh%s-proc-tf-1-40-grad.pdf',tokens{1},tokens{2},tokens{3},tokens{4})]);
    close(h);

    clear data_timelock data_freq data_freq_varWind;
end

% % remove empty first entry;
% data_grand_high = data_grand_high(2:end);
% data_grand_mid  = data_grand_mid(2:end);
% data_grand_low  = data_grand_low(2:end);

% grand averaging

% time
cfg = [];
cfg.channel     = {'M*'};
cfg.keeptrials  = 'no';
cfg.covariance  = 'yes';
data_grandAvg_timelock      = ft_timelockgrandaverage(cfg, data_grand_high(:).data_timelock, data_grand_mid(:).data_timelock, data_grand_low(:).data_timelock);
data_grandAvg_timelock_high = ft_timelockgrandaverage(cfg, data_grand_high(:).data_timelock);
data_grandAvg_timelock_mid  = ft_timelockgrandaverage(cfg, data_grand_mid(:).data_timelock);
data_grandAvg_timelock_low  = ft_timelockgrandaverage(cfg, data_grand_low(:).data_timelock);
% freq
data_grandAvg_freq          = ft_freqgrandaverage(cfg, data_grand_high(:).data_freq, data_grand_mid(:).data_freq, data_grand_low(:).data_freq);
data_grandAvg_freq_high     = ft_freqgrandaverage(cfg, data_grand_high(:).data_freq);
data_grandAvg_freq_mid      = ft_freqgrandaverage(cfg, data_grand_mid(:).data_freq);
data_grandAvg_freq_low      = ft_freqgrandaverage(cfg, data_grand_low(:).data_freq);
% tf
data_grandAvg_freq_varWind      = ft_freqgrandaverage(cfg, data_grand_high(:).data_freq_varWind, data_grand_mid(:).data_freq_varWind, data_grand_low(:).data_freq_varWind);
data_grandAvg_freq_varWind_high = ft_freqgrandaverage(cfg, data_grand_high(:).data_freq_varWind);
data_grandAvg_freq_varWind_mid  = ft_freqgrandaverage(cfg, data_grand_mid(:).data_freq_varWind);
data_grandAvg_freq_varWind_low  = ft_freqgrandaverage(cfg, data_grand_low(:).data_freq_varWind);

clear data_grand_high data_grand_mid data_grand_low;

% save to disk
grandAvg_path = '/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/';

save([grandAvg_path 'stim-coh-gAvg-timelock.mat'     ], 'data_grandAvg_timelock');
save([grandAvg_path 'stim-coh-gAvg-timelock-high.mat'], 'data_grandAvg_timelock_high');
save([grandAvg_path 'stim-coh-gAvg-timelock-mid.mat' ], 'data_grandAvg_timelock_mid');
save([grandAvg_path 'stim-coh-gAvg-timelock-low.mat' ], 'data_grandAvg_timelock_low');

save([grandAvg_path 'stim-coh-gAvg-freq.mat'     ], 'data_grandAvg_freq');
save([grandAvg_path 'stim-coh-gAvg-freq-high.mat'], 'data_grandAvg_freq_high');
save([grandAvg_path 'stim-coh-gAvg-freq-mid.mat' ], 'data_grandAvg_freq_mid');
save([grandAvg_path 'stim-coh-gAvg-freq-low.mat' ], 'data_grandAvg_freq_low');

save([grandAvg_path 'stim-coh-gAvg-freqVarWind.mat'     ], 'data_grandAvg_freq_varWind');
save([grandAvg_path 'stim-coh-gAvg-freqVarWind-high.mat'], 'data_grandAvg_freq_varWind_high');
save([grandAvg_path 'stim-coh-gAvg-freqVarWind-mid.mat' ], 'data_grandAvg_freq_varWind_mid');
save([grandAvg_path 'stim-coh-gAvg-freqVarWind-low.mat' ], 'data_grandAvg_freq_varWind_low');

% plot figures, save plots to disk

% time
data_timelockU_grandAvg         = data_grandAvg_timelock;
data_timelockD_grandAvg         = data_grandAvg_timelock;
data_timelockU_grandAvg.avg     = data_grandAvg_timelock.avg + sqrt(data_grandAvg_timelock.var);
data_timelockD_grandAvg.avg     = data_grandAvg_timelock.avg - sqrt(data_grandAvg_timelock.var);
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
h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock,      data_timelockU_grandAvg,      data_timelockD_grandAvg     );  title('timelock grand avg all');    saveas(h, [grandAvg_path 'grandAvg_timelock_all-mag.pdf']);     close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_high, data_timelockU_grandAvg_high, data_timelockD_grandAvg_high);  title('timelock grand avg high');   saveas(h, [grandAvg_path 'grandAvg_timelock_high-mag.pdf']);    close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_mid,  data_timelockU_grandAvg_mid,  data_timelockD_grandAvg_mid );  title('timelock grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_timelock_mid-mag.pdf']);     close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_low,  data_timelockU_grandAvg_low,  data_timelockD_grandAvg_low );  title('timelock grand avg low');    saveas(h, [grandAvg_path 'grandAvg_timelock_low-mag.pdf']);     close(h);
cfg.layout = 'neuromag306planar.lay';
h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock,      data_timelockU_grandAvg,      data_timelockD_grandAvg     );  title('timelock grand avg all');    saveas(h, [grandAvg_path 'grandAvg_timelock_all-grad.pdf']);     close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_high, data_timelockU_grandAvg_high, data_timelockD_grandAvg_high);  title('timelock grand avg high');   saveas(h, [grandAvg_path 'grandAvg_timelock_high-grad.pdf']);    close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_mid,  data_timelockU_grandAvg_mid,  data_timelockD_grandAvg_mid );  title('timelock grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_timelock_mid-grad.pdf']);     close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_timelock_low,  data_timelockU_grandAvg_low,  data_timelockD_grandAvg_low );  title('timelock grand avg low');    saveas(h, [grandAvg_path 'grandAvg_timelock_low-grad.pdf']);     close(h);

% freq
cfg             = [];
cfg.showlabels  = 'no';
cfg.ylim        = [0 3e-27];
    % 1-100
cfg.xlim   = [1 100];
cfg.layout = 'neuromag306mag.lay';
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq             );  title('freq grand avg all');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_all-mag.pdf']);     close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_high        );  title('freq grand avg high');   saveas(h, [grandAvg_path 'grandAvg_freq-1-100_high-mag.pdf']);    close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_mid         );  title('freq grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_mid-mag.pdf']);     close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_low         );  title('freq grand avg low');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_low-mag.pdf']);     close(h);
cfg.layout = 'neuromag306planar.lay';
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq             );  title('freq grand avg all');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_all-grad.pdf']);    close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_high        );  title('freq grand avg high');   saveas(h, [grandAvg_path 'grandAvg_freq-1-100_high-grad.pdf']);   close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_mid         );  title('freq grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_mid-grad.pdf']);    close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_low         );  title('freq grand avg low');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_low-grad.pdf']);    close(h);
    % 1-40
cfg.xlim   = [1 40];
cfg.layout = 'neuromag306mag.lay';
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq             );  title('freq grand avg all');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_all-mag.pdf']);     close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_high        );  title('freq grand avg high');   saveas(h, [grandAvg_path 'grandAvg_freq-1-40_high-mag.pdf']);    close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_mid         );  title('freq grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_mid-mag.pdf']);     close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_low         );  title('freq grand avg low');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_low-mag.pdf']);     close(h);
cfg.layout = 'neuromag306planar.lay';
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq             );  title('freq grand avg all');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_all-grad.pdf']);    close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_high        );  title('freq grand avg high');   saveas(h, [grandAvg_path 'grandAvg_freq-1-40_high-grad.pdf']);   close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_mid         );  title('freq grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_mid-grad.pdf']);    close(h);
h = figure();   ft_multiplotER( cfg, data_grandAvg_freq_low         );  title('freq grand avg low');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_low-grad.pdf']);    close(h);

% tf
cfg             = [];
cfg.showlabels  = 'no';	
cfg.zlim        = [-7e-27 7e-27];
    % 1-100
cfg.xlim   = [1 100];
cfg.layout = 'neuromag306mag.lay';
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind     );  title('freq grand avg all');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_varWind_all-mag.pdf']);     close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_high);  title('freq grand avg high');   saveas(h, [grandAvg_path 'grandAvg_freq-1-100_varWind_high-mag.pdf']);    close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_mid );  title('freq grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_varWind_mid-mag.pdf']);     close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_low );  title('freq grand avg low');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_varWind_low-mag.pdf']);     close(h);
cfg.layout = 'neuromag306planar.lay';
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind     );  title('freq grand avg all');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_varWind_all-grad.pdf']);    close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_high);  title('freq grand avg high');   saveas(h, [grandAvg_path 'grandAvg_freq-1-100_varWind_high-grad.pdf']);   close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_mid );  title('freq grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_varWind_mid-grad.pdf']);    close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_low );  title('freq grand avg low');    saveas(h, [grandAvg_path 'grandAvg_freq-1-100_varWind_low-grad.pdf']);    close(h);
    % 1-40
cfg.xlim   = [1 40];
cfg.layout = 'neuromag306mag.lay';
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind     );  title('freq grand avg all');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_varWind_all-mag.pdf']);     close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_high);  title('freq grand avg high');   saveas(h, [grandAvg_path 'grandAvg_freq-1-40_varWind_high-mag.pdf']);    close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_mid );  title('freq grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_varWind_mid-mag.pdf']);     close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_low );  title('freq grand avg low');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_varWind_low-mag.pdf']);     close(h);
cfg.layout = 'neuromag306planar.lay';
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind     );  title('freq grand avg all');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_varWind_all-grad.pdf']);    close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_high);  title('freq grand avg high');   saveas(h, [grandAvg_path 'grandAvg_freq-1-40_varWind_high-grad.pdf']);   close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_mid );  title('freq grand avg mid');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_varWind_mid-grad.pdf']);    close(h);
h = figure();   ft_multiplotTFR(cfg, data_grandAvg_freq_varWind_low );  title('freq grand avg low');    saveas(h, [grandAvg_path 'grandAvg_freq-1-40_varWind_low-grad.pdf']);    close(h);
