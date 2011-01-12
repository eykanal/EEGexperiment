function varargout = ParallelTest

    % clear out old temp directories
    dirs = dir('/tmp');
    if ~isempty(dirs)
        for n = 1:length(dirs)
            if dirs(n).isdir == 1 && length( dirs(n).name ) > 1 && strcmp( dirs(n).name(1:2), 'tr' )
                temp_dir = sprintf( '/tmp/%s', dirs(n).name );
                unix( sprintf( 'rm -R %s',temp_dir ) );
                rmpath( temp_dir );
            end
        end
    end

    % put empty file in /tmp so I can check for it
    ptr = fopen( '/tmp/resp.txt', 'w' );
    fclose( ptr );
    
    obj = createJob();
    % Add psychtoolbox to worker path
    set( obj, 'FileDependencies', {'jobStartup.m', 'GetPadResp.m'});

    task = createTask(obj, @GetPadResp, 1, {4});
    alltasks = get(obj, 'Tasks');
    set(alltasks, 'CaptureCommandWindowOutput', true);
    
    submit(obj);                   % Submit the job
    waitForState(task,'running');  % Wait for the task to start running
    disp('Starting!');
    
    a = GetSecs;
    get(task,'State');
    time = GetSecs-a;
    disp(time);
    
    while ~strcmp(get(task,'State'),'finished')  % Loop while the task is running
        resp = csvread( '/tmp/resp.txt' );

        if ~isempty( resp )
            disp( KbName( resp(3) ) );
            ptr = fopen( '/tmp/resp.txt', 'w' );
            fclose( ptr );
        end
    end

    varargout = get(task,'OutputArguments');  % Get the outputs from the task
    
    % troubleshooting!
    if isempty(varargout)
        disp( '## Error!' );
        err = get(task, 'Error');
        disp(err.message);

        for n = 1:length(err.cause);
            disp(err.cause{n}.message);
        end
    end
        
    destroy(obj);  % Remove the job from memory

    function string = getString( task )
        string = [];
        data = get( task, 'OutputArguments' );
        
        if iscell( data )
            data = cell2struct( data, {'data'}, 1 );
            data = data.data;
        end
        
        for n = 1:length(data)
            string = [ string KbName(data(n).keyCode) ];
        end
    end
    
end