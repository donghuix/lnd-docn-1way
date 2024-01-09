clear; close all;clc;

addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

% xv = [-76.5294; -76.5148; -76.5183; -76.5310; -76.5390; -76.5294];
% yv = [38.7167;  38.7212;  38.7348;  38.7362;  38.7281;  38.7167];

xc = -76.45; 
yc = 38.979;
dx = 0.1; dy = 0.1;
xv(1) = xc - dx/2; xv(2) = xc + dx/2; xv(3) = xc + dx/2; xv(4) = xc - dx/2; xv(5) = xc - dx/2; 
yv(1) = yc - dy/2; yv(2) = yc - dy/2; yv(3) = yc + dy/2; yv(4) = yc + dy/2; yv(5) = yc - dy/2; 

month_labels = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
tile = '/Volumes/LaCie/DATA/GLAD/season/40N_080W/';
glad = NaN(1200,1200,12);

for i = 1 : length(month_labels)
    if i < 10
        filename = [tile '0' num2str(i) '_' month_labels{i} '_percent_99_20.tif'];
    else
        filename = [tile num2str(i) '_' month_labels{i} '_percent_99_20.tif'];
    end
    disp(filename);
    if i == 1
        I = geotiffinfo(filename); 
        [x,y]=pixcenters(I);
        ind_i = find(x > min(xv) - 0.1 & x < max(xv) + 0.1); 
        ind_j = find(y > min(yv) - 0.1 & y < max(yv) + 0.1); 
        [lon,lat] = meshgrid(x(ind_i),y(ind_j));
    end
    A = imread(filename);
    tmp = double(A(min(ind_j) : max(ind_j),min(ind_i) : max(ind_i)));
    tmp(tmp > 101) = NaN;
    
    glad(:,:,i) = tmp;
end
figure;
in = inpoly2([lon(:) lat(:)],[xv(:) yv(:)]);

glad_grid = NaN(12,1);
load coastlines.mat
for i = 1 : 12
    subplot(3,4,i);
    tmp = glad(:,:,i);
    %tmp(tmp > 80) = 100;
    imAlpha = ones(size(tmp));
    imAlpha(isnan(tmp)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],tmp,'AlphaData',imAlpha); hold on;
    set(gca,'YDir','normal'); colorbar;
    plot(xv,yv,'g-','LineWidth',2); 
    plot(coastlon,coastlat,'r-','LineWidth',2);
    xlim([min(xv) max(xv)]);
    ylim([min(yv) max(yv)]);
    
    glad_grid(i) = nanmean(tmp(in));
end

figure;
plot(glad_grid,'k-','LineWidth',2);

files = dir('data/reanalysis_waterlevel_hourly_*.nc');
wl = NaN(12,1);
for i = 1 : length(files)
    filename = fullfile(files(i).folder,files(i).name);
    disp(filename);
    if i == 1 
        station_x = ncread(filename,'station_x_coordinate');
        station_y = ncread(filename,'station_y_coordinate');
        dist = (station_x - nanmean(xv)).^2 + (station_y - nanmean(yv)).^2;
        in = find(dist == min(dist));
%         in = inpoly2([station_x station_y],[xv yv]);
    end
    waterlevel = ncread(filename,'waterlevel');
    wl(i) = nanmean(nanmean(waterlevel(in,:),2));
end

figure;
plot(wl,'b-','LineWidth',2);
% figure;
% A = double(A); A(A > 101) = NaN;
% imAlpha = ones(size(A));
% imAlpha(isnan(A)) = 0;
% imagesc([x(1),x(end)],[y(1),y(end)],A,'AlphaData',imAlpha); hold on;
% set(gca,'YDir','normal'); colorbar;
% plot(xv,yv,'g-','LineWidth',2); 