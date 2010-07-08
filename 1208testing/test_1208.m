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
if isempty(err)
    disp('Error!');
    disp(err);
    return;
end

resp = input('Did it blink? (y/n) ','s');
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

fprintf('\nPress the right pad button... ');
for n = 1:1000
    resp = DaqDIn(daq);
    if resp(2) == 240
        fprintf('pressed!');
        break;
    end

    % use escape to get out of this
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        while KbCheck; end
        break;
    end
end

fprintf('\nPress the left pad button... ');
while 1
    resp = DaqDIn(daq);
    if resp(2) == 232
        fprintf('pressed!');
        break;
    end

    % use escape to get out of this
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        while KbCheck; end
        break;
    end
end

fprintf('\nPress both pad buttons... ');
for n = 1:1000
    resp = DaqDIn(daq);
    if resp(2) == 248
        fprintf('pressed!\n');
        break;
    end

    % use escape to get out of this
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        while KbCheck; end
        break;
    end
end

% 4) send data out
disp('4)  Send data');
err1 = DaqDOut(daq, 0, 10);
WaitSecs(0.5);
err2 = DaqDOut(daq, 0, 5);
disp('Data sent!');
disp('');
%save('buttonPressing.mat','left','right','both','gonuts');
disp('Finished! You may want to also run DaqTest also to verify that everything is working correctly.');