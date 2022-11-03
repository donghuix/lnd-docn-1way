function [lon,lat,data_out] = upscale_data(x,y,frac,data_in,dd)
    lon = [-180 + dd/2 : dd : 180 - dd/2];
    lat = [90 - dd/2 : -dd : -90 + dd/2];
    [lon,lat] = meshgrid(lon,lat);
    [nx,ny] = size(lon);
    data_out = NaN(nx,ny);
    for i = 1 : nx
        disp(i);
        for j = 1 : ny
            lonv = [lon(i,j) - dd/2; lon(i,j) + dd/2; lon(i,j) + dd/2; lon(i,j) - dd/2];
            latv = [lat(i,j) - dd/2; lat(i,j) - dd/2; lat(i,j) + dd/2; lat(i,j) + dd/2;];

            in = inpoly2([x y],[lonv latv]);
            if ~isempty(in)
                data_out(i,j) = nansum(data_in(in).*frac(in))./nansum(frac(in));
            end
        end
    end
end

