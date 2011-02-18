% Average dots fif files, both at stimulus onset and response time,
% according to coherence and response direction, as well as averaging the
% arrow-only trials.

function dots_ft_avg(subj, sess, dataset)
% for testing, use:
%   subject     4
%   session     8
%   dataset     4_090710_4_trigFix.fif
%   

ft_defaults;

%
% Setup configuration structure
%

cfg_base            = struct;                           % ## CFG RESET! ##
cfg_base.dataset    = dataset;
cfg_base.hdr        = ft_read_header(cfg_base.dataset);


%
% Define averaging parameters
%

subj_data = sprintf('subject%i_ses%i', subj, sess);
save_path = sprintf('/Volumes/Shady\\ Back\\ Bowls/meg_data/Dots/subj%i/matlab-data/', subj);


% variables necessary for defineDotsTrials()
load(subj_data, 'cohVec', 'cueVec', 'ST', 'ER', 'RT', 'Left_RT', 'Right_RT', 'RDir');

if ~exist( 'Left_RT', 'var' )
    Left_RT = [];
end
if ~exist( 'Right_RT', 'var' )
    Right_RT = [];
end

aveTimes    = {'stim', 'resp'};
aveParams   = {'coh', 'respdir', 'arrow'};  % currently not analyzing sigdet

% average for each parameter, both at stimulus and response
for aveTime = 1:length(aveTimes)
    for aveParam = 1:length(aveParams)

        % Load data        
        load([save_path subj_data '-preprocessed-'  char(aveTimes(aveTime)) '-' char(aveParams(aveParam))]);

        %
        % Averaging & statistics
        %

        cfg.channel         = ft_channelselection( 'M*1', cfg.hdr.label );
        cfg.keeptrials      = 'yes';
        cfg.covariance      = 'no';
        data_timelock       = ft_timelockanalysis(cfg, data_preprocessed);

        save([subj_data '-timelock-' char(aveTimes(aveTime)) '-' char(aveParams(aveParam))], 'data_timelock');

        % define all settings
        cfg = struct;                                   % ## CFG RESET! ##
        cfg.method              = 'montecarlo';         % use monte carlo to determine significance boundaries
        cfg.statistic           = 'indepsamplesT';      % indep T test determines which timepoints are actually significant
        cfg.correctm            = 'cluster';            % MCP correction done using cluster analysis; unsure on this
        cfg.alpha               = 0.025;
        cfg.tail                = 0;
        cfg.numrandomization    = 1000;
        cfg.design              = data_timelock.trialinfo;
        cfg.channel             = {'MEG*1'};
        cfg.latency             = 'all';
        cfg.clustertail         = 0;                    %  Determine significance within clusters using two-sided t-test
        cfg.ivar                = 1;

        cfg.minnbchan           = 2;                    %  Don't allow clusters to be connected to each other
                                                        % unless at least two neighbors are also in the
                                                        % cluster
        cfg.clusteralpha        = 0.05;                 %  Alpha level used to determine whether a given
                                                        % sample belongs to a cluster
        cfg.clusterstatistic    = 'maxsum';             %  For each permutation, sum all test statistics
                                                        % within each cluster. These will later be used to
                                                        % generate a distribution, against which will will
                                                        % compare the original test statistic

        data_timelock_stats = ft_timelockstatistics(cfg, data_timelock);
        
        save([save_path subj_data '-timelockstats-' char(aveTimes(aveTime)) '-' char(aveParams(aveParam))], 'data_timelock_stats');
        clear data_preprocessed;
    end
end