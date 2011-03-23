function dots_ft_cleaning(subj, sess, run, dataset)
% cfg.dataset = fif file
% subj_data   = matlab run data file

% for testing, use:
%   subject     4
%   session     5
%   dataset     4_090710
%   

ft_defaults;

subj_data       = sprintf('subject%i_ses%i_%i', subj, sess, run);
save_path       = sprintf('/Volumes/ShadyBackBowls/meg_data/Dots/%i/matlab-files/', subj);
meg_full_file   = sprintf('/Volumes/ShadyBackBowls/meg_data/Dots/%i/%s', subj, dataset);

%
% Setup configuration structure
%

if ~exist(meg_full_file, 'file')
    error('fif file not found. Please verify %s exists and that trigger has been fixed.', meg_full_file)
end

if ~exist(save_path, 'dir')
    mkdir(save_path);
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

cfg = cfg_base;                                         % ## CFG RESET! ##
cfg.trialfun        = 'defineDotsTrials';
cfg.dots.data       = data;
cfg.dots.coh        = cohVec;
cfg.dots.cue        = cueVec;
cfg.dots.ER         = ER;
cfg.dots.RT         = RT;
cfg.dots.dir_resp   = RDir;
cfg.dots.dir_correct = ST;
cfg.dots.preTrig    = 300;
cfg.dots.postTrig   = 300;
cfg.dots.left_RT    = Left_RT;
cfg.dots.right_RT   = Right_RT;

% Clean data - look at every non-error trial, store bad trials in cfg.
% Those trials will be excluded from analysis in defineDotsTrials.m.
cfg.dots.aveTime    = 'stim';
cfg.dots.aveParam   = 'all';

cfg = ft_definetrial(cfg);

cfg.bpfilter        = 'yes';
cfg.bpfreq          = [1 40];
cfg.channel         = 'M*1';
data_preprocessed   = ft_preprocessing(cfg);

% Examine magnetometers
cfg                 = cfg_base;                           % ## CFG RESET! ##
cfg.method          = 'trial';
cfg.alim            = 1e-12;
cfg.megscale        = 1;
cfg.eogscale        = 5e-8;
cfg.dots.artifact   = ft_rejectvisual(cfg,dataFIC);

cfg.continuous      = 'no';
cfg.viewmode        = 'vertical';
cfg.channel         = 'M*1';

cfg                 = ft_databrowser(cfg, data_preprocessed);
cfg.dots.artifact   = cfg.arfctdef.visual.artifact;
cfg                 = rmfield(cfg, 'trl');  % We only wanted the id times

aveTimes    = {'stim', 'resp'};
aveParams   = {{'coh', unique(cohVec)}, {'respdir','RL'}};  % currently not analyzing sigdet or arrow

% average for each parameter, both at stimulus and response
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
            cfg.dots.preTrig    = 300;
            cfg.dots.postTrig   = 300;
            cfg.dots.left_RT    = Left_RT;
            cfg.dots.right_RT   = Right_RT;

            cfg.dots.paramValue = aveParams{aveParam}{2}(aveParamValue);

            cfg.dots.aveTime    = char(aveTimes(aveTime));
            cfg.dots.aveParam   = char(aveParams{aveParam}{1});

            cfg = ft_definetrial(cfg);

            %
            % Define preprocessing routines
            %

            cfg.bpfilter        = 'no';
            cfg.bpfreq          = [1 40];
            cfg.demean          = 'yes';
            cfg.baselinewindow  = [-0.9 -0.6];
            data_preprocessed   = ft_preprocessing(cfg);

            savefile = [subj_data '-preprocessed-'  char(aveTimes(aveTime)) '-' num2str(aveParams{aveParam}{1}) '-' num2str(aveParams{aveParam}{2}(aveParamValue)) '.mat'];
            save([save_path savefile], 'data_preprocessed');
            disp(['File saved: ' savefile]);

        end
    end
end