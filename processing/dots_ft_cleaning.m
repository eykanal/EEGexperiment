% cfg.dataset = fif file
% subj_data   = matlab run data file

ft_defaults;

%
% Setup configuration structure
%

cfg_base = struct;                                      % ## CFG RESET! ##
cfg_base.dataset = '4_090710_4_trigFix.fif';
cfg_base.hdr = ft_read_header(cfg_base.dataset);


%
% Define averaging parameters
%

subj_data = 'subject4_ses8';


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
data_preprocessed   = ft_preprocessing(cfg);

cfg.continuous      = 'no';
cfg.viewmode        = 'vertical';
cfg.channel         = 'M*1';

cfg                 = ft_databrowser(cfg, data_preprocessed);
cfg.dots.artifact   = cfg.arfctdef.visual.artifact;
cfg                 = rmfield(cfg, 'trl');  % We only wanted the id times

aveTimes    = {'stim', 'resp'};
aveParams   = {'coh', 'respdir', 'arrow'};  % currently not analyzing sigdet

% average for each parameter, both at stimulus and response
for aveTime = 1:length(aveTimes)
    for aveParam = 1:length(aveParams)

        cfg = cfg_base;                                 % ## CFG RESET! ##
        
        cfg.dots.aveTime    = char(aveTimes(aveTime));
        cfg.dots.aveParam   = char(aveParams(aveParam));

        cfg = ft_definetrial(cfg);

        %
        % Define preprocessing routines
        %

        cfg.bpfilter        = 'yes';
        cfg.bpfreq          = [1 40];
        data_preprocessed   = ft_preprocessing(cfg);

        save([subj_data '-preprocessed-'  char(aveTimes(aveTime)) '-' char(aveParams(aveParam))], 'data_preprocessed');
    end
end