function createRTstruct(subject,session,basedir)
% function createRTstruct(subject,session,basedir)
% create an RTstruct for use with future arrow trials
% INPUT Args:
% subject = 4    % subject
% session = 1    % session
% basedir = '~/Desktop/DOT003'   % directory where the behavioral
% file resides; if this is left empty, the basedir is assumed to be
% the current directory

if ~exist('basedir','var')
  basedir = pwd;
end

load(fullfile(basedir,sprintf('subject%d_ses%d.mat',subject,session)));
outFile = fullfile(basedir,sprintf('RTsforArrows_subj%d.mat',subject));

RT_t = RT;
D_t = D;
CueType_t = cueVec;
TrialCoh_t = zeros(size(cohVec));
TrialCoh_t(cohVec==coherence_array(2)) = 1;
% RT struct is created based on RT_t, D_t, CueType_t, TrialCoh_t
save(outFile,'RT_t','D_t','CueType_t','TrialCoh_t');
