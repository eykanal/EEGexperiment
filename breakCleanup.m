% close display
rDone;
rClear;
Screen CloseAll;

% close running threads
rsc = findResource;
[pending queued running finished] = findJob(rsc);
destroy(running);
clear rsc pending queued running finished;