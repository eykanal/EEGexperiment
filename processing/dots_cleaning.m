function dots_ft_cleaning(subj, sess, run, dataset)
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

% Define averaging parameters
aveTimes    = {'stim', 'resp'};
aveParams   = {{'coh', unique(cohVec)}, {'respdir','RL'}};  % currently not analyzing sigdet or arrow

% preprocess for each averaging parameter, both at stimulus and response
for aveTime = 1:length(aveTimes)
    for aveParam = 1:length(aveParams)
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
            cfg.dots.preTrig    = 600;
            cfg.dots.postTrig   = 600;
            cfg.dots.left_RT    = Left_RT;
            cfg.dots.right_RT   = Right_RT;

            cfg.dots.paramValue = aveParams{aveParam}{2}(aveParamValue);

            cfg.dots.aveTime    = char(aveTimes(aveTime));
            cfg.dots.aveParam   = char(aveParams{aveParam}{1});

            cfg = ft_definetrial(cfg);

            %
            % Define preprocessing routines
            %

            cfg.bpfilter        = 'yes';
            cfg.bpfreq          = [1 40];
            cfg.demean          = 'no';
            cfg.baselinewindow  = [-0.9 -0.6];
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
            
            % The while loop allows viewing of the TFR, and then subsequent
            % re-denoising, if necessary
            tfr_denoise_cont = 'y';
            while strcmp( tfr_denoise_cont, 'y' )
                
                reject_vis_cont = 'y';
                while strcmp( reject_vis_cont, 'y' )
                    % Examine data for noise
                    cfg.channel         = 'M*';  %remove STI channels
                    cfg.method          = 'channel';
                    cfg.alim            = 1e-12;
                    cfg.megscale        = 1;
                    cfg.eogscale        = 5e-8;
                    %cfg.gradscale       = 0.05;
                    data_preprocessed   = ft_rejectvisual(cfg, data_preprocessed);

                    cfg.channel         = 'M*';  %remove STI channels
                    cfg.method          = 'trial';
                    cfg.alim            = 1e-12;
                    cfg.megscale        = 1;
                    cfg.eogscale        = 5e-8;
                    %cfg.gradscale       = 0.05;
                    data_preprocessed   = ft_rejectvisual(cfg, data_preprocessed);

                    beep;
                    reject_vis_cont = input( 'Do you want to re-examine the trials/channels? (y/n) ', 's' );
                end

                % temp - show frequency plot to determine whether need use
                % notch filter
                cfg_tmp             = cfg_base;
                cfg_tmp.output      = 'pow';
                cfg_tmp.method      = 'mtmconvol';
                cfg_tmp.taper       = 'hanning';
                cfg_tmp.foi         = 1:30;
                cfg_tmp.t_ftimwin   = 7./cfg_tmp.foi;
                cfg_tmp.toi         = -0.5:0.05:0.5;
                data_freq_fixWind   = ft_freqanalysis(cfg_tmp, data_preprocessed);

                cfg_tmp.t_ftimwin   = 0.5*ones(length(cfg_tmp.foi));
                data_freq_varWind   = ft_freqanalysis(cfg_tmp, data_preprocessed);

                cfg_tmp             = cfg_base;
                cfg_tmp.zlim        = [-3e-27 3e-27];	        
                cfg_tmp.showlabels  = 'yes';	
                cfg_tmp.layout      = 'neuromag306all.lay';

                figure();
                ft_multiplotTFR(cfg_tmp, data_freq_fixWind);
                figure();
                ft_multiplotTFR(cfg_tmp, data_freq_varWind);
keyboard;
                beep;
                tfr_denoise_cont = input( 'Do you want to re-examine the trials/channels? (y/n) ', 's' );
            end
            
            savefile = [subj_data '-preprocessed-'  char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1}) '-' num2str(aveParams{aveParam}{2}(aveParamValue)) '.mat'];
            save([save_path savefile], 'data_preprocessed');
            disp(['File saved: ' savefile]);

        end
    end
end