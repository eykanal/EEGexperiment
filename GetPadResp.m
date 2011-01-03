function keys = GetPadResp( deviceNumber )

keys = struct;
a = GetSecs;

while 1
    % Check the state of the keyboard.
    [ keyIsDown, secs, keyCode ] = KbCheck( deviceNumber );

    % If the user is pressing a key, then display its code number and name.
    if keyIsDown == 1
        ptr = fopen( '/tmp/resp.txt', 'w' );
        fprintf( ptr, '1,%1.4e,%i', secs, find( keyCode ) );
        fclose( ptr );
            
        while KbCheck; end  % wait for keys to be released
    end
end   


end