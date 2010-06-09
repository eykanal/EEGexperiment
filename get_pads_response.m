function val = get_pads_response( parport )

% wait for response
val     = getvalue(parport);
decval  = bin2dec(num2str(val));
d       = decval;

while d == decval
    val     = getvalue(parport);
    decval  = bin2dec(num2str(val));
end
