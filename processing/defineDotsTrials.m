function trl = defineDotsTrials(cfg)
% requires:
%   cfg.dots.aveParam   1xn cell, each cell containing a 1x2 cell. First cell
%                       is one of {'coh', 'respdir', 'arrow', 'sigdet', 'baseline'},
%                       second cell contains the values to be iterated over
%                       (i.e., coherence values, response directions, arrow
%                       directions, etc.)
%   cfg.dots.paramValue Specific value of cfg.dots.aveParam to be averaged
%   cfg.dots.aveTime    One of {'stim', 'resp'}
%   cfg.dots.preTrig    time before trigger onset averaging should begin
%   cfg.dots.postTrig   time after trigger onset averaging should begin
%
% Triggers from STI101, normalized to be 1 ms long
%   cfg.dots.data
%
% All of the below come directly from the subject's matlab run data file.
%   cfg.dots.coh
%   cfg.dots.cue
%   cfg.dots.dir_resp     Note: this is 'RDir' in the datafile
%   cft.dots.dir_correct  Note: this is 'ST' in the datafile
%   cfg.dots.ER
%   cfg.dots.RT
%   cfg.dots.left_RT
%   cfg.dots.right_RT

% Needs to output two things.
% trl :  n x 4 array:
%   1) trial start
%   2) trial end
%   3) trigger time relative to start
%   4) trigger value
% event: n x 1 struct, each n has following fields:
%     type
%     sample
%     value
%     offset
%     duration

% some files won't contain signal detection routine, if so skip it
sigDet = 1;
if ~isfield( cfg.dots, 'left_RT' ) || ~isfield( cfg.dots, 'right_RT' )
    cfg.dots.left_RT  = [];
    cfg.dots.right_RT = [];
    
    sigDet = 0;
end

% simplify var names
aveParam    = cfg.dots.aveParam;
data        = cfg.dots.data;
coh         = cfg.dots.coh;
cue         = cfg.dots.cue;
ER          = cfg.dots.ER;
RT          = cfg.dots.RT;
dir_resp    = cfg.dots.dir_resp;
dir_correct = cfg.dots.dir_correct;
left_RT     = cfg.dots.left_RT;
right_RT    = cfg.dots.right_RT;
preTrig     = cfg.dots.preTrig;
postTrig    = cfg.dots.postTrig;

% paramValue must be present for some, but not for all, so only throw error
% if needed
if ( strcmp(aveParam, 'coh') || strcmp(aveParam, 'respdir') || strcmp(aveParam, 'arrow') ) && ~isfield(cfg.dots, 'paramValue')
    error(['Please specify the ' aveParam ' value to be averaged in cfg.dots.aveParam.']);
end
if isfield(cfg.dots, 'paramValue')
    paramValue  = cfg.dots.paramValue;
end

% Number of trigger onsets should equal number of offsets.
if length(data.times.stim) ~= length(data.times.resp)
    error('Trigger onset and offset vectors are nonequal length!');
end

% The number of triggers in the MEG file should exactly match the length of
% the number of trials (as measured by the coherence vector).
if length([coh right_RT left_RT]) ~= length(data.times.stim)
    
    % Find the Infs in the RT file, remove from the appropriate vars
    infs = find(isinf(RT));
    
    for n = 1:length(infs)
        bad_entry = infs(n);
        
        coh         = [coh(1:bad_entry-1)  coh(bad_entry+1:length(coh))];
        cue         = [cue(1:bad_entry-1)  cue(bad_entry+1:length(cue))];
        ER          = [ER (1:bad_entry-1)   ER(bad_entry+1:length(ER))];
        RT          = [RT (1:bad_entry-1)   RT(bad_entry+1:length(RT))];
        dir_resp    = [dir_resp(1:bad_entry-1)    dir_resp(bad_entry+1:length(dir))];
        dir_correct = [dir_correct(1:bad_entry-1) dir_correct(bad_entry+1:length(RDir))];  
    end
    
    % Re-check to see if it still doesn't match
    if length([coh right_RT left_RT]) ~= length(data.times.stim)

        % This is the basic troubleshooting routine to determine where the
        % problem is (whether the PTB file or MEG file is shorter, and which
        % entry is the missing one)
        PTB_RT = RT';
        MEG_RT = (data.times.resp' - data.times.stim') / 1000;

        PTB_len = length(PTB_RT);
        MEG_len = length(MEG_RT);

        % append zeros to the end of the shorter one so the subtraction works
        if(MEG_len > PTB_len)
            PTB_RT = [PTB_RT; zeros(MEG_len - PTB_len,1)];
        else
            MEG_RT = [MEG_RT; zeros(PTB_len - MEG_len,1)];
        end

        diff_RT = MEG_RT - PTB_RT;
        disp(diff_RT);

        warning('PsychToolbox and STI101 trigger onsets report unequal number of trials! Examine the above array to find which entry is missing.');
        keyboard;
    end
end

%
% Find appropriate time series for each condition. Determine which
% parameter to average on using "cfg.dots.aveParam" field.
%

% determine whether to use .stim or .resp vector based on cfg.dots.aveTime
if strcmp( cfg.dots.aveTime, 'stim' )
    times = data.times.stim;
else
    times = data.times.resp;
end

% do from preTrig ms before onset to postTrig ms after, whether stim or resp
switch cfg.dots.aveParam
    case 'all'
        goodResponses = ( ER == 0 & ~isinf(RT) );
        len = length( times( goodResponses ) );
        trl = zeros( len, 4 );
        
        trl(:,1) = times( goodResponses )' - preTrig;
        trl(:,2) = times( goodResponses )' + postTrig;
        trl(:,3)  = -preTrig;
        trl(:,4) = 1;

    case 'coh'
        goodResponses = ( cue == 'd' & ER == 0 & ~isinf(RT) & coh == paramValue );
        len = length( times( goodResponses ) );
        trl = zeros( len, 4 );

        trl(:,1) = times( goodResponses )' - preTrig;
        trl(:,2) = times( goodResponses )' + postTrig;
        trl(:,3)  = -preTrig;
        trl(:,4) = paramValue;
        
    case 'respdir'
        goodResponses = ( cue == 'd' & ER == 0 & ~isinf(RT) & dir_resp == paramValue );
        len = length( times( goodResponses ) );
        trl = zeros( len, 4 );

        % Average based on response direction
        trl(:,1) = times( goodResponses )' - preTrig;
        trl(:,2) = times( goodResponses )' + postTrig;
        trl(:,3)  = -preTrig;
        % 1 = left, 2 = right
        trl(:,4) = 1;
        trl( dir_resp( goodResponses ) == 'R', 4 ) = 2;

    case 'arrow'
        % redefine good_responses to 'cue == a', reset len
        goodResponses = ( cue == 'a' & ER == 0 & ~isinf(RT) & dir_correct == paramValue );
        len = length( times( goodResponses ) );
        trl = zeros( len, 4 );

        trl(:,1) = times( goodResponses )' - preTrig;
        trl(:,2) = times( goodResponses )' + postTrig;
        trl(:,3)  = -preTrig;
        % 1 = left, 2 = right
        trl(:,4) = 1;
        trl( dir_correct( goodResponses ) == 'R' , 4 ) = 2;
        
    case 'sigdet'
        % Average the signal detection routine, if it's in the datafile.
        sigdet_RT = [Left_RT Right_RT];
        if( sigDet )
            len = length( times( length(coh)+1 : length(coh)+length(sigdet_RT) ) );
            trl = zeros( len, 4 );

            trl(:,1) = times( length(coh)+1 : length(coh)+length(sigdet_RT) )' - preTrig;
            trl(:,2) = times( length(coh)+1 : length(coh)+length(sigdet_RT) )' + postTrig;
            trl(:,3)  = -preTrig;
            % 1 = left, 2 = right
            trl(:,4) = 1;
            trl( 1:length(Left_RT), 4 ) = 2;
        end
end

