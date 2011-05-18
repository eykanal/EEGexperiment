function dots_listFiles( subject )
% 
% function dots_listFiles( subject )
% 
% This function lists all files associated with a particular subject,
% including matlab run files and fif files.
%
%   subject = subject number
%
% Eliezer Kanal, 5/2010

unix(['ls -lR /Volumes/ShadyBackBowls/meg_data/Dots/' num2str(subject)]);
fprintf('\n');
disp('Dropbox:');
unix(['ls -lR ~/Dropbox/MATLAB/Dots/data/subj' num2str(subject)]);
