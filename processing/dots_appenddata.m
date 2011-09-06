for analyses = {'stim','resp'}
    for conds = {'preprocessed'}  % {'timelock', 'freq', 'tf'}
        
        analysis = analyses{:};
        cond = conds{:};
        
        % define filenames
        all = { ...
        sprintf('17-4-1-%s-%s-coh-20.mat', cond, analysis), ...
        sprintf('17-4-1-%s-%s-coh-6.mat',  cond, analysis), ...
        sprintf('17-4-1-%s-%s-coh-8.5.mat',cond, analysis), ...
        sprintf('17-4-2-%s-%s-coh-20.mat', cond, analysis), ...
        sprintf('17-4-2-%s-%s-coh-6.mat',  cond, analysis), ...
        sprintf('17-4-2-%s-%s-coh-8.5.mat',cond, analysis), ...
        sprintf('17-4-3-%s-%s-coh-20.mat', cond, analysis), ...
        sprintf('17-4-3-%s-%s-coh-8.5.mat',cond, analysis), ...
        sprintf('17-4-4-%s-%s-coh-20.mat', cond, analysis), ...
        sprintf('17-4-4-%s-%s-coh-8.5.mat',cond, analysis), ...
        sprintf('18-5-1-%s-%s-coh-12.mat', cond, analysis), ...
        sprintf('18-5-1-%s-%s-coh-25.mat', cond, analysis), ...
        sprintf('18-5-1-%s-%s-coh-7.mat',  cond, analysis), ...
        sprintf('18-6-1-%s-%s-coh-12.mat', cond, analysis), ...
        sprintf('18-6-1-%s-%s-coh-25.mat', cond, analysis), ...
        sprintf('18-6-1-%s-%s-coh-7.mat',  cond, analysis), ...
        sprintf('18-6-2-%s-%s-coh-12.mat', cond, analysis), ...
        sprintf('18-6-2-%s-%s-coh-25.mat', cond, analysis), ...
        sprintf('18-6-2-%s-%s-coh-7.mat',  cond, analysis), ...
        sprintf('18-6-3-%s-%s-coh-12.mat', cond, analysis), ...
        sprintf('18-6-3-%s-%s-coh-25.mat', cond, analysis), ...
        sprintf('18-6-3-%s-%s-coh-7.mat',  cond, analysis), ...
        sprintf('19-6-1-%s-%s-coh-15.mat', cond, analysis), ...
        sprintf('19-6-1-%s-%s-coh-25.mat', cond, analysis), ...
        sprintf('19-6-1-%s-%s-coh-8.mat',  cond, analysis), ...
        sprintf('19-6-2-%s-%s-coh-15.mat', cond, analysis), ...
        sprintf('19-6-2-%s-%s-coh-25.mat', cond, analysis), ...
        sprintf('19-6-2-%s-%s-coh-8.mat',  cond, analysis), ...
        sprintf('19-6-3-%s-%s-coh-15.mat', cond, analysis), ...
        sprintf('19-6-3-%s-%s-coh-25.mat', cond, analysis), ...
        sprintf('19-6-3-%s-%s-coh-8.mat',  cond, analysis), ...
        };

        high = findSubset(all, '-(20|25)\.mat');
        mid  = findSubset(all, '-(8.5|12|15)\.mat');
        low  = findSubset(all, '-(6|7|8)\.mat');

        sub17 = findSubset(all, '17-');
        sub18 = findSubset(all, '18-');
        sub19 = findSubset(all, '19-');
    
        sub17h = intersect(sub17, high);
        sub17m = intersect(sub17, mid);
        sub17l = intersect(sub17, low);
        sub18h = intersect(sub18, high);
        sub18m = intersect(sub18, mid);
        sub18l = intersect(sub18, low);
        sub19h = intersect(sub19, high);
        sub19m = intersect(sub19, mid);
        sub19l = intersect(sub19, low);
        
        for subjNum = 17:19
            for difficulty = ['h','m','l']
                
                subset = eval(['sub' num2str(subjNum) difficulty]);
                data = [];
                
                for numSess = 1:length(subset)
                    tmp = load(subset{numSess});
                    if strcmp(cond,'timelock')
                        data(numSess).data_timelock     = tmp.data_timelock;
                    elseif strcmp(cond,'freq')
                        data(numSess).data_freq         = tmp.data_freq;
                    elseif strcmp(cond,'tf')
                        data(numSess).data_freq_varWind = tmp.data_freq_varWind;
                    elseif strcmp(cond,'preprocessed')
                        data(numSess).data_preprocessed = tmp.data_preprocessed;
                    else
                        error('Cond not recognized.')
                    end
                    clear tmp;
                end
                
                path = fileparts(which(subset{numSess}));
                
                filename = sprintf('%i-%s-%s-coh-%s', subjNum, cond, analysis, difficulty);
                if strcmp(cond,'timelock')
                    data_timelock     = ft_appenddata([], data(:).data_timelock);
                    save([path '/' filename], 'data_timelock');
                elseif strcmp(cond,'freq')
                    data_freq         = ft_appendfreq([], data(:).data_freq);
                    save([path '/' filename], 'data_freq');
                elseif strcmp(cond,'tf')
                    data_freq_varWind = ft_appendfreq([], data(:).data_freq_varWind);
                    save([path '/' filename], 'data_freq_varWind');
                elseif strcmp(cond,'preprocessed')
                    data_preprocessed = ft_appenddata([], data(:).data_preprocessed);
                    save
                else
                    error('Cond not recognized.')
                end
                
            end
        end
    end
end