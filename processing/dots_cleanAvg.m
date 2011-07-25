function dots_cleanAvg(subj, sess, run, dataset, aveTimes, aveParams, analysisTimes)
%
% function dots_ft_cleaning(subj, sess, run, dataset)
%
% Perform cleaning (bandpass filter, artifact detection & removal) and
% preprocessing of a raw dataset. Should be used prior to dots_ft_avg.
%
%   subj    = subject number
%   sess    = session number
%   run     = within-session run number
%   dataset = string containing folder and filename (e.g.
%             "1_820111/1_820111.fif")
%
% for testing, use:
%   subject     4
%   session     5
%   dataset     4_090710
%
% Eliezer Kanal, 5/2011

dbstop if error
ft_defaults;

% re-add the directories to the path to ensure that all subjects are
% present
addpath(genpath('/Users/eliezerk/Documents/MATLAB/EEGExperiment/data/'));
savepath;

subj_data       = sprintf('subject%i_ses%i_%i', subj, sess, run);
save_path       = sprintf('/Volumes/ShadyBackBowls/meg_data/Dots/%i/matlab-files/', subj);
meg_full_file   = sprintf('/Volumes/ShadyBackBowls/meg_data/Dots/%i/%s', subj, dataset);

%
% Setup configuration structure
%

if ~exist(meg_full_file, 'file')
    error('fif file not found. Please verify %s exists.', meg_full_file); %#ok<SPERR>
end

if ~exist([subj_data '.mat'], 'file')
    error('Subject datafile (%s) not found.', [subj_data '.mat']);
end

if ~exist(save_path, 'dir')
    mkdir(save_path);
end

% Run trigger_fix if necessary
if ~strcmp( meg_full_file(end-10:end-4), 'trigFix' )
    if exist([meg_full_file(1:end-4) '_trigFix.fif'], 'file')
        meg_full_file = [meg_full_file(1:end-4) '_trigFix.fif'];
        disp('Found identical file with trigger_fix applied, using that file...');
    else
        disp('trigger_fix not yet run, executing now...');
        meg_full_file = trigger_fix( meg_full_file );
    end
end

cfg_base            = struct;
cfg_base.dataset    = meg_full_file;
cfg_base.hdr        = ft_read_header(meg_full_file);

% Find triggers on STI101 channel
cfg = cfg_base;
hdr   = fiff_setup_read_raw( cfg.dataset );
picks = fiff_pick_types( hdr.info, false, false, false, {'STI101'} );
trig  = fiff_read_raw_segment( hdr, hdr.first_samp, hdr.last_samp, picks );

% Fix so each pulse is exactly 1 ms long
trig(trig > 0 & [0 diff(trig)] <= 0) = 0;

data.values     = trig(trig>0);
data.times.raw  = find(trig>0);

% Time of trigger pulse in ms, including initial skip
data.times.stim = data.times.raw(data.values == 1);
data.times.resp = data.times.raw(data.values == 2);

% variables necessary for defineDotsTrials()
load([subj_data '.mat'], 'cohVec', 'cueVec', 'ST', 'ER', 'RT', 'Left_RT', 'Right_RT', 'RDir');

if ~exist( 'Left_RT', 'var' )
    Left_RT = [];
end
if ~exist( 'Right_RT', 'var' )
    Right_RT = [];
end

% Define input parameters if not provided at runtime. Down here instead of
% at top due to use of `cohVec`. Most common is below, other options are
% commented out.
SetDefaultValue(5, 'aveTimes',      {'resp'}); % , 'stim'});
SetDefaultValue(6, 'aveParams',     {{'coh', unique(cohVec)}}); % , {'respdir','RL'}});
SetDefaultValue(7, 'analysisTimes', [1000 500]);

for n = 1:length(aveParams)
    if iscellstr(aveParams{n}(2)) && strcmp(aveParams{n}(2), 'all')
        switch char(aveParams{n}(1))
            case 'coh'
                aveParams{n}(2) = {unique(cohVec)};
            case 'respdir'
                aveParams{n}(2) = {unique(RDir)};
        end
    end
end

% preprocess for each averaging parameter, both at stimulus and response
for aveParam = 1:length(aveParams)
    for aveTime = 1:length(aveTimes)
        for aveParamValue = 1:length(aveParams{aveParam}{2})
            
            % define base plot name for future use
            curr_param          = char(aveParams{aveParam}{1});
            curr_paramValue     = num2str(aveParams{aveParam}{2}(aveParamValue));
            curr_time           = char(aveTimes(aveTime));
            
            cfg = cfg_base;
            cfg.trialfun        = 'defineDotsTrials';
            cfg.dots.data       = data;
            cfg.dots.coh        = cohVec;
            cfg.dots.cue        = cueVec;
            cfg.dots.ER         = ER;
            cfg.dots.RT         = RT;
            cfg.dots.dir_resp   = RDir;
            cfg.dots.dir_correct = ST;
            cfg.dots.preTrig    = analysisTimes(1);
            cfg.dots.postTrig   = analysisTimes(2);
            cfg.dots.left_RT    = Left_RT;
            cfg.dots.right_RT   = Right_RT;

            cfg.dots.paramValue = aveParams{aveParam}{2}(aveParamValue);

            cfg.dots.aveTime    = char(aveTimes(aveTime));
            cfg.dots.aveParam   = char(aveParams{aveParam}{1});

            cfg = ft_definetrial(cfg);

            %
            % Define preprocessing routines
            %

            cfg.lpfilter = 'yes';
            cfg.hpfilter = 'yes';
            cfg.lpfreq = 40;
            cfg.hpfreq = 1;
            cfg.demean          = 'no';
            cfg.baselinewindow  = [-1.5 -1];
            data_preprocessed   = ft_preprocessing(cfg);

            % scale down gradiometers
            grad_scale = 1;
            if grad_scale == 1
                grads               = regexp(data_preprocessed.label, 'MEG\d{3}[23]');  % find them
                grads               = ~(cellfun(@isempty, grads));  % convert from cell to bool

                for n = 1:length(data_preprocessed.trial)
                    % ## Eventually, determine variance of mags, grads, 
                    % ## scale grads in proportion to difference between
                    % ## variances. For now, just scale down to 5% of
                    % ## original.

                    data_preprocessed.trial{n}(grads, :) = data_preprocessed.trial{n}(grads, :)*0.05;
                end
            end
            
            % define some useful strings
            base_plot_name_ssr  = sprintf( 'Subject %i, session %i, run %i, %i trials', subj, sess, run, length( data_preprocessed.trial ) );
            base_plot_name_param = sprintf('%s (%s) @ %s', curr_param, curr_paramValue, curr_time );
            base_file_name      = sprintf( '%i-%i-%i-%s-%s%s', subj, sess, run, curr_time, curr_param, curr_paramValue );

            % display plots
            view_freq_plots = input( 'Do you want to see time/frequency plots? (Y/n) ', 's' );
            if ~strcmp( view_freq_plots, 'n' )
                % time plot
                myft_plot_time(data_preprocessed);
                title       = sprintf( '%s, %s, %s', base_plot_name_ssr, 'time series', base_plot_name_param );
                my_set_title(gcf, title, 'no processing');
                save_file    = sprintf( '%s-%s.pdf', base_file_name, 'noProc-time' );
                my_save_figure( gcf, save_file, [save_path 'figures/'] );

                % freq plot
                myft_plot_freq(data_preprocessed);
                title       = sprintf( '%s, %s, %s', base_plot_name_ssr, 'frequency plot', base_plot_name_param );
                my_set_title(gcf, title, 'no processing');
                save_file    = sprintf( '%s-%s.pdf', base_file_name, 'noProc-freq' );
                my_save_figure( gcf, save_file, [save_path 'figures/'] );

                % time-freq plot
                myft_plot_tf(data_preprocessed, analysisTimes);
                title       = sprintf( '%s, %s, %s', base_plot_name_ssr, 'time-frequency', base_plot_name_param );
                my_set_title(gcf, title, 'no processing');
                save_file    = sprintf( '%s-%s.pdf', base_file_name, 'noProc-tf' );
                my_save_figure( gcf, save_file, [save_path 'figures/'] );
            end

            % The while loop allows denoising, viewing of the TFR, and then
            % subsequent re-denoising, if necessary
            tfr_denoise_cont = 'y';
            while strcmp( tfr_denoise_cont, 'y' )
                
                % component analysis
                component_analysis = input( 'Do you want to run ft_componentanalysis? (Y/n) ', 's' );
                if ~strcmp( component_analysis, 'n' )
                    % find magnetometer, gradiometer components
                    channels = {'MEGGRAD', 'MEGMAG'};
                    layouts  = {'neuromag306planar.lay', 'neuromag306mag.lay'};

                    for chan = 1:length(channels)
                        run_again = 1;
                        while run_again
                            cfg                 = [];
                            cfg.method          = 'fastica';
                            cfg.channel         = channels(chan);
                            cfg.fastica.numOfIC = 40;
                            cfg.fastica.lastEig = 50;
                            cfg.fastica.verbose = 'off';
                            data_components = ft_componentanalysis(cfg, data_preprocessed);

                            cfg                 = [];
                            cfg.layout          = char(layouts(chan));
                            cfg.viewmode        = 'component';
                            ft_databrowser(cfg, data_components);
                            reject              = input( 'Enter components to reject (leave blank for none): ');

                            if ~isempty( reject )
                                cfg             = [];
                                cfg.component   = reject;
                                data_preprocessed = ft_rejectcomponent(cfg, data_components, data_preprocessed);
                            else
                                % cancel out of "run_again" loop
                                run_again = 0;
                            end
                        end
                    end
                end

                % Examine data for noise
                cfg = cfg_base;
                cfg.channel         = 'M*';  % remove STI channels
                cfg.megscale        = 1;
                cfg.eogscale        = 5e-8;
                cfg.alim            = 2e-12;

                cfg.method          = 'trial';
                data_preprocessed   = ft_rejectvisual(cfg, data_preprocessed);
                cfg.method          = 'channel';
                data_preprocessed   = ft_rejectvisual(cfg, data_preprocessed);
                cfg.method          = 'summary';
                cfg.metric          = 'maxabs';
                cfg.layout          = 'neuromag306all.lay';
                data_preprocessed   = ft_rejectvisual(cfg, data_preprocessed);

                save_preprocessed = input('Save preprocessed data? (Y/n) ', 's');
                if ~strcmp( save_preprocessed, 'n')
                    % save preprocessed file
                    disp('Saving preprocessed file...');
                    savefile = [num2str(subj) '-' num2str(sess) '-' num2str(run) '-preprocessed-'  char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1}) '-' num2str(aveParams{aveParam}{2}(aveParamValue)) '.mat'];
                    save([save_path savefile], 'data_preprocessed');
                    disp(['File saved: ' savefile]);
                end

                % re-define some useful strings (num trials changed)
                base_plot_name_ssr  = sprintf( 'Subject %i, session %i, run %i, %i trials', subj, sess, run, length( data_preprocessed.trial ) );
                base_plot_name_param = sprintf('%s (%s) @ %s', curr_param, curr_paramValue, curr_time );
                base_file_name      = sprintf( '%i-%i-%i-%s-%s%s', subj, sess, run, curr_time, curr_param, curr_paramValue );

                view_freq_plots = input( 'Do you want to see time/frequency plots? (Y/n) ', 's' );
                if ~strcmp( view_freq_plots, 'n' )
                    % time plot
                    myft_plot_time(data_preprocessed);
                    title       = sprintf( '%s, %s, %s', base_plot_name_ssr, 'time series', base_plot_name_param );
                    my_set_title(gcf, title, 'ICA & reject bad trials');
                    save_file    = sprintf( '%s-%s.pdf', base_file_name, 'proc-time' );
                    my_save_figure( gcf, save_file, [save_path 'figures/'] );

                    % freq plot
                    myft_plot_freq(data_preprocessed);
                    title       = sprintf( '%s, %s, %s', base_plot_name_ssr, 'frequency plot', base_plot_name_param );
                    my_set_title(gcf, title, 'ICA & reject bad trials');
                    save_file    = sprintf( '%s-%s.pdf', base_file_name, 'proc-freq' );
                    my_save_figure( gcf, save_file, [save_path 'figures/'] );

                    % time-freq plot
                    myft_plot_tf(data_preprocessed, analysisTimes);
                    title       = sprintf( '%s, %s, %s', base_plot_name_ssr, 'time-frequency', base_plot_name_param );
                    my_set_title(gcf, title, 'ICA & reject bad trials');
                    save_file    = sprintf( '%s-%s.pdf', base_file_name, 'proc-tf' );
                    my_save_figure( gcf, save_file, [save_path 'figures/'] );
                end

                break_keyboard = input('Enable keyboard? (y/N) ', 's');
                if strcmp( break_keyboard, 'y')
                    keyboard;
                end

                tfr_denoise_cont = input( 'Do you want to re-examine the trials/channels? (y/N) ', 's' );
            end
            
            % make averaged file
            disp('Averaging...');
            cfg.channel     = {'M*'};
            cfg.keeptrials  = 'no';
            cfg.covariance  = 'yes';
            data_timelock   = ft_timelockanalysis(cfg, data_preprocessed); %#ok<NASGU>
            savefile = [num2str(subj) '-' num2str(sess) '-' num2str(run) '-timelock-'  char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1}) '-' num2str(aveParams{aveParam}{2}(aveParamValue)) '.mat'];
            save([save_path savefile], 'data_timelock');
            disp(['File saved: ' savefile]);

        end
    end
end
