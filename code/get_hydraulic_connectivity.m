function connect = get_hydraulic_connectivity(dem,thre)
    [nx,ny] = size(dem);
    dem(1,1:ny) = NaN;
    dem(nx,1:ny) = NaN;
    dem(1:nx,1) = NaN;
    dem(1:nx,ny) = NaN;
    connect = zeros(nx,ny);
    ind = find(dem <= thre);
    
    for i = 1 : length(ind)
        disp(['i = ' num2str(i) ' / ' num2str(length(ind))]);
        [icurr,jcurr] = ind2sub([nx ny],ind(i));
        
        icurr0 = icurr;
        jcurr0 = jcurr;
        inext = 0; 
        while ~isnan(inext) && inext ~= -1
            [inext,jnext] = find_downstream(icurr,jcurr,dem,nx,ny);
            icurr = inext;
            jcurr = jnext;
        end
        
        if icurr == -1
            connect(icurr0,jcurr0) = 1;
        end
        
    end
    
end

function [inext,jnext] = find_downstream(icurr,jcurr,dem,nx,ny)
if icurr == 1 && jcurr == 1
    % x 1 o
    % 3 2 o
    % o o o
    ldem  = NaN(3,1);
    is    = NaN(3,1);
    js    = NaN(3,1);
    ldem0 = dem(icurr,jcurr);

    ldem(1) = dem(icurr,jcurr+1);
    is(1) = icurr; js(1) = jcurr+1;

    ldem(2) = dem(icurr+1,jcurr+1);
    is(2) = icurr+1; js(2) = jcurr+1;

    ldem(3) = dem(icurr+1,jcurr);
    is(3) = icurr+1; js(3) = jcurr;

    if any(isnan(ldem))
        inext = -1; jnext = -1;
    elseif ldem0 < min(ldem)
        inext = NaN; jnext = NaN;
    else
        imin = find(ldem == min(ldem));
        inext = is(imin);
        jnext = js(imin);
    end

elseif icurr == 1 && jcurr == ny
    % o 1 x
    % o 2 3
    % o o o
    ldem  = NaN(3,1);
    is    = NaN(3,1);
    js    = NaN(3,1);
    ldem0 = dem(icurr,jcurr);

    ldem(1) = dem(icurr,jcurr-1);
    is(1) = icurr; js(1) = jcurr-1;

    ldem(2) = dem(icurr+1,jcurr-1);
    is(2) = icurr+1; js(2) = jcurr-1;

    ldem(3) = dem(icurr+1,jcurr);
    is(3) = icurr+1; js(3) = jcurr;

    if any(isnan(ldem))
        inext = -1; jnext = -1;
    elseif ldem0 < min(ldem)
        inext = NaN; jnext = NaN;
    else
        imin = find(ldem == min(ldem));
        inext = is(imin);
        jnext = js(imin);
    end

elseif icurr == nx && jcurr == 1
    % o o o
    % 1 2 o
    % x 3 o
    ldem  = NaN(3,1);
    is    = NaN(3,1);
    js    = NaN(3,1);
    ldem0 = dem(icurr,jcurr);

    ldem(1) = dem(icurr-1,jcurr);
    is(1) = icurr-1; js(1) = jcurr;

    ldem(2) = dem(icurr-1,jcurr+1);
    is(2) = icurr-1; js(2) = jcurr+1;

    ldem(3) = dem(icurr,jcurr+1);
    is(3) = icurr; js(3) = jcurr+1;

    if any(isnan(ldem))
        inext = -1; jnext = -1;
    elseif ldem0 < min(ldem)
        inext = NaN; jnext = NaN;
    else
        imin = find(ldem == min(ldem));
        inext = is(imin);
        jnext = js(imin);
    end

elseif icurr == nx && jcurr == ny
    % o o o
    % o 2 1
    % o 3 x
    ldem  = NaN(3,1);
    is    = NaN(3,1);
    js    = NaN(3,1);
    ldem0 = dem(icurr,jcurr);

    ldem(1) = dem(icurr-1,jcurr);
    is(1) = icurr-1; js(1) = jcurr;

    ldem(2) = dem(icurr-1,jcurr-1);
    is(2) = icurr-1; js(2) = jcurr-1;

    ldem(3) = dem(icurr,jcurr-1);
    is(3) = icurr; js(3) = jcurr-1;

    if any(isnan(ldem))
        inext = -1; jnext = -1;
    elseif ldem0 < min(ldem)
        inext = NaN; jnext = NaN;
    else
        imin = find(ldem == min(ldem));
        inext = is(imin);
        jnext = js(imin);
    end

elseif jcurr == 1
    % 1 2 o
    % x 3 o
    % 5 4 o
    ldem  = NaN(5,1);
    is    = NaN(5,1);
    js    = NaN(5,1);
    ldem0 = dem(icurr,jcurr);

    ldem(1) = dem(icurr-1,jcurr);
    is(1) = icurr-1; js(1) = jcurr;

    ldem(2) = dem(icurr-1,jcurr+1);
    is(2) = icurr-1; js(2) = jcurr+1;

    ldem(3) = dem(icurr,jcurr+1);
    is(3) = icurr; js(3) = jcurr+1;

    ldem(4) = dem(icurr+1,jcurr+1);
    is(4) = icurr+1; js(4) = jcurr+1;

    ldem(5) = dem(icurr+1,jcurr);
    is(5) = icurr+1; js(5) = jcurr;

    if any(isnan(ldem))
        inext = -1; jnext = -1;
    elseif ldem0 < min(ldem)
        inext = NaN; jnext = NaN;
    else
        imin = find(ldem == min(ldem));
        inext = is(imin);
        jnext = js(imin);
    end

elseif icurr == 1
    % 1 x 5
    % 2 3 4
    % o o o
    ldem  = NaN(5,1);
    is    = NaN(5,1);
    js    = NaN(5,1);
    ldem0 = dem(icurr,jcurr);

    ldem(1) = dem(icurr,jcurr-1);
    is(1) = icurr; js(1) = jcurr-1;

    ldem(2) = dem(icurr1+1,jcurr-1);
    is(2) = icurr+1; js(2) = jcurr-1;

    ldem(3) = dem(icurr+1,jcurr);
    is(3) = icurr+1; js(3) = jcurr;

    ldem(4) = dem(icurr+1,jcurr+1);
    is(4) = icurr+1; js(4) = jcurr+1;

    ldem(5) = dem(icurr,jcurr+1);
    is(5) = icurr; js(5) = jcurr+1;

    if any(isnan(ldem))
        inext = -1; jnext = -1;
    elseif ldem0 < min(ldem)
        inext = NaN; jnext = NaN;
    else
        imin = find(ldem == min(ldem));
        inext = is(imin);
        jnext = js(imin);
    end

elseif jcurr == nx
    % o 2 1
    % o 3 x
    % o 4 5
    ldem  = NaN(5,1);
    is    = NaN(5,1);
    js    = NaN(5,1);
    ldem0 = dem(icurr,jcurr);

    ldem(1) = dem(icurr-1,jcurr);
    is(1) = icurr-1; js(1) = jcurr;

    ldem(2) = dem(icurr-1,jcurr-1);
    is(2) = icurr-1; js(2) = jcurr-1;

    ldem(3) = dem(icurr,jcurr-1);
    is(3) = icurr; js(3) = jcurr-1;

    ldem(4) = dem(icurr+1,jcurr-1);
    is(4) = icurr+1; js(4) = jcurr-1;

    ldem(5) = dem(icurr+1,jcurr);
    is(5) = icurr+1; js(5) = jcurr;

    if any(isnan(ldem))
        inext = -1; jnext = -1;
    elseif ldem0 < min(ldem)
        inext = NaN; jnext = NaN;
    else
        imin = find(ldem == min(ldem));
        inext = is(imin);
        jnext = js(imin);
    end

elseif icurr == ny
    % o o o
    % 2 3 4
    % 1 x 5
    ldem  = NaN(5,1);
    is    = NaN(5,1);
    js    = NaN(5,1);
    ldem0 = dem(icurr,jcurr);

    ldem(1) = dem(icurr,jcurr-1);
    is(1) = icurr; js(1) = jcurr-1;

    ldem(2) = dem(icurr1-1,jcurr-1);
    is(2) = icurr-1; js(2) = jcurr-1;

    ldem(3) = dem(icurr-1,jcurr);
    is(3) = icurr-1; js(3) = jcurr;

    ldem(4) = dem(icurr-1,jcurr+1);
    is(4) = icurr-1; js(4) = jcurr+1;

    ldem(5) = dem(icurr,jcurr+1);
    is(5) = icurr; js(5) = jcurr+1;

    if any(isnan(ldem))
        inext = -1; jnext = -1;
    elseif ldem0 < min(ldem)
        inext = NaN; jnext = NaN;
    else
        imin = find(ldem == min(ldem));
        inext = is(imin);
        jnext = js(imin);
    end

else
    % 1 2 3
    % 8 x 4
    % 7 6 5
    ldem  = NaN(8,1);
    is    = NaN(8,1);
    js    = NaN(8,1);
    ldem0 = dem(icurr,jcurr);

    ldem(1) = dem(icurr-1,jcurr-1);
    is(1) = icurr-1; js(1) = jcurr-1;

    ldem(2) = dem(icurr-1,jcurr);
    is(2) = icurr-1; js(2) = jcurr;

    ldem(3) = dem(icurr-1,jcurr+1);
    is(3) = icurr-1; js(3) = jcurr+1;

    ldem(4) = dem(icurr,jcurr+1);
    is(4) = icurr; js(4) = jcurr+1;

    ldem(5) = dem(icurr+1,jcurr+1);
    is(5) = icurr+1; js(5) = jcurr+1;

    ldem(6) = dem(icurr+1,jcurr);
    is(6) = icurr+1; js(6) = jcurr;

    ldem(7) = dem(icurr+1,jcurr-1);
    is(7) = icurr+1; js(7) = jcurr-1;

    ldem(8) = dem(icurr,jcurr-1);
    is(8) = icurr; js(8) = jcurr-1;

    
    if any(isnan(ldem))
        inext = -1; jnext = -1;
    elseif ldem0 < min(ldem)
        inext = NaN; jnext = NaN;
    else
        imin = find(ldem == min(ldem));
        inext = is(imin);
        jnext = js(imin);
    end

end

end