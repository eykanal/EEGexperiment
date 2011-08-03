function dots_grandAvg()

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

high = { ...
'17-4-1-timelock-resp-coh-20.mat', ...
'17-4-2-timelock-resp-coh-20.mat', ...
'17-4-3-timelock-resp-coh-20.mat', ...
'17-4-4-timelock-resp-coh-20.mat', ...
'18-6-1-timelock-resp-coh-25.mat', ...
'18-6-2-timelock-resp-coh-25.mat', ...
'18-6-3-timelock-resp-coh-25.mat', ...
'19-6-1-timelock-resp-coh-25.mat', ...
'19-6-2-timelock-resp-coh-25.mat', ...
'19-6-3-timelock-resp-coh-25.mat', ...
};

mid = { ...
'17-4-1-timelock-resp-coh-8.5.mat', ...
'17-4-2-timelock-resp-coh-8.5.mat', ...
'17-4-3-timelock-resp-coh-8.5.mat', ...
'17-4-4-timelock-resp-coh-8.5.mat', ...
'18-6-1-timelock-resp-coh-12.mat', ...
'18-6-2-timelock-resp-coh-12.mat', ...
'18-6-3-timelock-resp-coh-12.mat', ...
'19-6-1-timelock-resp-coh-15.mat', ...
'19-6-2-timelock-resp-coh-15.mat', ...
'19-6-3-timelock-resp-coh-15.mat', ...
};

low = { ...
'17-4-1-timelock-resp-coh-6.mat', ...
'17-4-2-timelock-resp-coh-6.mat', ...
'18-6-1-timelock-resp-coh-7.mat', ...
'18-6-2-timelock-resp-coh-7.mat', ...
'18-6-3-timelock-resp-coh-7.mat', ...
'19-6-1-timelock-resp-coh-8.mat', ...
'19-6-2-timelock-resp-coh-8.mat', ...
'19-6-3-timelock-resp-coh-8.mat', ...
};

% averaging and plotting
%gAvg_all = grandAvg(all);
%gAvg_high= grandAvg(high);
gAvg_mid = grandAvg(mid);
%gAvg_low = grandAvg(low);

%myft_plot_time(gAvg_all,  'ylim', [-4.25e-13 4.25e-13], 'average', 0); my_set_title(gcf, 'grandAve all');
%myft_plot_time(gAvg_high, 'ylim', [-4.25e-13 4.25e-13], 'average', 0); my_set_title(gcf, 'grandAve high');
myft_plot_time(gAvg_mid,  'ylim', [-4.25e-13 4.25e-13], 'average', 0); my_set_title(gcf, 'grandAve mid');
%myft_plot_time(gAvg_low,  'ylim', [-4.25e-13 4.25e-13], 'average', 0); my_set_title(gcf, 'grandAve low');

channels = {'MEG2012', 'MEG2013', 'MEG2043', 'MEG2042', 'MEG2022', 'MEG2023', 'MEG2033', 'MEG2032'};
myft_plot_time(gAvg_mid, 'chans', channels, 'average', 0);

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
