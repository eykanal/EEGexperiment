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
dbstop in dots_cleaning.m at averaging
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
    error('fif file not found. Please verify %s exists and that trigger_fix has been run.', meg_full_file);
end

if ~exist([subj_data '.mat'], 'file')
    error('Subject datafile (%s) not found.', [subj_data '.mat']);
end

if ~exist(save_path, 'dir')
    mkdir(save_path);
end

% Run trigger_fix if necessary
if isempty( strfind( meg_full_file, 'trigFix' ) )
    disp('Trigger_fix not yet run, executing now...');
    meg_full_file = trigger_fix( meg_full_file );
end

cfg_base            = struct;                           % ## CFG RESET! ##
cfg_base.dataset    = meg_full_file;
cfg_base.hdr        = ft_read_header(meg_full_file);

% Find triggers on STI101 channel
cfg = cfg_base;                                         % ## CFG RESET! ##
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

% Define averaging parameters, if not provided at runtime
if isempty('aveTimes')
    aveTimes    = {'stim', 'resp'};
end
if isempty('aveParams')
    aveParams   = {{'coh', unique(cohVec)}, {'respdir','RL'}};  % currently not analyzing sigdet or arrow
end

if isempty('analysisTimes')
    analysisTimes = [1000 1000];
end

% preprocess for each averaging parameter, both at stimulus and response
for aveParam = 1:length(aveParams)
    for aveTime = 1:length(aveTimes)
        for aveParamValue = 1:length(aveParams{aveParam}{2})

            cfg = cfg_base;                                 % ## CFG RESET! ##
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
            
            % The while loop allows denoising, viewing of the TFR, and then
            % subsequent re-denoising, if necessary
            tfr_denoise_cont = 'y';
            while strcmp( tfr_denoise_cont, 'y' )
                
                reject_vis_cont = 'y';
                while strcmp( reject_vis_cont, 'y' )
                    
                    % display plots
                    plot_time_freq(data_preprocessed);
                    
                    % Examine data for noise
                    cfg.channel         = 'M*';  %remove STI channels
                    cfg.megscale        = 1;
                    cfg.eogscale        = 5e-8;

                    cfg.method          = 'channel';
                    data_preprocessed   = ft_rejectvisual(cfg, data_preprocessed);
                    cfg.method          = 'trial';
                    data_preprocessed   = ft_rejectvisual(cfg, data_preprocessed);

                    component_analysis = input( 'Do you want to run ft_componentanalysis? (y/N) ', 's' );
                    
                    % component analysis
                    if strcmp( component_analysis, 'y' )
                        
                        % find gradiometer components
                        run_grad_again = 1;
                        while run_grad_again
                            cfg                 = [];
                            cfg.method          = 'fastica';
                            cfg.channel         = {'M*2', 'M*3'};
                            cfg.fastica.numOfIC = 40;
                            cfg.fastica.lastEig = 50;
                            cfg.fastica.verbose = 'off';
                            data_components = ft_componentanalysis(cfg, data_preprocessed);
                            
                            cfg                 = [];
                            cfg.layout          = 'neuromag306planar.lay';
                            ft_componentbrowser(cfg, data_components);
                            reject              = input( 'Enter components to reject (leave blank for none): ');
                            
                            if ~isempty( reject )
                                cfg             = [];
                                cfg.component   = reject;
                                data_preprocessed = ft_rejectcomponent(cfg, data_components, data_preprocessed);
                            else
                                % cancel out of "run grad again" loop
                                run_grad_again = 0;
                            end
                        end
                        
                        % find magnetometer components
                        run_mag_again = 1;
                        while run_mag_again
                            cfg                 = [];
                            cfg.method          = 'fastica';
                            cfg.channel         = {'M*1'};
                            cfg.fastica.numOfIC = 50;
                            cfg.fastica.lastEig = 50;
                            cfg.fastica.verbose = 'off';
                            data_components = ft_componentanalysis(cfg, data_preprocessed);
                            
                            cfg                 = [];
                            cfg.layout          = 'neuromag306mag.lay';
                            ft_componentbrowser(cfg, data_components);
                            reject              = input( 'Enter components to reject (leave blank for none): ');
                            
                            if ~isempty( reject )
                                cfg             = [];
                                cfg.component   = reject;
                                data_preprocessed = ft_rejectcomponent(cfg, data_components, data_preprocessed);
                            else
                                % cancel out of "run grad again" loop
                                run_mag_again = 0;
                            end
                        end
                    end
                    
                    beep;
                    reject_vis_cont = input( 'Do you want to re-examine the trials/channels? (y/N) ', 's' );
                end
                
                view_freq_plots = input( 'Do you want to see time/frequency plots? (y/N) ', 's' );
                
                if strcmp( view_freq_plots, 'y' )
                    
                    % plot averaged timeseries
                    plot_time_freq(data_preprocessed);
                    
                    % plot TFR
                    cfg             = [];
                    cfg.channel     = 'M*';
                    cfg.output      = 'pow';
                    cfg.method      = 'mtmconvol';
                    cfg.taper       = 'hanning';
                    cfg.foi         = 1:30;
                    cfg.t_ftimwin   = 2./cfg.foi;
                    cfg.toi         = -analysisTimes(1):0.05:analysisTimes(2);
                    data_freq_varWind = ft_freqanalysis(cfg, data_preprocessed);

                    cfg             = [];
                    cfg.showlabels  = 'no';	
                    cfg.layout      = 'neuromag306all.lay';
                    figure();
                    ft_multiplotTFR(cfg, data_freq_varWind);
                    save_figure(gcf);
                    
                    tfr_denoise_cont = input( 'Do you want to re-examine the trials/channels? (y/N) ', 's' );
                else
                    tfr_denoise_cont = 'n';
                end
            end
            
            savefile = [subj_data '-preprocessed-'  char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1}) '-' num2str(aveParams{aveParam}{2}(aveParamValue)) '.mat'];
            save([save_path savefile], 'data_preprocessed');
            disp(['File saved: ' savefile]);

        end
        
        % Make difference file, run averaging
        
        % already have the second condition, so use it
        data_timelock   = averaging(data_preprocessed);

        cond            = struct;
        cond(2)         = data_timelock;
            
        % process the first condition
        load([save_path subj_data '-preprocessed-'  char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1}) '-' num2str(aveParams{aveParam}{2}(1)) '.mat']);
        data_timelock   = averaging(data_preprocessed);
        cond(1)         = data_timelock;
        
        % difference the conditions, plot figures
        cond(3) = cond(1);
        cond(3).avg = cond(1).avg - cond(2).avg;
        
        plot_time_freq(cond(3));

    end
end

% Save a given figure to matlab-files/figures with a user-defined title and
% filename
function save_figure(h)
beep;
save_figure = input( 'Save figure? (y/N) ', 's' );
if strcmp( save_figure, 'y' )
    fig_title = input( 'Figure title: ', 's' );
    title( fig_title );
    save_name = input( 'File name: ', 's' );
    saveas( h, ['figures/' save_name], 'pdf' );
end

% Plot separate time and frequency plots, ask whether they should be saved
function plot_time_freq(data)
% Plot averaged general activity
cfg                 = [];
cfg.layout          = 'neuromag306all.lay';
cfg.showlabels      = 'no';
figure();
ft_multiplotER(cfg, data);
save_figure(gcf);

% plot frequency
cfg             = [];
cfg.method      = 'mtmfft';
cfg.output      = 'pow';
cfg.calcdof     = 'yes';
cfg.taper       = 'hanning';
cfg.foilim      = [1 40];
data_freq       = ft_freqanalysis( cfg, data );

cfg             = [];
cfg.layout      = 'neuromag306all.lay';
cfg.showlabels  = 'no';
cfg.ylim        = [0 3e-27];
figure();
ft_multiplotER( cfg, data_freq );
save_figure(gcf);

% perform averaging on a preprocessed dataset
function data_timelock = averaging(data)
cfg.channel     = ft_channelselection( 'M*', cfg.hdr.label );
cfg.keeptrials  = 'yes';
cfg.covariance  = 'yes';
data_timelock   = ft_timelockanalysis(cfg, data);
