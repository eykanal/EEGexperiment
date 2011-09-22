% load data
subj = [];

subj.h(1) = load('17-tf-resp-coh-h');
subj.h(2) = load('18-tf-resp-coh-h');
subj.h(3) = load('19-tf-resp-coh-h');

subj.l(1) = load('17-tf-resp-coh-l');
subj.l(2) = load('18-tf-resp-coh-l');
subj.l(3) = load('19-tf-resp-coh-l');

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

path    = fileparts(which([subj.h(1) '.mat']));
grandAvg_path = '/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/';

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
