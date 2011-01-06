function keys = GetPadResp( deviceNumber )

% define global daq value for the KbCheckMulti script
global daq;
daq = deviceNumber;

keys = struct;

while 1
    % Check the state of the keyboard.
    [ keyIsDown, secs, keyCode ] = KbCheckMulti( deviceNumber );

    % If the user is pressing a key, then display its code number and name.
    if keyIsDown == 1
        ptr = fopen( '/tmp/resp.txt', 'w' );
        fprintf( ptr, '1,%1.3f,%i', secs, find( keyCode ) );
        fclose( ptr );
            
        while KbCheckMulti; end  % wait for keys to be released
    end
end

end