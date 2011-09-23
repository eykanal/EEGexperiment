% load data
if ~exist('h','var') || ~exist('l','var')
    h(1) = load('17-tf-resp-coh-h');
    h(2) = load('18-tf-resp-coh-h');
    h(3) = load('19-tf-resp-coh-h');

    l(1) = load('17-tf-resp-coh-l');
    l(2) = load('18-tf-resp-coh-l');
    l(3) = load('19-tf-resp-coh-l');
end

path    = fileparts(which('17-tf-resp-coh-h.mat'));
grandAvg_path = '/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/';

% account for fact that some sets have different channels selected than
% others
a=[];
for n=1:2
    for m=1:3
        if n==1
            a(3*(n-1)+m).chan = vertcat(h(m).data_freq_varWind.label{:});
        else
            a(3*(n-1)+m).chan = vertcat(l(m).data_freq_varWind.label{:});
        end
    end
end

b = intersect(a(1).chan,a(2).chan,'rows');
for n=3:6
    b = intersect(b, a(n).chan,'rows');
end

c = cellstr(b);

for n=1:3
    h(n).data_freq_varWind = ft_selectdata(h(n).data_freq_varWind, 'channel', c);
    l(n).data_freq_varWind = ft_selectdata(l(n).data_freq_varWind, 'channel', c);
end

% non-parametric analysis (from
% http://fieldtrip.fcdonders.nl/tutorial/cluster_permutation_freq#within_subjects_experiments)
cfg = [];
cfg.method              = 'distance';
cfg.layout              = 'neuromag306mag.lay';
neighbours              = ft_neighbourselection(cfg, h(1).data_freq_varWind);

cfg = [];
%cfg.latency             = [-0.7 0.1];
cfg.frequency           = [8 12];
cfg.avgoverfreq         = 'yes';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';
cfg.minbchan            = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 2000;
cfg.neighbours          = neighbours;

Nsub = 3;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

stat = ft_freqstatistics(cfg, h(:).data_freq_varWind, l(:).data_freq_varWind);

% difference freq_varWind data
freq_varWind_hi = ft_freqgrandaverage([], h(:).data_freq_varWind);
freq_varWind_lo = ft_freqgrandaverage([], l(:).data_freq_varWind);

freq_varWind_diff = freq_varWind_hi;
freq_varWind_diff.powspctrm = freq_varWind_hi.powspctrm - freq_varWind_lo.powspctrm;

freq_varWind_diff = ft_selectdata(freq_varWind_diff, 'channel', c);

% make a plot
cfg = [];
cfg.channel             = c;
cfg.style               = 'blank';
cfg.layout              = 'neuromag306mag.lay';
cfg.highlight           = 'on';
cfg.highlightchannel    = find(sum(stat.mask,3)>0);
cfg.comment             = 'no';

figure();
ft_topoplotTFR(cfg, freq_varWind_diff);
title('Nonparametric: significant with cluster multiple comparison correction')    

cfg                     = [];
cfg.channel             = c;
cfg.alpha               = 0.05;
cfg.zparam              = 'stat';
cfg.zlim                = [-10 10];
cfg.layout              = 'neuromag306mag.lay';

ft_clusterplot(cfg, stat)
