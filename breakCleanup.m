% close display
try
    rDone;
    rClear;
    Screen CloseAll;
end

% close running threads
rsc = findResource;
[pending queued running finished] = findJob(rsc);
if ~isempty(pending)
    destroy(pending);
end
if ~isempty(queued)
    destroy(queued);
end
if ~isempty(running)
    destroy(running);
end
if ~isempty(finished)
    destroy(finished);
end


clear rsc pending queued running finished;