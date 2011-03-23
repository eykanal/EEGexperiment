function data_clean = dots_ft_ica(data_preprocessed)

a = cell2mat(data_preprocessed.trial);

% reshape data, to simplify processing
b = reshape(a,[309 601 230]);
b_data = b(1:306,:,:);
b_shift = shiftdim(b_data,2);

% reshape data to form of time x (chan*trials); basically, it's one huge
% list of time series, irrespective of channel or trial number
c = reshape(b_shift,306*230,[]);
% rescale so ICA can work
c = c * 10e12;
c = c';

numOfIC = 40;

[icasig, A, W] = fastica(c, 'lastEig', 50, 'numOfIC', numOfIC, 'verbose', 'off');

% plot all ICs
figure(1)
for n = 1:numOfIC
    subplot(5,8,n);
    plot(A(:,n));
    axis([0 601 -50 50]);
    title(sprintf('%i',n));
end

% zero out noise channels
denoise_index = input('Enter noise components (if >1, surround with brackets): ');
denoise = ones(numOfIC);
denoise(:,denoise_index) = 0;

% reconstruct the signal
A_clean = A * denoise;
A_clean = A_clean * icasig;
% undo scale change
A_clean_reshape = A_clean' * 10e-12;
A_clean_reshape = reshape(A_clean_reshape, 230, 306, []);
% add back data channels (STI 101-103, MEG chans 307-309)
A_clean_reshape = shiftdim(A_clean_reshape,1);
A_clean_reshape = cat(1, A_clean_reshape, b(307:309,:,:));
A_clean_reshape = shiftdim(A_clean_reshape,2);

% put back into correct format for FT
data_clean = data_preprocessed;
for n = 1:230
    data_clean.trial(n) = {squeeze(A_clean_reshape(n,:,:))};
end

% plot the new data
figure();
cfg = [];
cfg.layout = 'neuromag306mag.lay';
ft_multiplotER(cfg, data_clean);