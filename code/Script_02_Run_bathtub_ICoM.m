clear;close all;clc;

addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');
addpath('/Users/xudo627/developments/getPanoply_cMap/');

domain = '/Users/xudo627/projects/land-ocean-two-way-coupling/domain.lnd.r0125_oRRS15to5.191122.nc';
station_x = ncread('projection/waterlevel/GFDL-CM4C192-SST_future_waterlevel_2035_01_v1.nc','station_x_coordinate');
station_y = ncread('projection/waterlevel/GFDL-CM4C192-SST_future_waterlevel_2035_01_v1.nc','station_y_coordinate');
icom = [ [-81; -70; -70; -81; -81] [36; 36; 45; 45; 36] ];
in = inpoly2([station_x station_y],icom);
station_x = station_x(in);
station_y = station_y(in);

dx = 1 / 8;
dy = 1 / 8;

frac = ncread(domain,'frac');
xc   = ncread(domain,'xc');
yc   = ncread(domain,'yc');

icos = frac > 0 & frac < 1;
in   = inpoly2([xc(:) yc(:)],icom);

in = icos(:) & in;

frac = frac(in);
xc   = xc(in);
yc   = yc(in);
xv   = NaN(4,length(xc));
yv   = NaN(4,length(yc));

xv(1,:) = xc - dx/2; xv(2,:) = xc + dx/2; xv(3,:) = xc + dx/2; xv(4,:) = xc - dx/2;
yv(1,:) = yc - dy/2; yv(2,:) = yc - dy/2; yv(3,:) = yc + dy/2; yv(4,:) = yc + dy/2; 

save('domain.mat','xc','yc','xv','yv','frac');

figure;
cmap = getPanoply_cMap('NEO_modis_lst');
patch(xv,yv,frac,'LineStyle','none'); colormap(cmap);caxis([0 1]); colorbar; hold on;


fileID = fopen('MERIT_tiles.txt');
C = textscan(fileID,'%s');
tiles = cell(length(C{1}),1);
fclose(fileID);

for j = 1 : length(C{1})
    tiles{j} = C{1}{j};
    tile = tiles{j};
    if strcmp(tile(1),'n')
        ymin = str2double(tile(2:3));
    elseif strcmp(tile(1),'s')
        ymin = -str2double(tile(2:3));
    end

    ymax = ymin + 5;

    if strcmp(tile(4),'w')
        xmin = -str2double(tile(5:7));
    elseif strcmp(tile(4),'e')
        xmin = str2double(tile(5:7));
    end

    xmax = xmin + 5;

    %plot([xmin; xmax; xmax; xmin; xmin], [ymin; ymin; ymax; ymax; ymin],'k-','LineWidth',2); hold on;
    in = inpoly2([xc yc],[[xmin; xmax; xmax; xmin; xmin] [ymin; ymin; ymax; ymax; ymin]]);
    if sum(in) > 0
        disp(tile);
        plot([xmin; xmax; xmax; xmin; xmin], [ymin; ymin; ymax; ymax; ymin],'k-','LineWidth',2); hold on;
    end
end

plot(station_x,station_y,'g.','LineWidth',2);
if 1
SLR = 0 : 0.1 : 10;
bathtub_ele = NaN(length(xc),length(SLR));

tiles = {'n35w075_dem.tif','n35w080_dem.tif','n40w075_dem.tif'};
for i = 1 : length(tiles)
    tile = tiles{i};
    I = geotiffinfo(['./MERIT/' tile]); 
    [x,y]=pixcenters(I);
    dem = double(imread(['./MERIT/' tile]));
    dem(dem == -9999) = NaN;
    
    if strcmp(tile(1),'n')
        ymin = str2double(tile(2:3));
    elseif strcmp(tile(1),'s')
        ymin = -str2double(tile(2:3));
    end

    ymax = ymin + 5;

    if strcmp(tile(4),'w')
        xmin = -str2double(tile(5:7));
    elseif strcmp(tile(4),'e')
        xmin = str2double(tile(5:7));
    end

    xmax = xmin + 5;
    
    in = inpoly2([xc yc],[[xmin; xmax; xmax; xmin; xmin] [ymin; ymin; ymax; ymax; ymin]]);
    in = find(in == 1);
    for j = 1 : length(in)
        
        disp([tile ': j = ' num2str(j) '/' num2str(length(in))]);
        
        j1 = min(find(x >= min(xv(:,in(j)))));
        j2 = max(find(x <= max(xv(:,in(j)))));

        i1 = max(find(y >= min(yv(:,in(j)))));
        i2 = min(find(y <= max(yv(:,in(j)))));
        
        ny = (i1-i2+1);
        nx = (j2-j1+1);
        grid_dem = dem(i2:i1,j1:j2);
        
        connect = bathtub(grid_dem,3);
        connect(grid_dem >= 3 & grid_dem <=10) = 1;
        
        for k = 1 : length(SLR)
            below = grid_dem <= SLR(k) & connect;
            bathtub_ele(in(j),k) = sum(below(:)) / length(find(~isnan(grid_dem(:))));
        end
        
    end
end
save('ICOM_bathtub_ele.mat','bathtub_ele');
end

