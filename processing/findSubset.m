function subset = findSubset(all, pattern)
% extract relevant datasets

tmp     = (regexp(all, pattern));
subset  = all(~cellfun(@isempty,tmp));
