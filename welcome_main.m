
function welcome_main()

% show some text with the dXtext class
% also a good way to find text that looks good on a particular screen

strings{1}{1} = 'Now your task is to gain as many points';
strings{1}{2} = 'as possible. The experiment has a fixed';
strings{1}{3} = 'duration, so the faster you go, the more';
strings{1}{4} = 'money you can make. It''s OK to be greedy!';
strings{1}{5} = '';
strings{1}{6} = '(Press the ''Space'' key to continue.)  ';    

strings{2}{1} = 'Your task is to indicate the direction of the';
strings{2}{2} = 'motion or arrows (depending on the block) with';
strings{2}{3} = 'Z for left ';
strings{2}{4} = 'M for right';
strings{2}{5} = '';
strings{2}{6} = '(Press the ''Space'' key to continue.)';

strings{3}{1} = 'When you score a point, you''ll hear a';
strings{3}{2} = 'sound, and the circle or triangle will';
strings{3}{3} = 'turn green. For an error it will turn';
strings{3}{4} = 'red. You''ll see your current score every';
strings{3}{5} = '5 trials.';
strings{3}{6} = '';
strings{3}{7} = '(Press the ''Space'' key to continue.)';

strings{4}{1} = 'Do whatever necessary to make as much money';
strings{4}{2} = 'as possible.';
strings{4}{3} = 'Z = left ';
strings{4}{4} = 'M = right';
strings{4}{5} = '';
strings{4}{6} = '(Press the ''Space'' key to continue.)';

[wn_, sr_, ppd_, fr_] = rGraphicsGetScreenAttributes;
font_degrees = 0.7;
fontsize = floor(font_degrees * ppd_);

% display each instruction set
for n = 1:length(strings)
    str   = [];
    x_pos = [];
    y_pos = [];

    str = strings{n};
    
    for i = 1:length(str)
        textwidth = fontsize * length(str{i})/ppd_;
        x_pos{i}  = -0.3 * textwidth;
    end
    
    % Equally distribute lines in middle of screen
    y_pos = font_degrees * (length(str):-1:1) - (floor(length(str)/2));
    y_pos = num2cell(y_pos);
    
    indices = rAdd( ...
        'dXtext',   length(str), ...
        'visible',  true, ...
        'x',        x_pos, ...
        'y',        y_pos, ...
        'size',     fontsize, ...
        'font',     'Courier',  ...
        'bold',     true, ...
        'color',    [1 1 1]*255, ...
        'string',   str);

    spacekey = 44;  % Only accept a space as the command to quit:
    [ keySecs, myKeyCode ] = rGraphicsDrawSelectiveBreakMulti(inf,[],spacekey);

    while KbCheckMulti
        WaitSecs(0.002);
    end

    rSet('dXtext',indices,'visible',false);
    rGraphicsDraw;
end
