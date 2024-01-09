function connect = bathtub(dem,thre)

    OPT = 2;
    
    [nx,ny] = size(dem);
    connect = zeros(nx,ny);
    ind = find(dem <= thre);
    
    Is = 1 : nx;
    Js = 1 : ny;
    [Is,Js] = meshgrid(Is,Js);
    Is = Is'; Js = Js';
    
    if OPT == 1
        for i = 1 : length(ind)
            disp(['i = ' num2str(i) ' / ' num2str(length(ind))]);
            [icurr,jcurr] = ind2sub([nx ny],ind(i));

            in0 = Is == icurr & Js == jcurr;
            k = 1;
            in  = Is >= icurr - k & Is <= icurr + k & Js >= jcurr - k & Js <= jcurr + k & ~in0;

            while any(dem(in) <= thre)
                disp(['k = ' num2str(k)]);
                k = k + 1;
                in0 = in | in0;
                in  = Is >= icurr - k & Is <= icurr + k & Js >= jcurr - k & Js <= jcurr + k & ~in0;
                if any(isnan(dem(in)))
                    connect(icurr,jcurr) = 1;
                    break;
                end
                if all(dem(in)) > thre
                    connect(in0) = 0;
                    break;
                end
            end

        end
    else
        isocean = isnan(dem);
        nocean0 = sum(isocean(:));
        nocean = nocean0+1;
        
        while nocean > nocean0
            
            nocean0 = nocean;
            
            for i = 1 : length(ind)
                [icurr,jcurr] = ind2sub([nx ny],ind(i));
                in0 = Is == icurr & Js == jcurr;
                k = 1;
                in  = Is >= icurr - k & Is <= icurr + k & Js >= jcurr - k & Js <= jcurr + k & ~in0;

                if any(isocean(in) == 1)
                    connect(icurr,jcurr) = 1;
                    isocean(icurr,jcurr) = 1;
                end
            end

            nocean = sum(isocean(:));
            
        end
        
    end
    
end

