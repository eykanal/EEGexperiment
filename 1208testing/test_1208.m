function test_1208()
%
% This function tests 1208 functionality by:
%   1) locating the device
%   2) blinking the device LED
%   3) receiving digital data through port B
%   4) sending a digital response out port A
% the device.
%
%   EK - 6/17/10
%

% 1) locate the device
disp('1) Locate device');
devices = PsychHID('Devices');
daq = DaqDeviceIndex;
daq = daq(2);
if ~isempty(daq)
    disp('Found device!');
else
    disp('No device found!');
    disp(devices);
    return;
end

% 2) blinking device LED
disp('2) Blink LED');
err = DaqBlinkLED(daq);
if ~err
    disp('Error!');
    disp(err);
    return;
end

resp = input('Did it blink? (y/n)');
if resp ~= 'y'
    disp('I thought it did! Problem!');
    return;
else
    disp('Good!');
end

% 3) receive data
disp('3) Receive data');
errA = DaqDConfigPort(daq, 0, 0);   % Port A will send data out
errB = DaqDConfigPort(daq, 1, 1);   % Port B will receive data

begTime = GetSecs;
data = DaqDIn(daq);

fprintf('\nFor the next few seconds, press the right pad buttons...');
right = zeros(1000,1);
for n = 1:1000
    resp = DaqDIn(daq);
    right(n) = resp(2);

    % use escape to get out of this
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        while KbCheck; end
        break;
    end
end

fprintf('\nFor the next few seconds, press the left pad buttons...');
left = zeros(1000,1);
for n = 1:1000
    resp = DaqDIn(daq);
    left(n) = resp(2);

    % use escape to get out of this
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        while KbCheck; end
        break;
    end
end

fprintf('\nFor the next few seconds, press both the pad buttons...');
both = zeros(1000,1);
for n = 1:1000
    resp = DaqDIn(daq);
    both(n) = resp(2);

    % use escape to get out of this
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        while KbCheck; end
        break;
    end
end

fprintf('\nFor the next few seconds, go nuts on the pad buttons...');
gonuts = zeros(1000,1);
for n = 1:1000
    resp = DaqDIn(daq);
    gonuts(n) = resp(2);

    % use escape to get out of this
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        while KbCheck; end
        break;
    end
end

disp('Collected!');

% 4) send data out
disp('4)  Send data');
err1 = DaqDOut(daq, 0, 10);
WaitSecs(0.5);
err2 = DaqDOut(daq, 0, 5);
disp('Data sent!');
disp('');
plot(x);
save('buttonPressing.mat','left','right','both','gonuts');
disp('Finished! You may want to also run DaqTest also to verify that everything is working correctly.');