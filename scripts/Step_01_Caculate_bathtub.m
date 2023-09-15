clear;close all;clc;

dx = 1/8;
dy = 1/8;

fileID = fopen('/compyfs/icom/xudo627/MERIT/MERIT_tiles.txt');
C = textscan(fileID,'%s');
tiles = cell(length(C{1}),1);
fclose(fileID);

SLR = 0 : 0.1 : 10;

for j = 1 : length(C{1})
    tiles{j} = C{1}{j};
    tile = tiles{j};
    disp(tile);
    
    fout  = ['../MERIT_bathtub/' tile(1:8) 'bathtub.mat'];
    fout2 = ['../MERIT_bathtub/' tile(1:8) 'dem_mu.mat' ];
    fout3 = ['../MERIT_bathtub/' tile(1:8) 'dem_std.mat'];

    tic; 
    load(['../MERIT_frac/' tile(1:8) 'frac.mat']);
    dem = double(imread(['/compyfs/icom/xudo627/MERIT/' tile]));
    dem(dem == -9999) = NaN;
    
    ind = find(frac > 0  & frac < 1);
    bathtub_ele = NaN(length(ind),101);
    dem_mu      = NaN(length(ind),1);
    dem_std     = NaN(length(ind),1);
    disp(length(ind));
    
    for i = 1 : length(ind)
        disp([tile ', ii = ' num2str(i) '/' num2str(length(ind))]);
        [ii,jj] = ind2sub([40,40],ind(i));
        
        if frac(ii,jj) > 0 && frac(ii,jj) < 1
            grid_dem   = dem((ii-1)*150 + 1 : ii*150, (jj-1)*150 + 1 : jj*150);
            dem_mu(i)  = nanmean(grid_dem(:));
            dem_std(i) = nanstd(grid_dem(:));
            if ~exist(fout,'file')
            connect = bathtub(grid_dem,3);
            connect(grid_dem >= 3 & grid_dem <=10) = 1;

            for k = 1 : length(SLR)
                below = grid_dem <= SLR(k) & connect;
                bathtub_ele(i,k) = sum(below(:)) / length(find(~isnan(grid_dem(:))));
            end
            end
        end
    end

    if ~exist(fout,'file')
        save(fout,'bathtub_ele','bathtub_ele');
    end
    if ~exist(fout2,'file')
        save(fout2,'dem_mu');
    end
    if ~exist(fout3,'file')
        save(fout3,'dem_std');
    end
    toc;
end
