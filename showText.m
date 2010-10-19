function showText( str )
%
% Show text using dXtext method, have subject press space bar to proceed.
% Standardized to display text such that letters occupy 0.7 degrees in the
% visual field.
%
%   str = n x 1 cell containing string to be shown. Each row should contain
%         one line of text.
%
% Eliezer Kanal, 10/19/10

[wn_, sr_, ppd_, fr_] = rGraphicsGetScreenAttributes;
font_degrees = 0.7;
fontsize = floor(font_degrees * ppd_);
if ~iscell(str)
    str = {str};
end

for i = 1:length(str)
    textwidth = fontsize * length(str{i})/ppd_;
    x_pos{i}  = -0.3 * textwidth;
end

% Equally distribute lines in middle of screen
y_pos = font_degrees * (length(str):-1:1) - (floor(length(str)/2));
y_pos = num2cell(y_pos);

if length(str) == 1
    if iscell(str)
        str = cell2mat(str);
    end
    x_pos = cell2mat(x_pos);
    y_pos = cell2mat(y_pos);
end

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