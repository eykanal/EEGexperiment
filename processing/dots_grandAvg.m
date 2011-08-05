function [gAvg_all gAvg_high gAvg_mid gAvg_low] = dots_grandAvg()

% define filenames
all = { ...
'17-4-1-timelock-resp-coh-20.mat', ...
'17-4-1-timelock-resp-coh-6.mat', ...
'17-4-1-timelock-resp-coh-8.5.mat', ...
'17-4-2-timelock-resp-coh-20.mat', ...
'17-4-2-timelock-resp-coh-6.mat', ...
'17-4-2-timelock-resp-coh-8.5.mat', ...
'17-4-3-timelock-resp-coh-20.mat', ...
'17-4-3-timelock-resp-coh-8.5.mat', ...
'17-4-4-timelock-resp-coh-20.mat', ...
'17-4-4-timelock-resp-coh-8.5.mat', ...
'18-5-1-timelock-resp-coh-12.mat', ...
'18-5-1-timelock-resp-coh-25.mat', ...
'18-5-1-timelock-resp-coh-7.mat', ...
'18-6-1-timelock-resp-coh-12.mat', ...
'18-6-1-timelock-resp-coh-25.mat', ...
'18-6-1-timelock-resp-coh-7.mat', ...
'18-6-2-timelock-resp-coh-12.mat', ...
'18-6-2-timelock-resp-coh-25.mat', ...
'18-6-2-timelock-resp-coh-7.mat', ...
'18-6-3-timelock-resp-coh-12.mat', ...
'18-6-3-timelock-resp-coh-25.mat', ...
'18-6-3-timelock-resp-coh-7.mat', ...
'19-6-1-timelock-resp-coh-15.mat', ...
'19-6-1-timelock-resp-coh-25.mat', ...
'19-6-1-timelock-resp-coh-8.mat', ...
'19-6-2-timelock-resp-coh-15.mat', ...
'19-6-2-timelock-resp-coh-25.mat', ...
'19-6-2-timelock-resp-coh-8.mat', ...
'19-6-3-timelock-resp-coh-15.mat', ...
'19-6-3-timelock-resp-coh-25.mat', ...
'19-6-3-timelock-resp-coh-8.mat', ...
};

high = findSubset(all, '-(20|25)\.mat');
mid  = findSubset(all, '-(8.5|12|15)\.mat');
low  = findSubset(all, '-(6|7|8)\.mat');

% % averaging and plotting
% gAvg_all = grandAvg(all);
% gAvg_high= grandAvg(high);
% gAvg_mid = grandAvg(mid);
% gAvg_low = grandAvg(low);

% disp('Saving...');
% save('/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/gAvg_all.mat' , 'gAvg_all');
% save('/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/gAvg_high.mat', 'gAvg_high');
% save('/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/gAvg_mid.mat' , 'gAvg_mid');
% save('/Volumes/ShadyBackBowls/meg_data/Dots/grandAvg/gAvg_low.mat' , 'gAvg_low');

load gAvg_all;
load gAvg_high;
load gAvg_mid;
load gAvg_low;

myft_plot_time(gAvg_all,  'ylim', [-1.25e-13 1.25e-13], 'average', 0); my_set_title(gcf, 'grandAve all', [],'askextra',0);
myft_plot_time(gAvg_high, 'ylim', [-1.25e-13 1.25e-13], 'average', 0); my_set_title(gcf, 'grandAve high',[],'askextra',0);
myft_plot_time(gAvg_mid,  'ylim', [-1.25e-13 1.25e-13], 'average', 0); my_set_title(gcf, 'grandAve mid', [],'askextra',0);
myft_plot_time(gAvg_low,  'ylim', [-1.25e-13 1.25e-13], 'average', 0); my_set_title(gcf, 'grandAve low', [],'askextra',0);

channels = {'MEG2012', 'MEG2013', 'MEG2043', 'MEG2042', 'MEG2022', 'MEG2023', 'MEG2033', 'MEG2032','MEG2011', 'MEG2021', 'MEG2031', 'MEG2041'};
high_titles = cellfun(@strcat,repmat({'high-'}, size(channels)),channels,'UniformOutput',false);
myft_plot_time(gAvg_high, 'chans', channels, 'average', 0, 'titles', high_titles);
mid_titles  = cellfun(@strcat,repmat({'mid-'}, size(channels)),channels,'UniformOutput',false);
myft_plot_time(gAvg_mid,  'chans', channels, 'average', 0, 'titles', mid_titles);

figHandles = findobj('Type','figure');
for n=1:length(figHandles)
    figure(figHandles(n));
    orient(figHandles(n),'landscape');
    saveas(figHandles(n),sprintf('~/Desktop/figures/%s.pdf',get(get(gca,'Title'),'string')));
end

keyboard;


%############################################
%##            SUBFUNCTIONS                ##
%############################################

% average all datafiles together;
function gAvg = grandAvg(datafiles)
% Load up all averaged datafiles
avgs = [];
for n=1:length(datafiles)
    avgs(n).avg = load(datafiles{n});
    avgs(n).avg = avgs(n).avg.data_timelock;
end

% Average them into one large grand-averaged file
cfg = [];
gAvg = ft_timelockgrandaverage(cfg, avgs(:).avg);


% perform differencing
function diffs = differenceAvgs(avg1, avg2)
diffs = avg1;
diffs.avg = avg1.avg - avg2.avg;

% extract relevant datasets
function subset = findSubset(all, pattern)
tmp     = (regexp(all, pattern));
subset  = all(~cellfun(@isempty,tmp));