function dots_find_money(subject, mri, meg_hrs)
%
% function dots_find_money(data_dir, meg_hrs)
%
% Function to determine how much money a subject has accumulated over the
% course of the experiment.
%   subject     subject ID
%   mri         1 if MRI done, 0 otherwise
%   meg_hrs     number of hours of MEG time subject has logged
%
% Eliezer Kanal, 2/7/11

filepath    = ['~/Documents/MATLAB/EEGExperiment/data/subj' num2str(subject)];
files       = dir(filepath);
addpath(filepath);

money = 0;

fprintf('\n');

% skip the first three (., .., .DS_Store)
for file = 4:length(files)
    % if (1) the file is a mat file and (2) contains the variable "money"
    if strcmp( files(file).name(end-2:end), 'mat') ...
            && ~isempty( whos( '-file', files(file).name, 'money' ) )
        t_money = load( [filepath '/' files(file).name], 'money' );
        money = money + t_money.money;

        fprintf( 1, '%s\t$%1.2f', num2str(files(file).name), t_money.money/100);
        
        % if didn't finish study, add $5 for each behavioral
        if meg_hrs == 0 && ~isempty( whos( '-file', [filepath '/' files(file).name], 'ERpsych' ) )
            money = money + 500;
            fprintf( 1, ' + $5.00');
        end
        
        fprintf( 1, '\t$%1.2f\n', money/100);
    end
end

% add $10.00 for MRI
if mri
    fprintf('MRI: $10\n');
    money = money + 1000; 
end

% add 15/hr for MEG
fprintf('from MEG: $%1.2f\n',(meg_hrs * 15));
money = money + (meg_hrs * 1500);

fprintf( 1, '\nTotal - $%1.2f\n\n', money/100 );