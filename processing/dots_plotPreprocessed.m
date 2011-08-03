function dots_plotPreprocessed(subj, sess, run, coherence)
% Simple function for generating time plots of a particular dataset &
% coherence.
% 
% Note: coherence argument is string (e.g., '8.5'), all else integers

dataset     = sprintf('%i-%i-%i-preprocessed-resp-coh-%s.mat', subj, sess, run, coherence);

data = load(dataset,'data_preprocessed');

num_trials = length(data.data_preprocessed.trial);

plot_title  = sprintf('Subject %i, session %i, run %i, %i trials, time series, coh (%s) @ resp, ICA & reject bad trials', subj, sess, run, num_trials, coherence);
save_name   = sprintf('%i-%i-%i-resp-coh%s-proc-time.pdf', subj, sess, run, coherence);
save_path   = sprintf('/Volumes/ShadyBackBowls/meg_data/Dots/%i/matlab-files/figures/', subj);

myft_plot_time(data.data_preprocessed, 'ylim', [-4.25e-13 4.25e-13], 'average', 1);
my_set_title(gcf, plot_title);
my_save_figure(gcf, save_name, save_path);
