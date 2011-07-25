function dots_stats(subj, sess, run, dataset, aveTimes, aveParams)
% Average dots fif files, both at stimulus onset and response time,
% according to coherence and response direction, as well as averaging the
% arrow-only trials.

% for testing, use:
%   subject     4
%   session     5
%   dataset     4_090710_1_trigFix.fif

ft_defaults;

subj_data       = sprintf('subject%i_ses%i_%i', subj, sess, run);
save_path       = sprintf('/Volumes/ShadyBackBowls/meg_data/Dots/%i/matlab-files/', subj);
meg_full_file   = sprintf('/Volumes/ShadyBackBowls/meg_data/Dots/%i/%s', subj, dataset);

%
% Setup configuration structure
%

cfg_base            = struct;                           % ## CFG RESET! ##
cfg_base.dataset    = meg_full_file;
cfg_base.hdr        = ft_read_header(meg_full_file);

%
% Define averaging parameters
%

% variables necessary for defineDotsTrials()
load(subj_data, 'cohVec', 'cueVec', 'ST', 'ER', 'RT', 'Left_RT', 'Right_RT', 'RDir');

if ~exist( 'Left_RT', 'var' )
    Left_RT = [];
end
if ~exist( 'Right_RT', 'var' )
    Right_RT = [];
end

% Define averaging parameters, if not provided at runtime
if isempty('aveTimes')
    aveTimes    = {'stim', 'resp'};
end
if isempty('aveParams')
    aveParams   = {{'coh', unique(cohVec)}, {'respdir','RL'}};  % currently not analyzing sigdet or arrow
end

% average for each parameter, both at stimulus and response
for aveTime = 1:length(aveTimes)
    for aveParam = 1:length(aveParams)
        
        %## TODO: This file does not work, have it load things
        % appropriately and run through appropriately
        
        % Compare conditions using monte-carlo
        cfg = struct;                                   % ## CFG RESET! ##
        cfg.method              = 'montecarlo';         % use monte carlo to determine significance boundaries
        cfg.statistic           = 'indepsamplesT';      % indep T test determines which timepoints are actually significant
        cfg.correctm            = 'cluster';            % MCP correction done using cluster analysis; unsure on this
        cfg.alpha               = 0.025;
        cfg.tail                = 0;
        cfg.numrandomization    = 1000;
        cfg.design              = [ones(size(cond(1).data_timelock.trialinfo)); 2*ones(size(cond(2).data_timelock.trialinfo))]';
        cfg.channel             = {'M*'};
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

        data_timelock_stats = ft_timelockstatistics(cfg, cond(1).data_timelock, cond(2).data_timelock);

        save([save_path subj_data '-timelockstats-' char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1})], 'data_timelock_stats');
        clear cond;

    end
end
