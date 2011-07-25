probs = {'MEG0232', 'MEG0233', 'MEG0812', 'MEG0923', 'MEG0943'};

for n=1:length(probs)
    for m=1:2
        index = find(strcmp(cond(m).label,probs(n))); 
        if ~isempty(index)
            cond(m).avg(index,:) = [];
            cond(m).var(index,:) = [];
            cond(m).dof(index,:) = [];
            cond(m).label(index,:) = [];
        end
    end
end
