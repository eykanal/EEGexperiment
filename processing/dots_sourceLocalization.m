% Entirety of script based on
% http://fieldtrip.fcdonders.nl/tutorial/beamformer

% prepare data to be localized
load 19-preprocessed-resp-coh-h; dat_hi = data_preprocessed; clear data_preprocessed;
load 19-preprocessed-resp-coh-l; dat_lo = data_preprocessed; clear data_preprocessed;

% calculate cross-spectral densities for relevant parts of the trial
cfg             = [];                                           
cfg.toilim      = [-0.7 0.1];                       
dat_hi          = ft_redefinetrial(cfg, dat_hi);
dat_lo          = ft_redefinetrial(cfg, dat_lo);

% # THIS WILL PROBABLY NOT WORK! Change back to mtmfft as described in
% tutorial
cfg             = [];
cfg.method      = 'mtmconvol';
cfg.output      = 'powandcsd';
cfg.taper       = 'hanning';
cfg.foi         = 8:12;
cfg.t_ftimwin   = 5./cfg.foi;
cfg.toi         = -0.7:0.05:0.1;
dat_hi_freq3    = ft_freqanalysis(cfg, dat_hi);
dat_lo_freq3    = ft_freqanalysis(cfg, dat_lo);

% load in MRI data (reference first DICOM file)
mri = ft_read_mri('/Volumes/ShadyBackBowls/mri_data/spmOutput/s19-0005-00001-000192-01.img');

% align the brain
cfg = [];
cfg.method      = 'interactive';
mri_realign     = ft_volumerealign(cfg, mri);

% normalize slices and spaces between slices
cfg = [];
cfg.resolution = 1; % mm
cfg.dim = mri_orig.dim;
mri_reslice = ft_volumereslice(cfg, mri_realign);

% segment the brain
cfg             = [];
cfg.write       = 'no';
cfg.coordsys    = 'neuromag';
segmentedmri    = ft_volumesegment(cfg, mri);

% prepare head model
vol = ft_prepare_singleshell([],segmentedmri);

% make leadfield
grad = load('19-6-1-preprocessed-resp-coh-15');  % any preproc file from subject, need hdr.grad data
cfg             = [];
cfg.grad        = dat_hi.hdr.grad;
cfg.vol         = vol;
cfg.reducerank  = 2;
cfg.channel     = {'MEG','-MEG0812'}; % also specify any other bad channels
cfg.grid.resolution = 1;
grid = ft_prepare_leadfield(cfg);

% fit CSD to leadfield, calculate source locations 
cfg             = []; 
cfg.frequency   = 10;  
cfg.method      = 'dics';
cfg.projectnoise = 'yes';
cfg.grid        = grid; 
cfg.vol         = vol;
cfg.grad        = dat_hi.hdr.grad;
cfg.lambda      = 0;

source_hi       = ft_sourceanalysis(cfg, dat_hi_freq);
source_lo       = ft_sourceanalysis(cfg, dat_lo_freq);

% take difference (actual values can't be plotted for some reason, see
% http://fieldtrip.fcdonders.nl/tutorial/beamformer#plot_the_result)
source_diff = source_hi;
source_diff.avg.pow = (source_hi.avg.pow - source_lo.avg.pow) ./ source_lo.avg.pow;
  
cfg             = [];
cfg.downsample  = 1;
source_diff_int   = ft_sourceinterpolate(cfg, source_diff, mri);

% plot
cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'avg.pow';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim   = 'maxabs'; %[0.0 1.2];
cfg.opacitylim    = 'maxabs'; %[0.0 1.2]; 
cfg.opacitymap    = 'rampup';
cfg.slicerange    = [50 172];
figure
ft_sourceplot(cfg, source_diff_int);
