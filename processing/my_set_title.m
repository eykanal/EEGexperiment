function my_set_title(h, plotTitle, extra, varargin)

SetDefaultValue(3, 'extra', '');
askextra    = keyval('askextra',    varargin); if isempty(askextra),    askextra = 1;          end

% set figure name
figure(h);

if strlen(extra) > 0
    extra = [', ' extra];
end
title( sprintf( '%s%s', plotTitle, extra ) );

if askextra
    extra = input( 'Modify comment (leave blank if OK as is): ', 's' );
    if strlen(extra) > 0
        title( sprintf( '%s, %s', plotTitle, extra ) );
    end
end