function my_save_figure(h, save_name, save_path, varargin)
% 
%
% Save a given figure to matlab-files/figures with a user-defined title and
% filename
%

SetDefaultValue(3, 'save_path', pwd);

noninteract = keyval('noninteract',  varargin);	if isempty(noninteract),	noninteract = 'maxmin';     end

figure(h);

if noninteract
    save_figure = 'y';
else
    beep;
    save_figure = input( 'Save figure? (Y/n) ', 's' );
end

if ~strcmp( save_figure, 'n' )
    if ~exist( [save_path 'figures'], 'dir' )
        mkdir( save_path, 'figures' );
    end
    
    % get file name, ensure file doesn't already exist
    save_ok = 'n';
    while ~strcmp(save_ok, 'y')
        fprintf('Default save name: %s\n', save_name);
        
        if ~noninteract
            new_save_name = input( 'Input new file name (leave blank if OK as is): ', 's' );
            if strlen(new_save_name) > 0
                save_name = new_save_name;
            end
        end
        
        if exist( [save_path save_name], 'file' )
            if noninteract
                warning('File exists! Figure %02.0f not saved!', gcf);
                break;
            else
                save_ok = input( 'File exists! Overwrite? (y/N) ', 's' );
            end

            if ~strcmp( save_ok, 'y' )
                save_ok = 'n';
            end
        else
            save_ok = 'y';
        end
    end
    
    saveas( h, [save_path save_name], 'pdf' );
end