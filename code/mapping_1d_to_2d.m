function data2d = mapping_1d_to_2d(data1d,mapping,map_1dto2d,sz)
    data1d = data1d(:);
    data1d(isnan(data1d)) = 0;
    
    data2d = NaN(sz);
    data2d(map_1dto2d) = data1d'*mapping;
end

