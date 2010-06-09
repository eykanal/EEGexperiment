function welcome_quest()

try
    % pull in vars from global space
    Behavioral  = evalin('caller','Behavioral');
    u           = evalin('caller','u');
    parport     = evalin('caller','parport');
    
    % first instruction screen
    lnsp = -1;  
    str = {};
    x_pos = {};
    str{1} = 'Welcome';
    str{2} = 'In every trial, you are supposed to press the Z key'; 
    str{3} = 'representing "Left", or else the M key, for "Right".';
    str{4} = 'In every trial, you will see dots moving on the';
    str{5} = 'screen. Most will jump randomly, but some will move';
    str{6} = 'to the left or to the right. You will earn a';
    str{7} = 'point by pressing Z for leftward dot-motion, and M for';
    str{8} = 'rightward dot-motion. ';
    str{9} = 'In these first trials, try to be as accurate as';
    str{10} = 'possible, yet press the keys as soon as you have';
    str{11} = 'your response';
    str{12} = '(Press the ''Space'' key to continue.)';

    if Behavioral
        [wn_, sr_, ppd_, fr_] = rGraphicsGetScreenAttributes;
    end
    
    xres = sr_(3);
    yres = sr_(4);

    fontsize = 30;    

    for i = 1:length(str)
        textwidth = fontsize*length(str{i})/ppd_;
        x_pos{i} = -0.3*textwidth;
    end

    y = -ceil(length(str)/2):floor(length(str)/2);
    if length(y)>length(str)
        y = y(1:length(str));
    end
    y = y*lnsp;

    args = {@rAdd, ...
        'dXtext', length(str), ...
        'visible', true, ...
        'x', x_pos, 'y', num2cell(y), ...
        'size', fontsize, ...
        'font', 'Courier', ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', str };
    execute_code(Behavioral,args,u,'indices');
    
    if Behavioral
        spacekey = 44;
        [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);
        while KbCheckMulti
            WaitSecs(0.002);
        end
    else
        get_pads_response( parport );
    end
    
    args = { @rSet,'dXtext',indices,'visible',false};
    execute_code( Behavioral, args, u );
    args = { @rGraphicsDraw };
    execute_code( Behavioral, args, u );

    % second instruction screen
    str = {};
    x_pos = {};
    str{1} = 'When you score a point, you''ll hear a sound, and';
    str{2} = 'you''ll see your current score every 5 trials.';
    str{3} = '(Press the ''Space'' key to continue.)';

    for i = 1:length(str)
        textwidth = fontsize*length(str{i})/ppd_;
        x_pos{i} = -0.3*textwidth;
    end

    args = {@rAdd, ...
        'dXtext', length(str), 'visible', true, ...
        'x', x_pos, 'y', { -1*lnsp 0*lnsp 5*lnsp }, ...
        'size', fontsize, ...
        'font', 'Courier',  ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', str };
    execute_code(Behavioral,args,u,'indices');
    
    if Behavioral
        spacekey = 44;
        [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);
        while KbCheckMulti
            WaitSecs(0.002);
        end
    else
        get_pads_response( parport );
    end
    
    args = { @rSet,'dXtext',indices,'visible',false};
    execute_code( Behavioral, args, u );
    args = { @rGraphicsDraw };
    execute_code( Behavioral, args, u );

    % third instruction screen
    str = {};
    x_pos = {};
    str{1} = 'Also, please try to keep your';
    str{2} = 'head the same distance from the screen at all times';
    str{3} = 'with your gaze centered on the middle of the screen.';
    str{4} = '(Press the ''Space'' key to continue.)';

    for i = 1:length(str)
        textwidth = fontsize*length(str{i})/ppd_;
        x_pos{i} = -0.3*textwidth;

    end

    args = {@rAdd, ...
        'dXtext', length(str), 'visible', true, ...
        'x', x_pos, 'y', {  -1*lnsp 0*lnsp 1*lnsp 5*lnsp }, ...
        'size', fontsize, ...
        'font', 'Courier',  ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', str };
    execute_code(Behavioral,args,u,'indices');

    if Behavioral
        spacekey = 44;
        [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);
        while KbCheckMulti
            WaitSecs(0.002);
        end
    else
        get_pads_response( parport );
    end
    
    args = { @rSet,'dXtext',indices,'visible',false};
    execute_code( Behavioral, args, u );
    args = { @rGraphicsDraw };
    execute_code( Behavioral, args, u );

    % fourth instruction screen
    str = {};
    x_pos = {};
    str{1} = 'Try not to press';
    str{2} = 'a key before fixation turns blue -- this will delay';
    str{3} = 'the dots from appearing, and you will hear a buzzing sound.';
    str{4} = 'Press the "Space" key when you are ready to play.';

    for i = 1:length(str)
        textwidth = fontsize*length(str{i})/ppd_;
        x_pos{i} = -0.3*textwidth;

    end

    args = { @rAdd, ...
        'dXtext', length(str), 'visible', true, ...
        'x', x_pos, 'y', {  -1*lnsp 0*lnsp 1*lnsp 5*lnsp }, ...
        'size', fontsize, ...
        'font', 'Courier',  ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', str };
    execute_code(Behavioral,args,u,'indices');

    if Behavioral
        spacekey = 44;
        [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);
        while KbCheckMulti
            WaitSecs(0.002);
        end
    else
        get_pads_response( parport );
    end

    args = { @rSet,'dXtext',indices,'visible',false};
    execute_code( Behavioral, args, u );
    args = { @rGraphicsDraw };
    execute_code( Behavioral, args, u );

catch
    e = lasterror;
end


