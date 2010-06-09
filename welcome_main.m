function welcome_main()

% pull in vars from global space
Behavioral  = evalin('caller','Behavioral');
u           = evalin('caller','u');
parport     = evalin('caller','parport');

str{1}{1}= 'Now your task is to gain as many';
str{1}{2}= 'points as possible.';
str{1}{3}= 'The experiment has a fixed duration. So';
str{1}{4}= 'the faster you go, the more money you';
str{1}{5}= 'can make. It''s OK to be greedy! :)';
str{1}{6}= '(Press the ''Space'' key to continue.)';    

str{2}{1} = 'Your task is to indicate the direction of the';
str{2}{2} = 'motion or arrows (depending on the block), using:';
str{2}{3} = 'Z for left';
str{2}{4} = 'M for right';
str{2}{5} = '';
str{2}{6} = '(Press the ''Space'' key to continue.)';

str{3}{1} = 'When you score a point, you''ll hear a sound, and';
str{3}{2} = 'the circle or triangle will turn green. For an';
str{3}{3} = 'error it will turn red.';
str{3}{4} = 'You''ll see your current score every 5 trials.';
str{3}{5} = '';
str{3}{6} = '(Press the ''Space'' key to continue.)';

str{4}{1} = 'Do whatever necessary to make as much money as';
str{4}{2} = 'possible.';
str{4}{3} = 'Z = left';
str{4}{4} = 'M = right';
str{4}{5} = '';
str{4}{6} = '(Press the ''Space'' key to continue.)';

[wn_, sr_, ppd_, fr_] = rGraphicsGetScreenAttributes;

fontsize = 30;
lnsp = -1;

for n = 1:length(str)
    x_pos = cell(size(str{n}));
    
    for i = 1:length(str{n})
        textwidth = fontsize*length(str{n}{i})/ppd_;
        x_pos{i} = -0.3*textwidth;
        
    end

    % show a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', length(str{n}), 'visible', true, ...
        'x', x_pos, 'y', {-3*lnsp -2*lnsp -1*lnsp 0*lnsp 1*lnsp 4*lnsp }, ...
        'size', fontsize, ...
        'font', 'Courier',  ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', str{n});

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
end
