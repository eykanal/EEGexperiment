function dots_ft_plot(subj, sess, run)
% function dots_ft_plot(subj, sess, run)
% 
% Plot output of monte carlo simulation data from ft_dots_avg
%

% for testing, use:
%   subject     4
%   session     5
%   dataset     4_090710_1_trigFix.fif

ft_defaults;

%
% Setup configuration structure
%

cfg_base            = struct;                           % ## CFG RESET! ##


%
% Define averaging parameters
%

subj_data = sprintf('subject%i_ses%i_%i', subj, sess, run);
save_path = sprintf('/Volumes/ShadyBackBowls/meg_data/Dots/%i/matlab-files/', subj);

aveTimes    = {'stim', 'resp'};
aveParams   = {'coh', 'respdir'};  % currently not analyzing arrows, sigdet

%
% Plot
%

for aveTime = 1:length(aveTimes)
    for aveParam = 1:length(aveParams)
        
        % after both are processed, can subtract differences and save plots
        cond1 = load([save_path subj_data '-timelock-' char(aveTimes(aveTime)) '-' char(aveParams(aveParam)) '-1.mat'], 'data_timelock');
        cond2 = load([save_path subj_data '-timelock-' char(aveTimes(aveTime)) '-' char(aveParams(aveParam)) '-2.mat'], 'data_timelock');

        load([save_path subj_data '-timelockstats-' char(aveTimes(aveTime)) '-' char(aveParams(aveParam))], 'data_timelock_stats');

        % get difference between average of conditions
        data_timelock_diff = cond1.data_timelock;
        data_timelock_diff.avg = cond1.data_timelock.avg - cond2.data_timelock.avg;
        
        % find significant clusters
        pos_clusters = find( cell2mat( {data_timelock_stats.posclusters.prob} ) < data_timelock_stats.cfg.alpha );
        neg_clusters = find( cell2mat( {data_timelock_stats.negclusters.prob} ) < data_timelock_stats.cfg.alpha );
        % make boolean matrix of which (ch,time)-pairs are part of
        % significant cluster (from tutorial)
        pos = ismember( data_timelock_stats.posclusterslabelmat, pos_clusters );
        neg = ismember( data_timelock_stats.negclusterslabelmat, neg_clusters );
        
        % can use following to see only first j most significant clusters
        %pos = data_timelock_stats.posclusterslabelmat == j;
        %neg = data_timelock_stats.negclusterslabelmat == j;
        
        % Plotting code comes straight from FT wiki
        %   http://fieldtrip.fcdonders.nl/tutorial/cluster_permutation_timelock
        
        timestep        = 0.05;                         % timestep between time windows for each subplot (in seconds)
        sampling_rate   = 1000;                         % Data has a temporal resolution of X Hz
        sample_count    = length(data_timelock_stats.time);  % number of temporal samples in the statistics object
                                
        j = 0:timestep:0.6;                             % Temporal endpoints (in seconds) of the ERP average computed in each subplot
        m = 1:timestep*sampling_rate:sample_count;      % temporal endpoints in MEEG samples

        figure();
        for k = 1:length(m)-1;
            subplot(3,4,k);
            cfg         = cfg_base;                     % ## CFG RESET! ##
            cfg.xlim    = [j(k) j(k+1)];                % time interval of the subplot
            cfg.zlim    = [-2.5e-13 2.5e-13];
            % If a channel reaches this significance, then
            % the element of pos_int with an index equal to that channel
            % number will be set to 1 (otherwise 0).

            % Next, check which channels are significant over the
            % entire time interval of interest.
            pos_int     = all(pos(:, m(k):m(k+1)), 2);
            neg_int     = all(neg(:, m(k):m(k+1)), 2);

            cfg.highlight   = 'on';
            % Get the index of each significant channel
            cfg.highlightchannel = find(pos_int | neg_int);
            cfg.comment     = 'xlim';   
            cfg.commentpos  = 'title'; 
            cfg.channel     = 'M*1';
            cfg.layout      = 'neuromag306mag.lay';
            ft_topoplotER(cfg, data_timelock_diff);   
        end
    end
end
