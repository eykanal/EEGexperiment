% load data
subj = [];

if ~exist('data_grandAvg_freq_varWind_high','var') || ~exist('data_grandAvg_freq_varWind_low','var')
    load('resp-coh-gAvg-freqVarWind-high');
    load('resp-coh-gAvg-freqVarWind-low');
end

% account for fact that some sets have different channels selected than
% others... is that necessary?

path    = fileparts(which('17-tf-resp-coh-h.mat'));
grandAvg_path = '/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/';

% tf
stat_diff_time = [0.15 0.50];
stat_diff_freq = [8 12];
labels = {'MEG2011', 'MEG2021', 'MEG2031', 'MEG2041'};
sig = [];

figure();
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

    subplot(2,2,m);
    plot(dat1.time, squeeze(mean(mean(dat1.powspctrm(:, strcmp(dat1.label, label), dat1.freq >= 8 & dat1.freq <= 12, :),1),3)),'-ob', ...
         dat2.time, squeeze(mean(mean(dat2.powspctrm(:, strcmp(dat2.label, label), dat2.freq >= 8 & dat2.freq <= 12, :),1),3)),'-or');
    title(sprintf('8-12 Hz activity over time in channel %s',label));
end
