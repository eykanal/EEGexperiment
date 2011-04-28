Files added to FreeResponsefMRI by Marieke:
-----------------------------------------------------

for determining coherence thresholds:
quest_experiment.m - runs a bunch of trials of the QUEST staircasing algorithm, which yields a coherence at which the participant is x% correct
quest_block.m      - used by quest_experiment.m
psychometric_experiment.m - runs a bunch of trials to determine the whole psychometric function at a set of predefined coherences
psychometric_block.m      - the block of trials run by psychometric_experiment.m
trial_fixedview.m         - this is the trial function called by psychometric_block in which the participants see the stimulus for a fixed amount of time (typically 1 second)
psychometric_error_function - to minimize the error between actual trial performance (as a function of coherence) and a fitted theoretical distribution (normcdf, Weibull, or gamma cdf)
analyzePsychometric.m       - a convenient function to analyze the data obtained by psychometric_experiment.m (this will actually fit the psychometric curves)
test_coh_experiment.m       - run a block of trials at a specified coherence to check whether you indeed obtain the desired accuracy


for running an EEG experiment:
experiment_eeg.m - this is virtually identical to the fMRI experiment, except that when run in behavioral mode, it can include a QUEST procedure or a psychometric procedure to determine the 60% and 80% correct thresholds for this participant. Moreover, it will run straight through 4 successive runs of the fMRI procedure.

after running the EEG experiment:
createDDMevents.m - this will create a matlab structure with the behavioral data--for use with the eeg_toolbox
emse_split.m      - to split the EMSE file in different files for different channels--for use with the eeg_toolbox
