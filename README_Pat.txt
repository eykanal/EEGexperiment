README_Pat.txt

This document describes the use of this directory for the free-response 
fMRI experiment and its behavioral equivalent (which is twice as long and 
has more instructions displayed).

The experiment covaries 2 levels of dot-motion coherence, 2 levels of RSI, 
and two cue-types: dots, as usual, or dots followed by an arrow cue. The 
arrow cue was intended to occur at such a time that the resulting RT 
distribution was pretty much the same as the dots RT distribution, so the 
idea was to fit the DDM to the dots data, then randomly draw arrow-onset 
times from it, at the same time subtracting the residual latency T0. Now 
we think that the best way to do that is to draw onset-times from the 
behavioral dots conditions, and subtract a randomly sampled RT from the 
behavioral arrow conditions that have equivalent RSI and coherence. That 
should handle the fact that signal-detection RT really depends on RSI and 
stuff like that. Whether it will actually produce similar RT distributions 
remains to be seen . . . time to collect more behavioral data!!!



As of 2/4/2009, I found that I did not remember why I had selected 2 and 3 
seconds as the RSIs, instead of 2 and 4 as per the original plan. I think 
the function test_fMRI_design.m, which is in the old, pre-SVN folder, 
~/DotsfMRI_OSX/FreeResponsefMRI, showed that you can only get about 25 
trials into a 2-minute block with mean RSI 4 sec and gamma distribution 
shape parameter 10. But that's not that bad really. You get about 30 for a 
3 sec RSI, and I'm both curious to see how people do with a longer RSI, and 
I'd like to be sure that the RSI's are really different, to show a strong 
RSI effect (otherwise, why are we manipulating RSI?).

Because I failed to record coherence information before 2/4/2009, we 
couldn't use Mike Arcaro's behavioral data to generate arrow-onset times. 
Now that is corrected, but I'd like to record coherence info on a trial by 
trial basis, which I'm not yet doing. OK, that's done now.



CRITICAL CODE CHANGES TO GET CODE TO WORK IN FMRI SCANNER: I had to make 
changes to DotsX_Dec2008 code. Specifically, I had to change a line in a 
file called ~/DotsX_Dec2008/classes/hardware/@dXkbHID/dXkbHID.m to deal 
with the fact that multiple keyboards make that function barf. Line 33 to 
be exact. There's an old version in dXkbHID.m.pristine. I furthermore had 
to change the while loop that listens for the scanner trigger from KbCheck 
to KbCheckMulti.m. That uses a for-loop to examine all the HID devices for 
keypresses. Could be inefficient, but in practice seems to lead to no 
noticeable delay. Josh's dXkbHID object is meant to make data collection 
easier, but I'd rather stick with what I know. Unfortunately, the new 
object is required by the latest DotsX code. 







SUBJECT NUMBER: I am now following Mike A's idea and using my birthday as 
my subject number, 6870. 


NEW CHANGES, 2/9/2009: 
1) Setting coherence back to 0 again on arrow trials -- I definitely feel 
that I'm deciding about motion direction during arrow trials, so 0 
coherence should help defeat that somewhat.
2) Now able to draw arrow_onset times from pre-existing RT distribution, 
which is obtained by a behavioral session and then concatenating the 
data together. 
3) Made penalty delays for anticipatory responses equal to twice the RSI in
a given condition.
4) Shortened behavioral signal detection blocks to half the duration of a 
dots or arrow block.
5) Allowing user to enter a string as a comment into the file at the start 
of an experiment.
6) Allowing override so that all RSIs are equal to the longest value. This 
can help compensate for the reduced number of long-RSI trials that would 
otherwise occur, relative to the number of short-RSI trials. 




SCANNER TIMING: 
There is a blank time at the end of the experiment, currently 1 second.

There are 8 blocks, each of 2-minutes duration (120 sec) ---- "blockdur".

There are 30-second rest periods before each block ---- "waitdur".

So there should be 8*30 + 8*120 + 1 seconds = 1201 seconds. 
Now with 10 sec blank-time: 1210 seconds

With 8*10 + 8*2 + 2 = 98 seconds (debugging).







SCANNING HISTORY:

Naming convention: M##<First name Initial><Last name initial>MMDDYYYY
(## is the number of the scan, sequentially)
(MMDDYYYY is the subject's birthday)


M01PS060870

2/9/2009: Test scanning Pat. Resolution of scanner projector is 1024x768, 75 Hz
Result: failure to get two keyboards to work. Solution required changing a 
KbCheck to KbCheckMulti in trial_arrow.m (in a while loop used to absorb 
continuous key pressing). I also had to make everything selective, 
responding only to left and right key presses, so that scanner trigger 
pulses don't get picked up. 

2/16/2009: Trying to test scan Pat again. Discovered that block duration limits 
in the block code enforce only a lower bound of duration. Each block can go 
over this lower bound, because the trial-level code doesn't check for time 
limits. SUBJECT ID: M01PS060870




M02MA070282

3/3/2009: Now scanning Mike for his first fMRI run, using arrow onset times 
calculated from his behavioral data from earlier today: subject72_ses4.mat. 
He's been having having difficulty with the low coherence behaviorally, 
with wide variance in average accuracy from block to block of low coherence. 

Accuracy is way lower in the scanner. So we'll double the coherence. 
Unfortunately, his behavioral data was saved as subject72_ses2.mat. I've 
copied that to subject72_ses991.mat.




M03SM021177

3/16/09: Stephanie is scanning for the first time. We're running the 
psychometric function approximator. Stephanie did fine with the psychometric 
function, even though there was only audio feedback, which worked fine. 
Saved as psychomses_vPat_data_21177_0_scanner.mat.

Comparable behavioral psychometric data is saved in the specifically named 
folder, Data21177, as psychomses_vPat_data_21177_0.mat.

She also did a single run of experiment_fMRI.m. Data was saved in the trunk 
of FreeResponsefMRI as subject21177_ses1.mat. Coherences were 6 and 12.






M04MA070282

3/16/09: Mike is rescanning. We did the psychometric function code again. I
modified the saved name for this file as psychomses_vPat_data_72_0_scanner.mat.
Comparable behavioral psychometric data is saved in the specifically named 
folder, Data72, as psychomses_vPat_data_72_0.mat.

He also did two runs of experiment_fMRI.m (coherences 12 and 24). Data was 
saved as subject72_ses8.mat and subject72_ses9.mat.



M05MA070282

4/8/09: Mike redoing a second psychometric function run, then a dots vs. 
arrows scan.



M06SM021177

4/13/09: Coughed during first arrows block of first run.




M07SM021177
4/20/09: First scan of penalty_dots.m. Coherences of 2 and 4. One behavioral 
session was done at $0.01 reward/$0.02 penalty, and coherence of 2, which 
produced nice long RTs, and 80% accuracy.
penalty_dots_subject21177_ses0.mat and ses1.mat
Two-handed responding
TRs:
run1 = 613
run2 = 602






M08MA070282
4/22/09: First scan of penalty_dots.m. Coherences of 4 and 7. One behavioral 
was done at $0.01 reward/$0.02 penalty, and coherence of 3, which produced 
big strings of errors that threw him off, and then RTs that started out very 
low in each block, and then tended to grow and grow. So I'm easing up on the 
coherence. IMPORTANT: This is the first time we've used singled-handed 
responding.





M09SM021177
5/4/09: Second scan of penalty dots, (penalty_dots_subject21177_ses3.mat, 
and ses4.mat and ses5.mat). $0.01 reward/$0.02 penalty, and coherence of 
2 and 4.
M09_r1:  595 TRs
M09_r2:  614 TRs
M09_r3:  618 TRs
Single-handed responding






M10FB021279
Dots vs. arrows
Coherence: 4 and 8 (I think)
2 runs
Two-handed responding.




M11PS060870
5/11/09: Coherence: 2 and 4
Penalty dots
3 sessions
Behavioral data files: penalty_dots_subject6870_ses0.mat, ses1.mat and ses2.mat.
TRs:
597     M11_r1
613     M11_r2
603     M11_r3
Two handed responding



M12FB021279
5/11/09: Coherence: 2 and 4
Penalty dots
Behavioral data files: Data21279Scanner/penalty_dots_subject21279_ses0.mat 
and ses1.mat.
Two-handed responding.



M13FB021279
5/13/09: Coherence 3 and 5 (I think)
Behavioral data files: Data21279Scanner/penalty_dots_subject21279_ses1.mat 
and ses2.mat.
TRs: 
Run 1: 624
Run 2: 612
Two-handed responding.



