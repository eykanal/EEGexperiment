function my_set_title(h, plotTitle, extra)

% set figure name
figure(h);

title( sprintf( '%s, %s', plotTitle, extra ) );

extra = input( 'Modify comment (leave blank if OK as is): ', 's' );
if strlen(extra) > 0
    title( sprintf( '%s, %s', plotTitle, extra ) );
end