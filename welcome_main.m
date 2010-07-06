
function welcome_main()


% show some text with the dXtext class
% also a good way to find text that looks good on a particular screen

try
    lnsp = -1;

    str{1}= 'Now your task is to gain as many        ';
    str{2}= 'points as possible.                     ';
    str{3}= 'The experiment has a fixed duration. So ';
    str{4}= 'the faster you go, the more money you   ';
    str{5}= 'can make. It''s OK to be greedy!:)      ';
    str{6}= '(Press the ''Space'' key to continue.)  ';    
    
    [wn_, sr_, ppd_, fr_] = rGraphicsGetScreenAttributes;

    fontsize = 22;
    fontsize = 30;

    for i = 1:length(str)
        textwidth = fontsize*length(str{i})/ppd_;
        x_pos{i} = -0.3*textwidth;
    end

    % show a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', length(str), 'visible', true, ...
        'x', x_pos, 'y', {-3*lnsp -2*lnsp -1*lnsp 0*lnsp 1*lnsp 4*lnsp }, ...
        'size', fontsize, ...
        'font', 'Courier',  ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', str);

    spacekey = 44; % Only accept a space as the command to quit:
    [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);
    while KbCheckMulti
        WaitSecs(0.002);
    end

    
    rSet('dXtext',indices,'visible',false);
    rGraphicsDraw;
 
    str = {};
    x_pos = {};
    str{1} = 'Your task is to indicate the direction of the ';
    str{2} = 'motion or arrows (depending on the block) with';
    str{3} = 'Z for left';
    str{4} = 'M for right';
    str{9} = '(Press the ''Space'' key to continue.)';

    for i = 1:length(str)
        textwidth = fontsize*length(str{i})/ppd_;
        x_pos{i} = -0.3*textwidth;
    end

   y = -ceil(length(str)/2):floor(length(str)/2);
    if length(y)>length(str)
      y = y(1:length(str));
    end
    y = y*lnsp;    
    
    % shoe a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext',length(str), 'visible', true, ...
        'x', x_pos, 'y', num2cell(y), ...
        'size', fontsize, ...
        'font', 'Courier',  ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', str );

    spacekey = 44; % Only accept a space as the command to quit:
    [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);
    while KbCheckMulti
        WaitSecs(0.002);
    end

    rSet('dXtext',indices,'visible',false);
    rGraphicsDraw;
    str = {};
    x_pos = {};
    str{1} = 'When you score a point, you''ll hear a sound, and';
    str{2} = 'the circle or triangle will turn green. For an   ';
    str{3} = 'error it will turn red.                          ';
    str{4} = 'You''ll see your current score every 5 trials.   ';
    str{5} = '(Press the ''Space'' key to continue.)';

    for i = 1:length(str)
        textwidth = fontsize*length(str{i})/ppd_;
        x_pos{i} = -0.3*textwidth;
    end

    % show a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', 6, 'visible', true, ...
        'x', x_pos, 'y', { -1*lnsp 0*lnsp 1*lnsp 2*lnsp 5*lnsp }, ...
        'size', fontsize, ...
        'font', 'Courier',  ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', str );

%     rGraphicsDraw(inf)
    spacekey = 44; % Only accept a space as the command to quit:
    [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);
    while KbCheckMulti
        WaitSecs(0.002);
    end
    %     KbWait;

    rRemove('dXtext',indices);
%     rSet('dXtext',indices,'visible',false);
    rGraphicsDraw;
    %     rClear;
    

    str = {};
    x_pos = {};
    str{1} = 'Do whatever necessary to make as much money as';
    str{2} = 'possible.';
    str{3} = 'Z = left';
    str{4} = 'M = right';
    str{5} = '(Press the ''Space'' key to continue.)';


    for i = 1:length(str)
        textwidth = fontsize*length(str{i})/ppd_;
        x_pos{i} = -0.3*textwidth;
    end

    % shoe a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', length(str), 'visible', true, ...
        'x', x_pos, 'y', {  -1*lnsp 0*lnsp 1*lnsp 2*lnsp 5*lnsp }, ...
        'size', fontsize, ...
        'font', 'Courier',  ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', str );

    spacekey = 44; % Only accept a space as the command to quit:
    [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);
    while KbCheckMulti
        WaitSecs(0.002);
    end
    rSet('dXtext',indices,'visible',false);
    rGraphicsDraw;


  
catch
    e = lasterror
end


