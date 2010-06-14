
function demoText_Pat3();

% show some text with the dXtext class
% also a good way to find text that looks good on a particular screen

try
%     rInit('local')

    %     % dXscreen sets the Screen('TextBackgroundColor', ...) to match
    %     %   (for all the good it does)
    %     rSet('dXscreen', 1, 'bgColor', 0.31555);

    %     % shoe a normal text, and
    %     %   try to make another that looks good on mono++
    %     rAdd('dXtext', 2, 'visible', true, ...
    %         'x', -10, 'y', { 0 0.25 }, ...
    %         'size', 22, ...
    %         'font', 'Courier',  ...
    %         'bold', true, ...
    %         'color', {[1 1 1]*255, [1 1 0]*255}, ...
    %         'string', {'I look bad on mono++', 'I look better'});


    lnsp = -1;
    str{1} = 'Welcome to the Experiment!';
    str{2} = 'Your task is to gain as many points as possible';
    str{3} = 'during the experiment. The experiment will last';
    str{4} = 'about an hour no matter what, so the faster you';
    str{5} = 'go, the more chances you will have to score';
    str{6} = 'points and make money. We are interested in how';
    str{7} = 'people behave when they are trying to earn the';
    str{8} = 'most reward possible. It''s OK to be greedy! :)';
    str{9} = '(Press the ''Space'' key to continue.)';


    [wn_, sr_, ppd_, fr_] = rGraphicsGetScreenAttributes;
    xres = sr_(3);
    yres = sr_(4);

    fontsize = 22;
    fontsize = 30;

    for i = 1:9
        textwidth = fontsize*length(str{i})/ppd_;
%         x_pos{i} = -textwidth/pi;
        x_pos{i} = -0.3*textwidth;

    end

    % shoe a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', 9, 'visible', true, ...
        'x', x_pos, 'y', { -6*lnsp -4*lnsp -3*lnsp -2*lnsp -1*lnsp 0*lnsp 1*lnsp 2*lnsp 5*lnsp }, ...
        'size', fontsize, ...
        'font', 'Courier',  ...
        'bold', true, ...
        'color', [1 1 1]*255, ...
        'string', { 'Welcome to the Experiment!', ...
        'Your task is to gain as many points as possible', ...
        'during the experiment. The experiment will last', ...
        'about an hour no matter what, so the faster you', ...
        'go, the more chances you will have to score', ...
        'points and make money. We are interested in how', ...
        'people behave when they are trying to earn the', ...
        'most reward possible. It''s OK to be greedy! :)', ...
        '(Press the ''Space'' key to continue.)'} );

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

    %     % Trying out a method for writing text into the current screen, but
    %     % making it invisible, in order to get its width in pixels.
    % %     w = rGet('dXscreen','windowNumber')
    %     global ROOT_STRUCT;
    %     w = ROOT_STRUCT.windowNumber;
    %     str = 'fred';
    % %     Screen(w,'TextFont','Arial');
    % %     Screen(w,'TextSize',22);
    % %     Screen(w,'TextStyle',1); % 0=plain (default for new window), 1=bold, etc.
    %     bounds = TextBounds(w,str)
    %



%     str{1} = 'At each trial, you will see dots moving on the';
%     str{2} = 'screen. Most will jump randomly, but some will';
%     str{3} = 'move to the left or to the right. If you press';
%     str{4} = 'the Z key when they are moving left, you will';
%     str{5} = 'score a point and earn a penny. If you press';
%     str{6} = 'the M key when they are moving right, you will';
%     str{7} = 'score a point. Otherwise you won''t score a point,';
%     str{8} = 'but you won''t lose any points for errors.';
%     str{9} = '(Press the ''Space'' key to continue.)';
    
%     str = {};
%     x_pos = {};
%     str{1} = 'The experiment involves multiple blocks of trials.';
%     str{2} = 'In every trial, you are supposed to press the Z key'; 
%     str{3} = 'representing "Left", or else the M key, for "Right".';
%     str{4} = 'In every trial, you will see dots moving on the';
%     str{5} = 'screen. Most will jump randomly, but some will move';
%     str{6} = 'to the left or to the right. In some blocks, the dots';
%     str{7} = 'will always be followed by an arrow. We will warn you';
%     str{8} = 'before the block starts if there will be arrows or not.';
%     str{9} = 'If you are in a no-arrow block, then you will earn a';
%     str{10} = 'point by pressing Z for leftward dot-motion, and M for';
%     str{11} = 'rightward dot-motion. In arrow blocks, dot motion is';
%     str{12} = 'irrelevant, and you earn points by pressing Z for left-';
%     str{13} = 'pointing arrows and M for right-pointing arrows.';
%     str{14} = '(Press the ''Space'' key to continue.)';

    str = {};
    x_pos = {};
    str{1} = 'The experiment involves multiple blocks of trials.';
    str{2} = 'In every trial, you will see dots moving on the';
    str{3} = 'screen. Most will jump randomly, but some will move';
    str{4} = 'to the left or to the right. If there is a CIRCLE in';
    str{5} = 'the middle of the screen, your task is to press ''Z''';
    str{6} = 'for leftward motion and ''M'' for rightward motion.';
    str{7} = 'If instead there is a TRIANGLE on the screen,';
    str{8} = 'then you should ignore the dots and wait until an';
    str{9} = 'arrow appears. If it points left, press ''Z'', and if';
    str{10} = 'it points right, press ''M''.';
    str{11} = 'You will earn 1 point for every correct answer.';
    str{12} = '(Press the ''Space'' key to continue.)';

    for i = 1:12
        textwidth = fontsize*length(str{i})/ppd_;
%         x_pos{i} = -textwidth/pi;
        x_pos{i} = -0.3*textwidth;

    end

    % shoe a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', 12, 'visible', true, ...
        'x', x_pos, 'y', { -7*lnsp -6*lnsp -5*lnsp -4*lnsp -3*lnsp -2*lnsp 0*lnsp 1*lnsp 2*lnsp 3*lnsp 4*lnsp 6*lnsp }, ...
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
    str{1} = 'When you score a point, you''ll hear a sound, and';
    str{2} = 'the circle or triangle will turn green. When you ';
    str{3} = 'make an error, it will turn red, and you will not ';
    str{4} = 'hear any sound.';
    str{5} = 'You''ll see your current score every 5 trials.';
    str{6} = '(Press the ''Space'' key to continue.)';

    for i = 1:6
        textwidth = fontsize*length(str{i})/ppd_;
%         x_pos{i} = -textwidth/pi;
        x_pos{i} = -0.3*textwidth;
    end

    % shoe a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', 6, 'visible', true, ...
        'x', x_pos, 'y', { -2*lnsp -1*lnsp 0*lnsp 1*lnsp 2*lnsp 5*lnsp }, ...
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
    str{1} = 'You can do the task however you want to do it in';
    str{2} = 'order to make the most possible money, but please';
    str{3} = 'press the Z key (for "left") with your left index';
    str{4} = 'finger, and the M key (for "right") with your';
    str{5} = 'right index finger.';
    str{6} = '(Press the ''Space'' key to continue.)';


    for i = 1:6
        textwidth = fontsize*length(str{i})/ppd_;
%         x_pos{i} = -textwidth/pi;
        x_pos{i} = -0.3*textwidth;
    end

    % shoe a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', 6, 'visible', true, ...
        'x', x_pos, 'y', { -2*lnsp -1*lnsp 0*lnsp 1*lnsp 2*lnsp 5*lnsp }, ...
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



    str = {};
    x_pos = {};
    str{1} = 'Also, please try to keep your';
    str{2} = 'head the same distance from the screen at all times';
    str{3} = 'with your gaze centered on the middle of the screen.';
    str{4} = '(Press the ''Space'' key to continue.)';

    for i = 1:4
        textwidth = fontsize*length(str{i})/ppd_;
%         x_pos{i} = -textwidth/pi;
        x_pos{i} = -0.3*textwidth;

    end

    % shoe a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', 4, 'visible', true, ...
        'x', x_pos, 'y', {  -1*lnsp 0*lnsp 1*lnsp 5*lnsp }, ...
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
    str{1} = 'In order to make the most money, try not to press';
    str{2} = 'a key before you see any dots -- this will delay';
    str{3} = 'the dots from appearing, and you will hear a buzzing sound.';
    str{4} = 'Press the "Space" key when you are ready to play.';

    for i = 1:4
        textwidth = fontsize*length(str{i})/ppd_;
%         x_pos{i} = -textwidth/pi;
        x_pos{i} = -0.3*textwidth;

    end

    % shoe a normal text, and
    %   try to make another that looks good on mono++
    indices = rAdd('dXtext', 4, 'visible', true, ...
        'x', x_pos, 'y', {  -1*lnsp 0*lnsp 1*lnsp 5*lnsp }, ...
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
%     rGraphicsBlank;

catch
    e = lasterror
end
% rDone

% keyboard

