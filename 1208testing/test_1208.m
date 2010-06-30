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
disp('Please press a pad button...');
resp = data;
while resp == data;
    resp = DaqDIn(daq);
    if (GetSecs - begTime) > 30
        disp('Not receiving data! Bummer!');
        return
    end
end
disp('Received data!');
disp(resp);

% 4) send data out
disp('4)  Send data');
err1 = DaqDOut(daq, 0, 10);
WaitSecs(0.5);
err2 = DaqDIn(daq, 0, 5);
disp('Data sent!');
disp('');
disp('Finished! You may want to also run DaqTest also to verify that everything is working correctly.');