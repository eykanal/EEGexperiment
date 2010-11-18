load 'photodiodeTest_data/photodiodeTestData_''MEG2''.mat' 'dot*';

meg1_dotHist = dot_history;
meg1_dotTime = dot_timeHistory;

load 'photodiodeTest_data/photodiodeTestData_''MEG3''.mat' 'dot*';

meg2_dotHist = dot_history;
meg2_dotTime = dot_timeHistory;

load 'photodiodeTest_data/photodiodeTestData_''PC1''.mat' 'dot*';

pc1_dotHist = dot_history;
pc1_dotTime = dot_timeHistory;

load 'photodiodeTest_data/photodiodeTestData_''PC2''.mat' 'dot*';

pc2_dotHist = dot_history;
pc2_dotTime = dot_timeHistory;

load 'photodiodeTest_data/photodiodeTestData_''LAPTOP1''.mat' 'dot*';

laptop1_dotHist = dot_history;
laptop1_dotTime = dot_timeHistory;

load 'photodiodeTest_data/photodiodeTestData_''LAPTOP2''.mat' 'dot*';

laptop2_dotHist = dot_history;
laptop2_dotTime = dot_timeHistory;

clear dot*;

meg_timeDiff = meg1_dotTime - cat(1,meg2_dotTime,0);

% plot on scatter
x = -1:0.01:1;
y = sqrt(1-x.^2);

x = (x+1)/2;
y = (y+1)/2;

figure();
hold on;

scatter( x, y );
scatter( x, -y+1 );

color = [1 0 0];

frame = 50;
scatter( meg1_dotHist(1,:,frame), meg1_dotHist(2,:,frame), [], 'red', 'x' );
scatter( meg2_dotHist(1,:,frame), meg2_dotHist(2,:,frame), [], 'blue', 'o' );
scatter( pc1_dotHist(1,:,frame), pc1_dotHist(2,:,frame), [], 'green', '^' );
scatter( pc2_dotHist(1,:,frame), pc2_dotHist(2,:,frame), [], 'black', 'v' );
scatter( laptop1_dotHist(1,:,frame), laptop1_dotHist(2,:,frame), [], [0 0.5 0.5], '*' );
scatter( laptop2_dotHist(1,:,frame), laptop2_dotHist(2,:,frame), [], [0.5 0 0.5], 'p' );
legend;

figure(); bar(meg1_dotTime,ones(1,length(meg1_dotTime)),0.01); axis([0 5 0 1]);
figure(); bar(meg2_dotTime,ones(1,length(meg2_dotTime)),0.01); axis([0 5 0 1]);

figure(); bar(meg1_dotTime,ones(1,length(meg1_dotTime)),0.01); axis([0 5 0 1]);
figure(); bar(meg2_dotTime,ones(1,length(meg2_dotTime)),0.01); axis([0 5 0 1]);
