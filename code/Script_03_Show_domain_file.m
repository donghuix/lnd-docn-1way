clear;close all;clc;
addpath('/Users/xudo627/developments/getPanoply_cMap/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');
addpath('/Users/xudo627/donghui/mylib/m/');

cmap = getPanoply_cMap('NEO_modis_lst');

filename = '../inputdata/domain.lnd.r0125_WC14to60E2r3.200924.nc';
frac = ncread(filename,'frac');
xc   = ncread(filename,'xc');
yc   = ncread(filename,'yc');
ind  = find(frac > 0 & frac < 1 & yc >= -60);

fileID = fopen('../MERIT/MERIT_tiles.txt');
C = textscan(fileID,'%s');
tiles = cell(length(C{1}),1);

merit_frac = [];
merit_x = [];
merit_y = [];
figure;
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
    in = inpoly2([xc(ind) yc(ind)],[[xmin; xmax; xmax; xmin; xmin] [ymin; ymin; ymax; ymax; ymin]]);
    if sum(in) > 0
        disp(tile);
        plot([xmin; xmax; xmax; xmin; xmin], [ymin; ymin; ymax; ymax; ymin],'k-','LineWidth',2); hold on;
    end
    
    tmp = load(['../MERIT_frac/' tile(1:8) 'frac.mat']);
    ii = find(tmp.frac > 0 & tmp.frac < 1);
    merit_frac = [merit_frac; tmp.frac(ii)];
    merit_x    = [merit_x; tmp.x(ii)];
    merit_y    = [merit_y; tmp.y(ii)];
end
fclose(fileID);

[merit_xv,merit_yv,merit_area] = xc2xv(merit_x,merit_y,1/8,1/8);

S = shaperead('/Users/xudo627/Downloads/World_Countries_(Generalized)/World_Countries__Generalized_.shp');
figure;
cmap = getPanoply_cMap('NEO_modis_lst');
patch(merit_xv,merit_yv,merit_frac,'LineStyle','none'); colormap(cmap); 
caxis([0 1]); colorbar; hold on;
ylim([-60 90]);

dd = 1;
lon = [-180 + dd/2 : dd : 180 - dd/2];
lat = [90 - dd/2 : -dd : -90 + dd/2];
[lon,lat] = meshgrid(lon,lat);
[nx,ny] = size(lon);
frac1deg = NaN(nx,ny);
for i = 1 : nx
    disp(i);
    for j = 1 : ny
        lonv = [lon(i,j) - dd/2; lon(i,j) + dd/2; lon(i,j) + dd/2; lon(i,j) - dd/2];
        latv = [lat(i,j) - dd/2; lat(i,j) - dd/2; lat(i,j) + dd/2; lat(i,j) + dd/2;];
        
        in = inpoly2([merit_x merit_y],[lonv latv]);
        if ~isempty(in)
            frac1deg(i,j) = nanmean(merit_frac(in));
        end
    end
end
imAlpha = ones(size(frac1deg));
imAlpha(isnan(frac1deg)) = 0;
figure;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],frac1deg,'AlphaData',imAlpha); 
colormap(cmap); colorbar; caxis([0 1]); hold on;
set(gca,'YDir','normal');
ylim([-60 90]);

% ind = find(~isnan(frac1deg));
% coastline_countary = NaN(length(ind),1);
% for i = 1 : length(ind)
%     disp(i);
%     lonv = [lon(ind(i)) - dd/2; lon(ind(i)) + dd/2; lon(ind(i)) + dd/2; lon(ind(i)) - dd/2];
%     latv = [lat(ind(i)) - dd/2; lat(ind(i)) - dd/2; lat(ind(i)) + dd/2; lat(ind(i)) + dd/2;];
%         
%     for j = 1 : length(S)
%         in = inpoly2([S(j).X' S(j).Y'],[lonv latv]);
%         if sum(in) >= 1
%             coastline_countary(i,1) = j;
%         end
%     end
% end
% 
% a = unique(coastline_countary(~isnan(coastline_countary)));
% for i = 1 : length(S)
%     if any(a == i)
%         plot(S(i).X,S(i).Y,'k-','LineWidth',0.5); hold on;
%     end
% end
ylim([-60 90]);

xmin1 = 118.5; xmax1 = 122.5; ymin1 = 21.5; ymax1 = 25.5;
xmin2 = -82;   xmax2 = -72;   ymin2 = 32;   ymax2 = 41;
xmin3 = 38;    xmax3 = 50;    ymin3 = -15;  ymax3 = -10;


if 0 
figure;
patch(merit_xv,merit_yv,merit_frac,'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
plot([xmin1 xmax1 xmax1 xmin1 xmin1],[ymin1 ymin1 ymax1 ymax1 ymin1],'r-','LineWidth',4);
xlim([xmin1 xmax1]);
ylim([ymin1 ymax1]); colorbar; caxis([0 1]);

figure;
patch(merit_xv,merit_yv,merit_frac,'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
plot([xmin2 xmax2 xmax2 xmin2 xmin2],[ymin2 ymin2 ymax2 ymax2 ymin2],'b-','LineWidth',4);
ylim([-60 90]);
xlim([xmin2 xmax2]);
ylim([ymin2 ymax2]); colorbar; caxis([0 1]);

figure;
patch(merit_xv,merit_yv,merit_frac,'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
plot([xmin3 xmax3 xmax3 xmin3 xmin3],[ymin3 ymin3 ymax3 ymax3 ymin3],'g-','LineWidth',4);
ylim([-60 90]);
xlim([xmin3 xmax3]);
ylim([ymin3 ymax3]); colorbar; caxis([0 1]);



figure;
[xv,yv] = xc2xv(xc(ind),yc(ind),1/8,1/8);
patch(xv,yv,frac(ind),'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
ylim([-60 90]);
plot([xmin3 xmax3 xmax3 xmin3 xmin3],[ymin3 ymin3 ymax3 ymax3 ymin3],'g-','LineWidth',4);
ylim([-60 90]);
xlim([xmin3 xmax3]);
ylim([ymin3 ymax3]); colorbar; caxis([0 1]);

figure;
patch(merit_xv,merit_yv,merit_frac,'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
plot([xmin2 xmax2 xmax2 xmin2 xmin2],[ymin2 ymin2 ymax2 ymax2 ymin2],'b-','LineWidth',4);
ylim([-60 90]);
xlim([xmin2 xmax2]);
ylim([ymin2 ymax2]); colorbar; caxis([0 1]);

figure;
[xv,yv] = xc2xv(xc(ind),yc(ind),1/8,1/8);
patch(xv,yv,frac(ind),'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
ylim([-60 90]);
plot([xmin3 xmax3 xmax3 xmin3 xmin3],[ymin3 ymin3 ymax3 ymax3 ymin3],'g-','LineWidth',4);
ylim([-60 90]);
xlim([xmin3 xmax3]);
ylim([ymin3 ymax3]); colorbar; caxis([0 1]);

plot([xmin1 xmax1 xmax1 xmin1 xmin1],[ymin1 ymin1 ymax1 ymax1 ymin1],'r-','LineWidth',2);
plot([xmin2 xmax2 xmax2 xmin2 xmin2],[ymin2 ymin2 ymax2 ymax2 ymin2],'b-','LineWidth',2);
plot([xmin3 xmax3 xmax3 xmin3 xmin3],[ymin3 ymin3 ymax3 ymax3 ymin3],'g-','LineWidth',2);

figure;
[xv,yv] = xc2xv(xc(ind),yc(ind),1/8,1/8);
patch(xv,yv,frac(ind),'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
ylim([-60 90]);
plot([xmin1 xmax1 xmax1 xmin1 xmin1],[ymin1 ymin1 ymax1 ymax1 ymin1],'r-','LineWidth',4);
xlim([xmin1 xmax1]);
ylim([ymin1 ymax1]); colorbar; caxis([0 1]);

figure;
[xv,yv] = xc2xv(xc(ind),yc(ind),1/8,1/8);
patch(xv,yv,frac(ind),'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
plot([xmin2 xmax2 xmax2 xmin2 xmin2],[ymin2 ymin2 ymax2 ymax2 ymin2],'b-','LineWidth',4);
ylim([-60 90]);
xlim([xmin2 xmax2]);
ylim([ymin2 ymax2]); colorbar; caxis([0 1]);

figure;
[xv,yv] = xc2xv(xc(ind),yc(ind),1/8,1/8);
patch(xv,yv,frac(ind),'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
plot([xmin3 xmax3 xmax3 xmin3 xmin3],[ymin3 ymin3 ymax3 ymax3 ymin3],'g-','LineWidth',4);
ylim([-60 90]);
xlim([xmin3 xmax3]);
ylim([ymin3 ymax3]); colorbar; caxis([0 1]);
end