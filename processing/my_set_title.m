function my_set_title(h, plotTitle, extra)

SetDefaultValue(3, 'extra', '');

% set figure name
figure(h);

if strlen(extra) > 0
    extra = [', ' extra];
end
title( sprintf( '%s%s', plotTitle, extra ) );

extra = input( 'Modify comment (leave blank if OK as is): ', 's' );
if strlen(extra) > 0
    title( sprintf( '%s, %s', plotTitle, extra ) );
end