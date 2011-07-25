function dots_grandAve()
% Run grand average on all timelock data and print figures, calculate
% difference files and print more figures

cd /Volumes/ShadyBackBowls/meg_data/Dots/18/matlab-files/

%
% Averaging
%

% load condition
disp('loading coh');
coh = load('./subject18_ses5_1-timelock-resp-all-1.mat');
coh = coh.data_timelock;

%
% Plotting
%

% time plot
disp('time plots');
cfg             = [];
cfg.showlabels  = 'no';
cfg.layout      = 'neuromag306all.lay';
figure();
ft_multiplotER(cfg, coh);
title('Subject 18, average')

% frequency plot
disp('freqplots');
cfg             = [];
cfg.method      = 'mtmfft';
cfg.output      = 'pow';
cfg.calcdof     = 'yes';
cfg.taper       = 'hanning';
cfg.foilim      = [1 40];
cohFreq        = ft_freqanalysis( cfg, coh );

cfg             = [];
cfg.layout      = 'neuromag306all.lay';
cfg.showlabels  = 'no';
%cfg.ylim        = [0 1e-28];
figure();
ft_multiplotER( cfg, cohFreq );
title('Subject 18, average frequency')

% time-frequency plot
disp('tf plots');
cfg             = [];
cfg.output      = 'pow';
cfg.method      = 'mtmconvol';
cfg.taper       = 'hanning';
cfg.foi         = 1:30;
cfg.t_ftimwin   = 2./cfg.foi;
cfg.toi         = -1:0.05:0.5;
cohTfr         = ft_freqanalysis(cfg, coh);

cfg             = [];
cfg.showlabels  = 'no';	
cfg.layout      = 'neuromag306all.lay';
cfg.zlim        = [-4e-26 4e-26];
figure();
ft_multiplotTFR(cfg, cohTfr);
title('Subject 18, average TF')

% %
% % Differencing
% %
% 
% % subtract
% disp('subtracting');
% cohDiff = coh8;
% cohDiff.avg = coh20.avg - coh8.avg;
% save('17-resp-coh20minus8-time-grandaverageDifference.mat', 'cohDiff');
% 
% cohDiffFreq = coh20freq;
% cohDiffFreq.powspctrm = coh20freq.powspctrm - coh8freq.powspctrm;
% save('17-resp-coh20minus8-freq-grandaverageDifference.mat', 'cohDiffFreq');
% 
% cohDiffTfr = coh20tfr;
% cohDiffTfr.powspctrm = coh20tfr.powspctrm - coh8tfr.powspctrm;
% save('17-resp-coh20minus8-tfr-grandaverageDifference.mat', 'cohDiffTfr');

% disp('diff plots')
% % time
% cfg             = [];
% cfg.showlabels  = 'no';
% cfg.layout      = 'neuromag306all.lay';
% figure();
% ft_multiplotER(cfg, cohDiff);
% title('Subject 17, grand average, Difference (20-8)')
% 
% % tfr
% cfg             = [];
% cfg.showlabels  = 'no';	
% cfg.layout      = 'neuromag306all.lay';
% cfg.zlim        = [-5e-27 5e-27];
% figure();
% ft_multiplotTFR(cfg, cohDiffTfr);
% title('Subject 17, grand average, difference, TF')


% individual plots
disp('individual plots')
channels = {'MEG2012', 'MEG2013', 'MEG2043', 'MEG2042', 'MEG2022', 'MEG2023', 'MEG2033', 'MEG2032'};

figure();
for n=1:2
    for m=1:4
        chanNum = m+(n-1)*4;
        
        cfg         = [];
        cfg.channel = channels(chanNum);
        cfg.xlim    = [-0.7 0];
        cfg.baseline = [-1500 1000];
        cfg.baselinetype = 'relative';
        
        subplot(4,2,chanNum);
        ft_singleplotER(cfg, coh);
        line([-0.7 0], [0 0], 'Color', [0 0 0]);
        title(char(cell2mat(channels(chanNum))));
    end
end
    
figure();
for n=1:2
    for m=1:4
        chanNum = m+(n-1)*4;

        cfg         = [];
        cfg.channel = channels(chanNum);
        %cfg.ylim    = [0 1e-28];
        
        subplot(4,2,chanNum);
        ft_singleplotER(cfg, cohFreq);
        title(char(cell2mat(channels(chanNum))));
    end
end

figure();
for n=1:2
    for m=1:4
        chanNum = m+(n-1)*4;

        cfg         = [];
        cfg.channel = channels(chanNum);
        cfg.zlim    = [-4e-26 4e-26];
        
        subplot(4,2,chanNum);
        ft_singleplotTFR(cfg, cohTfr);
        title(char(cell2mat(channels(chanNum))));
    end
end
    