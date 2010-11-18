function analyzePhotodiode( dot_history, frame )

x = -1:0.01:1;
y = sqrt(1-x.^2);

x = (x+1)/2;
y = (y+1)/2;

figure(1);
clf(1);
hold on;

scatter( x, y );
scatter( x, -y+1 );

color = [1 0 0];

for n = 1:length(frame)
    scatter( dot_history(1,:,frame(n)), dot_history(2,:,frame(n)), [], color, 'x' );
    color(1) = color(1) - 0.25;
end

end