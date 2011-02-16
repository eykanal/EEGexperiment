% close display
rDone;
rClear;
Screen CloseAll;

% close running threads
rsc = findResource;
[pending queued running finished] = findJob(rsc);
if length(pending) > 1
    destroy(pending);
end
if length(queued) > 1
    destroy(queued);
end
if length(running) > 1
    destroy(running);
end
if length(finished) > 1
    destroy(finished);
end


clear rsc pending queued running finished;