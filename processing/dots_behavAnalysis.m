function dots_behavAnalysis(subj, ses, run)
% [numbers all_num] = dots_behavAnalysis(subj, ses, run)
%
% subj  = subject id
% ses   = session #
% run   = run #
%
% 

if ~exist( 'run', 'var' )
    run = '';
else
    run = ['_' num2str(run)];
end

filename = ['~/Documents/MATLAB/EEGExperiment/data/subj' num2str(subj) '/subject' num2str(subj) '_ses' num2str(ses) run '.mat'];

if ~exist( filename, 'file' )
    error( 'File doesn''t exist in path: %s', filename );
end

load( filename );

coherences = unique( cohVec );

numbers = cell( numblocks+1, 8 );
numbers(1,:) = {'sess','block','type','diff','#','perf','RT','RT std'};

% loop through blocks
for n = min(blocknum):max(blocknum)
    type = cueVec( blocknum == n );
    type = type(1);
    
    diff = cohVec( blocknum == n );
    diff = diff(1);
    
    perf = 1 - mean( ER( blocknum == n) );
    num  = length( ER( blocknum == n ) );
    rt   = mean( RT( blocknum == n ) );
    rt_std = std( RT( blocknum == n ) );
    
    row = n - min(blocknum) + 1;
    numbers(row+1,:) = {ses n type diff num perf rt rt_std};
end

num_coherences = length(coherences);
all_num = { 'sess', 'diff', '#', 'perf', 'RT', 'RT std' };

for n=1:num_coherences
    num    = length( ER( cueVec == 'd' & cohVec == coherences(n)) );
    perf   = 1 - mean( ER( cueVec == 'd' & cohVec == coherences(n) ) );
    rt     = mean( RT( cueVec == 'd' & cohVec == coherences(n) ) );
    rt_std = std(  RT( cueVec == 'd' & cohVec == coherences(n) ) );

    all_num(n+1,:) = { ses, coherences(n), num, perf, rt, rt_std };
end
        
disp( all_num );
disp( numbers );
