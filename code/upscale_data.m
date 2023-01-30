function [lon,lat,data_out,mapping,map_1dto2d] = upscale_data(x,y,frac,data_in,dd)
    lon = [-180 + dd/2 : dd : 180 - dd/2];
    lat = [90 - dd/2 : -dd : -90 + dd/2];
    [lon,lat] = meshgrid(lon,lat);
    [nx,ny] = size(lon);
    data_out = NaN(nx,ny);
    map_1dto2d = [];
    mapping = zeros(length(data_in),1);
    
    i2 = 1;
    for i = 1 : nx
        disp(i);
        for j = 1 : ny
            lonv = [lon(i,j) - dd/2; lon(i,j) + dd/2; lon(i,j) + dd/2; lon(i,j) - dd/2];
            latv = [lat(i,j) - dd/2; lat(i,j) - dd/2; lat(i,j) + dd/2; lat(i,j) + dd/2;];

            in = inpoly2([x y],[lonv latv]);
            if ~isempty(in) && any(~isnan(data_in(in)))
                data_out(i,j) = nansum(data_in(in).*frac(in))./nansum(frac(in));
                map_1dto2d = [map_1dto2d; sub2ind([nx, ny],i,j)];
                mapping(in,i2) = frac(in)./nansum(frac(in));
                i2 = i2 + 1;
            end
        end
    end
    
    mapping = sparse(mapping);
end

