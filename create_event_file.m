function create_event_file( fiff, subj_data )
%
% function create_event_file( trigger_line )
%
%   fiff      = MEG data file name (including path) 
%   subj_data = data file containing run data (subject#_ses#.mat)
%
% Write an event file for coherence-based analysis. Exclude all incorrect
% responses. Place four triggers - (1) low coherence trial onset, (2) high
% coherence trial onset, (3) low coherence response time, (4) high 
% coherence response time.

%
% Load files
%

hdr   = fiff_setup_read_raw( fiff );
picks = fiff_pick_types( hdr.info, false, false, false, {'STI101'} );
trig  = fiff_read_raw_segment( hdr, hdr.first_samp, hdr.last_samp, picks );

% Time of trigger pulse in ms, including initial skip. Use diff() command
% to ensure only one event in case the pulse lasts more than one ms.
times.trig.onset    = intersect(find(or(trig == 5,  trig == 10)), find(diff(trig) > 0) + 1);
times.trig.offset   = intersect(find(or(trig == 15, trig == 20)), find(diff(trig) > 0) + 1);
times.sigdet.onset  = intersect(find(or(trig == 25, trig == 30)), find(diff(trig) > 0) + 1);
times.sigdet.offset = intersect(find(or(trig == 35, trig == 40)), find(diff(trig) > 0) + 1);

% Actual values recorded to STI101
values.trig.coh   = trig(times.trig.onset);     % coherence value
values.trig.err   = trig(times.trig.offset);    % correct (0) or error (1)?
values.sigdet.dir = trig(times.sigdet.onset);   % trial direction (25 = left, 30 = right)
values.sigdet.err = trig(times.sigdet.offset);  % correct (0) or error (1)?

% see VoodooPad for description of variables
load(subj_data, 'coherence_array', 'cohVec', 'ER', 'RT', 'Left_RT', 'Right_RT');
sigdet_RT = [Left_RT Right_RT];

comments{min(coherence_array)} = 'low coherence';
comments{max(coherence_array)} = 'high coherence';
comments{15} = 'incorrect response';
comments{20} = 'correct response';
comments{25} = 'leftwards motion';
comments{30} = 'rightwards motion';
comments{35} = 'incorrect response';
comments{40} = 'correct response';

%
% Sanity checks
%

% Number of trigger onsets should equal number of offsets.
if length(times.trig.onset) ~= length(times.trig.offset)
    error('Trigger onset and offset vectors are nonequal length!');
end
if length(times.sigdet.onset) ~= length(times.sigdet.offset)
    error('Signal detection onset and offset vectors are unequal length!');
end

% The number of triggers in the MEG file should exactly match the length of
% the number of trials (as measured by the coherence vector).
if length(cohVec) ~= length(times.trig.onset)
    error('PsychToolbox and STI101 trigger onsets report unequal number of regular trials!');
end
if length(sigdet_RT) ~= length(times.sigdet.onset)
    error('PsychToolbox and STI101 trigger onsets report unequal number of signal detection trials!');
end

%
% Write files
%

% open/create coherence event file for writing
[path,filename] = fileparts(hdr.info.filename);

fid_stim = fopen(fprint('%s/%s_coh_stim.eve',path,filename),'w+');
fid_resp = fopen(fprint('%s/%s_coh_resp.eve',path,filename),'w+');
fid_sigdet = fopen(fprint('%s/%s_coh_sigdet.eve',path,filename),'w+');
if fid_stim == -1 || fid_resp == -1
    error('Unable to open files for writing.');
end

% determine error rate
for n = 1:length(coherence_array)
    ER_condition = ER(cohVec == coherence_array(n));
    
    fprintf('Error rate for coherence %d = %0.3f\n', coherence_array(n), mean(ER_condition));
end

% save event file in following format:
%  <sample> <time> <from> <to> <text>
% needs to begin with "0 0 0 0" (see mne 2.7 manual, section 4.10.5).

% write the coherence event file
fprintf(fid_stim,'0\t0\t0\t0');
fprintf(fid_resp,'0\t0\t0\t0');
fprintf(fid_sigdet,'0\t0\t0\t0');

for n = 1:length(times.trig.onset)
    % only include correct trials in analysis
    if values.trig.err ~= 1
        fprintf(fid_stim, '%8i\t%5.3f\t%i\t%i\n', times.trig.onset(n),  times.trig.onset(n)/1000,  0, values.trig.coh(n), comments{values.trig.coh(n)});
        fprintf(fid_resp, '%8i\t%5.3f\t%i\t%i\n', times.trig.offset(n), times.trig.offset(n)/1000, 0, values.trig.coh(n), comments{values.trig.coh(n)});
    end
end

for n = 1:length(times.sigdet.onset)
    if values.sigdet.err ~= 1
        fprintf(fid_sigdet, '%8i\t%5.3f\t%i\t%i\n', times.sigdet.onset(n), times.sigdet.onset(n)/1000, 0, values.sigdet.dir(n), comments{values.sigdet.dir(n)});
    end
end

fclose(fid_stim);
fclose(fid_resp);


%% write comments to file indicating what the values mean

