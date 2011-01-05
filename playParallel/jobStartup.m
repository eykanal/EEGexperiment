function jobStartup(job)

PTB_path = '/Users/eliezerk/Documents/MATLAB/Psychtoolbox3/';
addpath( PTB_path );

curr_dir = pwd;
cd( PTB_path );
SetupPsychtoolbox;
cd( curr_dir );