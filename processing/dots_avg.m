function dots_avg(subj, sess, run, dataset, aveTimes, aveParams)
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
        
        cond = struct([struct struct]);                 % dummy variable to hold the timelock data
                                                        % until timelockstatistics can be run
        for aveParamValue = 1:length(aveParams{aveParam}{2})
        
            cfg = cfg_base;                             % ## CFG RESET! ##
            
            % Load data        
            load([save_path subj_data '-preprocessed-'  char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1}) '-' num2str(aveParams{aveParam}{2}(aveParamValue)) '.mat']);

            %
            % Averaging & statistics
            %

            cfg.channel     = {'M*'};
            cfg.keeptrials  = 'yes';
            cfg.covariance  = 'yes';
            data_timelock   = ft_timelockanalysis(cfg, data_preprocessed);
    
            save([subj_data '-timelock-'  char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1}) '-' num2str(aveParams{aveParam}{2}(aveParamValue)) '.mat'], 'data_timelock');
            %## TODO - Echo saved file name
            
            % save data for next run
            cond(aveParamValue).data_timelock = data_timelock;
            clear data_timelock;
        end
        
        %
        % Make difference file, run averaging
        %
        
        % already have the second condition, so use it
        data_timelock           = averaging(data_preprocessed);

        cond                    = [struct struct];
        cond(2).data_timelock   = data_timelock;
            
        % process the first condition
        load([save_path subj_data '-preprocessed-'  char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1}) '-' num2str(aveParams{aveParam}{2}(1)) '.mat']);
        data_timelock           = averaging(data_preprocessed);
        cond(1).data_timelock   = data_timelock;
        
        % difference the conditions, plot figures
        cond(3) = cond(1);
        cond(3).data_timelock.avg = cond(1).data_timelock.avg - cond(2).data_timelock.avg;
        
        plot_time_freq(cond(3).data_timelock);
        
%         %
%         % Compare conditions using monte-carlo
%         %
%         cfg = struct;                                   % ## CFG RESET! ##
%         cfg.method              = 'montecarlo';         % use monte carlo to determine significance boundaries
%         cfg.statistic           = 'indepsamplesT';      % indep T test determines which timepoints are actually significant
%         cfg.correctm            = 'cluster';            % MCP correction done using cluster analysis; unsure on this
%         cfg.alpha               = 0.025;
%         cfg.tail                = 0;
%         cfg.numrandomization    = 1000;
%         cfg.design              = [ones(size(cond(1).data_timelock.trialinfo)); 2*ones(size(cond(2).data_timelock.trialinfo))]';
%         cfg.channel             = {'M*'};
%         cfg.latency             = 'all';
%         cfg.clustertail         = 0;                    %  Determine significance within clusters using two-sided t-test
%         cfg.ivar                = 1;
% 
%         cfg.minnbchan           = 2;                    %  Don't allow clusters to be connected to each other
%                                                         % unless at least two neighbors are also in the
%                                                         % cluster
%         cfg.clusteralpha        = 0.05;                 %  Alpha level used to determine whether a given
%                                                         % sample belongs to a cluster
%         cfg.clusterstatistic    = 'maxsum';             %  For each permutation, sum all test statistics
%                                                         % within each cluster. These will later be used to
%                                                         % generate a distribution, against which will will
%                                                         % compare the original test statistic
% 
%         data_timelock_stats = ft_timelockstatistics(cfg, cond(1).data_timelock, cond(2).data_timelock);
% 
%         save([save_path subj_data '-timelockstats-' char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1})], 'data_timelock_stats');
%         clear cond;


    end
end
