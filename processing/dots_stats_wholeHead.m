% load data
subj = [];

subj.h(1) = load('17-tf-resp-coh-h');
subj.h(2) = load('18-tf-resp-coh-h');
subj.h(3) = load('19-tf-resp-coh-h');

subj.l(1) = load('17-tf-resp-coh-l');
subj.l(2) = load('18-tf-resp-coh-l');
subj.l(3) = load('19-tf-resp-coh-l');

path    = fileparts(which([subj.h(1) '.mat']));
grandAvg_path = '/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/';

% account for fact that some sets have different channels selected than
% others
a=[];
for n=1:2
    for m=1:3
        if n==1
            a(3*(n-1)+m).chan = vertcat(subj.h(m).data_freq_varWind.label{:});
        else
            a(3*(n-1)+m).chan = vertcat(subj.l(m).data_freq_varWind.label{:});
        end
    end
end

b = intersect(a(1).chan,a(2).chan,'rows');
for n=3:6
    b = intersect(b, a(n).chan,'rows');
end

c = cellstr(b);

cfg = [];
cfg.method              = 'distance';
cfg.channel             = c;
cfg.layout              = 'neuromag306mag.lay';
neighbours              = ft_neighbourselection(cfg, subj.h(1).data_freq_varWind);

% non-parametric analysis (from
% http://fieldtrip.fcdonders.nl/tutorial/cluster_permutation_freq#within_subjects_experiments)
cfg = [];
cfg.channel             = c;
cfg.latency             = [-0.7 -0.2];
cfg.frequency           = [10 10];
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
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

stat = ft_freqstatistics(cfg, subj.h(:).data_freq_varWind, subj.l(:).data_freq_varWind);

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