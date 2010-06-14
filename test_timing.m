waitdur = 15; blockdur = 30; numblocks = 5;

% Select a random set of block timings beforehand, and pass them to block
% and trial. This is stored as a row of timings in a matrix with one row
% for each block. ISI probabilities are meant to be a quasi-exponentially
% distributed set of values, but constrained to be in multiples of the TR,
% which is 2 seconds. 
timing_array = cell(numblocks,1);
ISI_array = cell(numblocks,1);
current_duration = waitdur; % This variable keeps track of total time elapsed in experiment
for i = 1:numblocks
    % Initialize timing array values to begin at the current duration:
    timing_array{i} = current_duration;
    sumISI = 0;                    % This keeps track of how much time has elapsed in a block
    while sumISI < 30,
        u = rand(1);
        if u < .5063
            sumISI = sumISI + 2;
            timing_array{i} = [timing_array{i}, timing_array{i}(end)+2];
            ISI_array{i} = [ISI_array{i}, 2];
        elseif u < 0.8136
            sumISI = sumISI + 4;
            timing_array{i} = [timing_array{i}, timing_array{i}(end)+4];
            ISI_array{i} = [ISI_array{i}, 4];
        else
            sumISI = sumISI + 6;
            timing_array{i} = [timing_array{i}, timing_array{i}(end)+6];
            ISI_array{i} = [ISI_array{i}, 6];
        end
    end
    % Truncation of the last ISI may be needed to fit the sum inside
    % blockdur seconds:
    timing_array{i}(end) = timing_array{i}(end) - (sumISI-blockdur);
    ISI_array{i}(end) = ISI_array{i}(end) - (sumISI-blockdur);
    
    % Remove current duration as first element of timing_array row:
    timing_array{i}(1) = [];
    
    current_duration = current_duration + blockdur + waitdur;
end

keyboard
