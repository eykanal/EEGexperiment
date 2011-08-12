% This script takes the cleaned trials (i.e., all noisy trials removed)
% from the resp datasets, finds their trigger times, finds the
% corresponding stim times, and makes new preprocessed files based on them.

all = { ...
'17-4-1-preprocessed-resp-coh-20.mat', ...
'17-4-1-preprocessed-resp-coh-6.mat', ...
'17-4-1-preprocessed-resp-coh-8.5.mat', ...
'17-4-2-preprocessed-resp-coh-20.mat', ...
'17-4-2-preprocessed-resp-coh-6.mat', ...
'17-4-2-preprocessed-resp-coh-8.5.mat', ...
'17-4-3-preprocessed-resp-coh-20.mat', ...
'17-4-3-preprocessed-resp-coh-8.5.mat', ...
'17-4-4-preprocessed-resp-coh-20.mat', ...
'17-4-4-preprocessed-resp-coh-8.5.mat', ...
'18-5-1-preprocessed-resp-coh-12.mat', ...
'18-5-1-preprocessed-resp-coh-25.mat', ...
'18-5-1-preprocessed-resp-coh-7.mat', ...
'18-6-1-preprocessed-resp-coh-12.mat', ...
'18-6-1-preprocessed-resp-coh-25.mat', ...
'18-6-1-preprocessed-resp-coh-7.mat', ...
'18-6-2-preprocessed-resp-coh-12.mat', ...
'18-6-2-preprocessed-resp-coh-25.mat', ...
'18-6-2-preprocessed-resp-coh-7.mat', ...
'18-6-3-preprocessed-resp-coh-12.mat', ...
'18-6-3-preprocessed-resp-coh-25.mat', ...
'18-6-3-preprocessed-resp-coh-7.mat', ...
'19-6-1-preprocessed-resp-coh-15.mat', ...
'19-6-1-preprocessed-resp-coh-25.mat', ...
'19-6-1-preprocessed-resp-coh-8.mat', ...
'19-6-2-preprocessed-resp-coh-15.mat', ...
'19-6-2-preprocessed-resp-coh-25.mat', ...
'19-6-2-preprocessed-resp-coh-8.mat', ...
'19-6-3-preprocessed-resp-coh-15.mat', ...
'19-6-3-preprocessed-resp-coh-25.mat', ...
'19-6-3-preprocessed-resp-coh-8.mat', ...
};

high = findSubset(all, '-(20|25)\.mat');
mid  = findSubset(all, '-(8.5|12|15)\.mat');
low  = findSubset(all, '-(6|7|8)\.mat');

for n=1:length(all)
    dataset = all{n};

    % load preprocessed dataset
    load(dataset);

    % get filename
    cfg = [];
    cfg.dataset = data_preprocessed.hdr.orig.raw.info.filename;
    
    % get resp trial times
    resp_trials = [data_preprocessed.sampleinfo repmat(-1000,size(data_preprocessed.sampleinfo,1),1)];
    resp_trigger_times = resp_trials(:,1)+1000;
    
    % Find triggers on STI101 channel
    hdr     = fiff_setup_read_raw( cfg.dataset );
    picks   = fiff_pick_types( hdr.info, false, false, false, {'STI101'} );
    trig    = fiff_read_raw_segment( hdr, hdr.first_samp, hdr.last_samp, picks );

    % Fix so each pulse is exactly 1 ms long
    trig(trig > 0 & [0 diff(trig)] <= 0) = 0;

    data.values     = trig(trig>0);
    data.times.raw  = find(trig>0);

    % Time of trigger pulse in ms, including initial skip
    data.times.stim = data.times.raw(data.values == 1);
    data.times.resp = data.times.raw(data.values == 2);

    % Find stim equivalent of trial times from resp preprocessed dataset
    stim_trigger_times = data.times.stim(ismember(data.times.resp, resp_trigger_times))';
    
    cfg.trl     = [stim_trigger_times-500 stim_trigger_times+1000 repmat(-500,size(stim_trigger_times,1),1)];
    cfg.hdr     = data_preprocessed.hdr;
    clear data_preprocessed;

    % remove line noise, low freq oscillations
    % use cfg.dataset, cfg.trl, and cfg.hdr defined above
    cfg.hpfilter        = 'yes';
    cfg.hpfreq          = 1;
    cfg.dftfilter       = 'yes';
    cfg.dftfreq         = [60 120];
    data_preprocessed   = ft_preprocessing(cfg);

    % scale down gradiometers
    grads               = regexp(data_preprocessed.label, 'MEG\d{3}[23]');  % find them
    grads               = ~(cellfun(@isempty, grads));  % convert from cell to bool

    for n = 1:length(data_preprocessed.trial)
        % ## Eventually, determine variance of mags, grads, 
        % ## scale grads in proportion to difference between
        % ## variances. For now, just scale down to 5% of
        % ## original.

        data_preprocessed.trial{n}(grads, :) = data_preprocessed.trial{n}(grads, :)*0.05;
    end

    % save newly preprocessed data
    path    = fileparts(which(dataset));
    tokens  = regexp(dataset,'(\d{2})-(\d)-(\d)-preprocessed-resp-coh-(\d{1,2}\.?\d?)\.mat','tokens');
    tokens  = tokens{1};
    save([path '/' sprintf('%s-%s-%s-preprocessed-stim-coh-%s.mat',tokens{1},tokens{2},tokens{3},tokens{4})], 'data_preprocessed');
end

% run TFR, save, plot, save
disp('Don''t forget to run a modified `dots_stimCompleteAnalysis` to run over the `stim` datasets!');

