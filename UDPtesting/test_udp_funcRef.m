% set up UDP connection
localIP = '10.1.1.2';
remoteIP = '10.1.1.3';
port = 6665;
u = udp(remoteIP, port);
fopen(u);

% turn of Screen
fprintf(u,'rDone')

behavioral = 0;
frank = 'AIEEE!';
% set immediate data
myCell={@strcat,'bob','joe', 'jim', 'jay','frank'};

fprintf(u,'joe=''AIEEE'';');
execute_code( behavioral, u, myCell, 'myVar' );

fprintf(u,'disp(myVar)');