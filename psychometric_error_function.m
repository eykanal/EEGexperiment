function my_error = psychometric_error_function( x, sigs, mean_behavior, cdf_type )
% psychometric_error_function(x, coherVec, acc', cdf_type)

my_error = 0;

% mean_behavior = [ 0.0500    0.3000    0.1500    0.5000    0.7500    0.8500    0.8500 ];
% sigs = [ -1.5000   -1.0000   -0.5000         0    0.5000    1.0000    1.5000 ];

if cdf_type == 1
    my_error = sum( ( mean_behavior - normcdf( x(1) * sigs + x(2) ) ) .^2 );
elseif cdf_type == 2
    my_error = sum( ( mean_behavior - wblcdf( sigs - sigs(1), x(1), x(2) ) ) .^2 );
elseif cdf_type == 3
    my_error = sum( ( mean_behavior - gamcdf( sigs, x(1), x(2) ) ) .^2 );
end
