function jobStartup(job)

PTBpath = 'Documents/MATLAB/Psychtoolbox3/';
fullPTBpath = pathRelToHome( PTBpath );
addpath( fullPTBpath );

curr_dir = pwd;
cd( fullPTBpath );
SetupPsychtoolbox;
cd( curr_dir );