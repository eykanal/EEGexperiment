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

filename = ['subject' num2str(subj) '_ses' num2str(ses) run '.mat'];

if ~exist( filename, 'file' )
    error( 'File doesn''t exist in path: %s', filename );
end

load( filename );

hard = min( cohVec );
easy = max( cohVec );

numbers = cell(9,8);
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

hard_num    = length( ER( cueVec == 'd' & cohVec == hard ) );
easy_num    = length( ER( cueVec == 'd' & cohVec == easy ) );
hard_perf   = 1 - mean( ER( cueVec == 'd' & cohVec == hard ) );
easy_perf   = 1 - mean( ER( cueVec == 'd' & cohVec == easy ) );
rt_hard     = mean( RT( cueVec == 'd' & cohVec == hard ) );
rt_hard_std = std(  RT( cueVec == 'd' & cohVec == hard ) );
rt_easy     = mean( RT( cueVec == 'd' & cohVec == easy ) );
rt_easy_std = std(  RT( cueVec == 'd' & cohVec == easy ) );

all_num = { 'sess', 'diff', '#',        'perf',     'RT',       'RT std'; ...
            ses,    hard,   hard_num,   hard_perf,  rt_hard,    rt_hard_std; ...
            ses,    easy,   easy_num,   easy_perf,  rt_easy,    rt_easy_std};
        
disp( all_num );
disp( numbers );
