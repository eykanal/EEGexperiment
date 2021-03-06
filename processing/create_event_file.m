function create_event_file( fiff, subj_data, path )
%
% function create_event_file( trigger_line )
%
%   fiff      = MEG data file name (including path) 
%   subj_data = data file containing run data (subject#_ses#.mat)
%   path      = path where files should be saved
%
% Write an event file for coherence-based analysis. Exclude all incorrect
% responses. Place four triggers - (1) low coherence trial onset, (2) high
% coherence trial onset, (3) low coherence response time, (4) high 
% coherence response time.
%
% Eliezer Kanal - 10/26/10

if nargin == 2
    path = pwd;
end

filename = fiff(1:length(fiff)-4);

%
% Load files
%

hdr   = fiff_setup_read_raw( fiff );
picks = fiff_pick_types( hdr.info, false, false, false, {'STI101'} );
trig  = fiff_read_raw_segment( hdr, hdr.first_samp, hdr.last_samp, picks );

% Fix so each pulse is exactly 1 ms long
trig(trig > 0 & [0 diff(trig)] <= 0) = 0;

data.values     = trig(trig>0);
data.times.raw  = find(trig>0);

% Add the initial skip to the raw times
data.times.raw = data.times.raw + double(hdr.first_samp);

% Time of trigger pulse in ms, including initial skip
data.times.onset    = data.times.raw(data.values == 1);
data.times.offset   = data.times.raw(data.values == 2);

% see VoodooPad for description of variables
load(subj_data, 'coherence_array', 'cohVec', 'cueVec', 'ST', 'ER', 'RT',...
    'Left_RT', 'Right_RT', 'RDir');
% some files won't contain signal detection routine, if so skip it
sigDet = 1;
if ~exist('Left_RT', 'var') || ~exist('Right_RT', 'var')
    Left_RT  = [];
    Right_RT = [];
    
    sigDet = 0;
end

%
% Sanity checks
%

% Number of trigger onsets should equal number of offsets.
if length(data.times.onset) ~= length(data.times.offset)
    error('Trigger onset and offset vectors are nonequal length!');
end

% The number of triggers in the MEG file should exactly match the length of
% the number of trials (as measured by the coherence vector).
if length([cohVec Right_RT Left_RT]) ~= length(data.times.onset)
    
    % Find the Infs in the RT file, remove from the appropriate vars
    infs = find(isinf(RT));
    
    for n = 1:length(infs)
        bad_entry = infs(n);
        
        cohVec = [cohVec(1:bad_entry-1) cohVec(bad_entry+1:length(cohVec))];
        cueVec = [cueVec(1:bad_entry-1) cueVec(bad_entry+1:length(cueVec))];
        ST     = [ST(1:bad_entry-1) ST(bad_entry+1:length(ST))];
        ER     = [ER(1:bad_entry-1) ER(bad_entry+1:length(ER))];
        RT     = [RT(1:bad_entry-1) RT(bad_entry+1:length(RT))];
        RDir   = [RDir(1:bad_entry-1) RDir(bad_entry+1:length(RDir))];  
    end
    
    % Re-check to see if it still doesn't match
    if length([cohVec Right_RT Left_RT]) ~= length(data.times.onset)
        manual_break = true;
    end

    % This is the basic troubleshooting routine to determine where the
    % problem is (whether the PTB file or MEG file is shorter, and which
    % entry is the missing one)
    PTB_RT = RT';
    MEG_RT = (data.times.offset' - data.times.onset') / 1000;
    
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

    % Including a catch here so I can skip the error in manual
    % troubleshooting. See end of file for useful commands.
    if ~exist( 'manual_break', 'var' )
        error('PsychToolbox and STI101 trigger onsets report unequal number of trials! Examine the above array to find which entry is missing.');
    end
end

%
% Find appropriate time series for each condition
%

% Average based on coherence. Only include (1) correct, (2) non-arrow
% trials.
coherence_entries.times.onset  = data.times.onset (cueVec == 'd' & ER == 0 & ~isinf(RT));
coherence_entries.times.offset = data.times.offset(cueVec == 'd' & ER == 0 & ~isinf(RT));

coherence_entries.coherence = ones(size(coherence_entries.times.onset));  % set all coherence entries to "high"... gotta start somewhere!
coherence_entries.coherence(cohVec(cueVec == 'd' & ER == 0) == min(coherence_array)) = 2;  % change the low ones to "low"

coherence_entries.labels = repmat({'high coherence'}, size(coherence_entries.coherence));
coherence_entries.labels(coherence_entries.coherence == 2) = {'low coherence'};

% Average based on response direction
respdir_entries.times.onset  = data.times.onset (cueVec == 'd' & ~isinf(RT));
respdir_entries.times.offset = data.times.offset(cueVec == 'd' & ~isinf(RT));

respdir_entries.direction = ones(size(respdir_entries.times.onset));
respdir_entries.direction(RDir == 'R') = 2;

respdir_entries.labels = repmat({'left'}, size(respdir_entries.direction));
respdir_entries.labels(respdir_entries.direction == 2) = {'right'};

% Average based on arrows. Only include (1) correct, (2) arrow trials.
arrows_entries.times.onset  = data.times.onset (cueVec == 'a' & ER == 0 & ~isinf(RT));
arrows_entries.times.offset = data.times.offset(cueVec == 'a' & ER == 0 & ~isinf(RT));

arrows_entries.direction = ones(size(arrows_entries.times.onset));
arrows_entries.direction(ST == 'R') = 2;
 
arrows_entries.labels = repmat({'right'}, size(arrows_entries.direction));
arrows_entries.labels(arrows_entries.direction == 2) = {'left'};

% Average the signal detection routine, if it's in the datafile.
sigdet_RT = [Left_RT Right_RT];
if( sigDet )
    sigdet_entries.times.onset  = data.times.onset (length(cohVec)+1 : length(cohVec)+length(sigdet_RT));
    sigdet_entries.times.offset = data.times.offset(length(cohVec)+1 : length(cohVec)+length(sigdet_RT));

    sigdet_entries.direction = ones(size(sigdet_RT));
    sigdet_entries.direction(1:length(Left_RT)) = 2;

    sigdet_entries.labels = repmat({'left'}, size(sigdet_entries.direction));
    sigdet_entries.labels(sigdet_entries.direction == 2) = {'right'};
end
    
%
% Write files
%

% open/create coherence event file for writing
fid_coh_stim     = fopen(fullfile(path, sprintf('%s_coh_stim.eve',filename)),'w+');
fid_coh_resp     = fopen(fullfile(path, sprintf('%s_coh_resp.eve',filename)),'w+');
fid_respdir_stim = fopen(fullfile(path, sprintf('%s_respdir_stim.eve',filename)),'w+');
fid_respdir_resp = fopen(fullfile(path, sprintf('%s_respdir_resp.eve',filename)),'w+');
fid_arrows_stim  = fopen(fullfile(path, sprintf('%s_arrows_stim.eve',filename)),'w+');
fid_arrows_resp  = fopen(fullfile(path, sprintf('%s_arrows_resp.eve',filename)),'w+');
if( sigDet )
    fid_sigdet_stim = fopen(fullfile(path, sprintf('%s_sigdet_stim.eve',filename)),'w+');
    fid_sigdet_resp = fopen(fullfile(path, sprintf('%s_sigdet_resp.eve',filename)),'w+');
end

% determine error rate
ER_condition = sum(cueVec=='a' & ER == 0 & ~isinf(RT))/sum(cueVec=='a');
fprintf('Error rate for arrows = %0.4f\n', ER_condition);
for n = 1:length(coherence_array)
    ER_condition = sum(cueVec=='d' & ER==0 & ~isinf(RT) & cohVec==coherence_array(n))/sum(cueVec=='d' & cohVec==coherence_array(n));
    fprintf('Error rate for coherence %d = %0.4f\n', coherence_array(n), ER_condition);
end

% save event file in following format:
%  <sample> <time> <from> <to> <text>
% needs to begin with "0 0 0 0" (see mne 2.7 manual, section 4.10.5).

% write the coherence event file
fprintf(fid_coh_stim,'%8i\t%5.3f\t0\t0\n', hdr.first_samp, hdr.first_samp/1000);
fprintf(fid_coh_resp,'%8i\t%5.3f\t0\t0\n', hdr.first_samp, hdr.first_samp/1000);
fprintf(fid_respdir_stim,'%8i\t%5.3f\t0\t0\n', hdr.first_samp, hdr.first_samp/1000);
fprintf(fid_respdir_resp,'%8i\t%5.3f\t0\t0\n', hdr.first_samp, hdr.first_samp/1000);
fprintf(fid_arrows_stim,'%8i\t%5.3f\t0\t0\n', hdr.first_samp, hdr.first_samp/1000);
fprintf(fid_arrows_resp,'%8i\t%5.3f\t0\t0\n', hdr.first_samp, hdr.first_samp/1000);
if( sigDet )
    fprintf(fid_sigdet_stim,'%8i\t%5.3f\t0\t0\n', hdr.first_samp, hdr.first_samp/1000);
    fprintf(fid_sigdet_resp,'%8i\t%5.3f\t0\t0\n', hdr.first_samp, hdr.first_samp/1000);
end

% write coherence file
for n = 1:length(coherence_entries.times.onset)
	fprintf(fid_coh_stim, '%8i\t%5.3f\t%i\t%i\t%s\n', coherence_entries.times.onset(n),  coherence_entries.times.onset(n)/1000,  0, coherence_entries.coherence(n), mat2str(cell2mat(coherence_entries.labels(n))));
    fprintf(fid_coh_resp, '%8i\t%5.3f\t%i\t%i\t%s\n', coherence_entries.times.offset(n), coherence_entries.times.offset(n)/1000, 0, coherence_entries.coherence(n), mat2str(cell2mat(coherence_entries.labels(n))));
end

% write response direction file
for n = 1:length(respdir_entries.times.onset)
    fprintf(fid_respdir_stim, '%8i\t%5.3f\t%i\t%i\t%s\n', respdir_entries.times.onset(n),  respdir_entries.times.onset(n)/1000,  0, respdir_entries.direction(n), mat2str(cell2mat(respdir_entries.labels(n))));
    fprintf(fid_respdir_resp, '%8i\t%5.3f\t%i\t%i\t%s\n', respdir_entries.times.offset(n), respdir_entries.times.offset(n)/1000, 0, respdir_entries.direction(n), mat2str(cell2mat(respdir_entries.labels(n))));
end

% write arrows file
for n = 1:length(arrows_entries.times.onset)
    fprintf(fid_arrows_stim, '%8i\t%5.3f\t%i\t%i\t%s\n', arrows_entries.times.onset(n),  arrows_entries.times.onset(n)/1000,  0, arrows_entries.direction(n), mat2str(cell2mat(arrows_entries.labels(n))));
    fprintf(fid_arrows_resp, '%8i\t%5.3f\t%i\t%i\t%s\n', arrows_entries.times.offset(n), arrows_entries.times.offset(n)/1000, 0, arrows_entries.direction(n), mat2str(cell2mat(arrows_entries.labels(n))));
end

% write signal detection file
if( sigDet )
    for n = 1:length(sigdet_entries.times.onset)
        fprintf(fid_sigdet_stim, '%8i\t%5.3f\t%i\t%i\t%s\n', sigdet_entries.times.onset(n),  sigdet_entries.times.onset(n)/1000,  0, sigdet_entries.direction(n), mat2str(cell2mat(sigdet_entries.labels(n))));
        fprintf(fid_sigdet_resp, '%8i\t%5.3f\t%i\t%i\t%s\n', sigdet_entries.times.offset(n), sigdet_entries.times.offset(n)/1000, 0, sigdet_entries.direction(n), mat2str(cell2mat(sigdet_entries.labels(n))));
    end
end

fclose(fid_coh_stim);
fclose(fid_coh_resp);
fclose(fid_respdir_stim);
fclose(fid_respdir_resp);
fclose(fid_arrows_stim);
fclose(fid_arrows_resp);
if( sigDet )
    fclose(fid_sigdet_stim);
    fclose(fid_sigdet_resp);
end

disp('FILES CREATED:');
fprintf('%s_coh_stim.eve\n',filename);
fprintf('%s_coh_resp.eve\n',filename);
fprintf('%s_respdir_stim.eve\n',filename);
fprintf('%s_respdir_resp.eve\n',filename);
fprintf('%s_arrows_stim.eve\n',filename);
fprintf('%s_arrows_resp.eve\n',filename);
if( sigDet )
    fprintf('%s_sigdet_stim.eve\n',filename);
    fprintf('%s_sigdet_resp.eve\n',filename);
end



% for troubleshooting; remove single entries from all PTB vectors

% cohVec = [cohVec(1:bad_entry-1) cohVec(bad_entry+1:length(cohVec))];
% cueVec = [cueVec(1:bad_entry-1) cueVec(bad_entry+1:length(cueVec))];
% ST = [ST(1:bad_entry-1) ST(bad_entry+1:length(ST))];
% ER = [ER(1:bad_entry-1) ER(bad_entry+1:length(ER))];
% RT = [RT(1:bad_entry-1) RT(bad_entry+1:length(RT))];
% RDir = [RDir(1:bad_entry-1) RDir(bad_entry+1:length(RDir))];
