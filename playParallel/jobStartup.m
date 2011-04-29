function jobStartup(job)

PTBpath = 'Documents/MATLAB/Psychtoolbox3/';
fullPTBpath = pathRelToHome(PTBpath);
addpath( fullPTBpath );

curr_dir = pwd;
cd( PTB_path );
SetupPsychtoolbox;
cd( curr_dir );