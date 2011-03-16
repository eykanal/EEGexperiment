function trainingIntro()
%
% Display instructions about the task, describe how the practice and the
% actual task behave.
%

%## test with rInit('local') and rDone as in demoDots6.m

% Initialize dot motion
blackTargetIdx  = rAdd( ...
    'dXtarget', 2, ...
    'color',    [0 0 0], ...
    'penWidth', 24, ...
    'diameter', 2, ...
    'visible',  false, ...
    'x',        {-7,7}, ...
    'y',        {-4,-4});
targetIdx       = rAdd( ...
    'dXtarget', 2, ...
    'color',    [255 255 255], ...
    'penWidth', 24, ...
    'diameter', .5, ...
    'visible',  false, ...
    'x',        {-7,7}, ...
    'y',        {-4,-4});
dotsIdx         = rAdd( ...
    'dXdots',   2, ...
    'color',    [255 255 255], ...
    'direction',{180 0}, ...
    'coherence',25, ...
    'diameter', 6, ...
    'size',     5, ...
    'loops',    3, ...
    'density',  20, ...
    'speed',    7, ...
    'lifetimeMode', 'random', ...
    'visible',  false, ...
    'x',        {-7,7}, ...
    'y',        {-4,-4});

% Show text instructions
str = {};
str{1} = 'In every trial, you will see dots moving';
str{2} = 'on the screen. Most will jump randomly,';
str{3} = 'but some will move to the left or to the';
str{4} = 'right. An example of this is shown on the';
str{5} = 'next screen.';
str{7} = '';
str{8} = '(Press the ''Space'' key to continue.)';
showText(str);


str = {};
str{1} = 'The left and right displays below show dot';
str{2} = 'motion to the left and right, respectively.';
str{3} = 'Note that while many dots are moving at random,';
str{4} = 'enough are moving to a single direction to give';
str{5} = 'the appearance of directional motion. This type';
str{6} = 'of motion is what you will be looking for.';
str{7} = '';
str{8} = '(Press the ''Space'' key to continue.)';
rSet('dXtarget',    blackTargetIdx, 'visible',  true);
rSet('dXtarget',    targetIdx,      'visible',  true);
rSet('dXdots',      dotsIdx,        'visible',  true);
showText(str,0,-5);

str = {};
str{1} = 'In some trials, the motion direction will be';
str{2} = 'very easy to detect. In other trials, the motion';
str{3} = 'will be very subtle. With practice, you will';
str{4} = 'become more skilled at detecting even very subtle';
str{5} = 'changes in motion. In both displays below, the';
str{6} = 'dots are moving right.';
str{7} = '';
str{8} = '(Press the ''Space'' key to continue.)';
rSet('dXdots',      dotsIdx,        'coherence',{25,5});
rSet('dXdots',      dotsIdx,        'direction',0);
showText(str,0,-5);
rSet('dXtarget',    blackTargetIdx, 'visible',  false);
rSet('dXtarget',    targetIdx,      'visible',  false);
rSet('dXdots',      dotsIdx,        'visible',  false);

str = {};
str{1} = 'For this first part of the training, you';
str{2} = 'will be shown a dots pattern for 0.5 seconds.';
str{3} = 'When the fixation dot turns blue, you should';
str{4} = 'respond based on what direction you think';
str{5} = 'the dots were moving. Try to respond as';
str{6} = 'quickly as possible, while being as and as';
str{7} = 'accurate as you can.';
str{8} = '';
str{9} = '(Press the ''Space'' key to continue.)';
showText(str);

str = {};
str{1} = 'Some things to know:                            ';
str{2} = '- Respond with M (rightward motion) and Z       ';
str{3} = '  (leftward motion)                             ';
str{4} = '- You''ll hear a tone when you answer correctly.';
str{5} = '- You''ll be shown your score every 5 trials.   ';
str{6} = '- Keep your head still.                         ';
str{7} = '- Keep your gaze on the center of the screen.   ';
str{8} = '- Respond only after the fixation changes from  ';
str{9} = '  white to blue.                                ';
str{10} = '';
str{11} = '(Press the ''Space'' key to continue.)';
showText(str);

str = {};
str{1} = 'To begin the task, press the ''Space'' key.';
showText(str);
