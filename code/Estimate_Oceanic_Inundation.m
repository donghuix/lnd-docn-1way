clear;close all;clc;

addpath('/Users/xudo627/developments/getPanoply_cMap/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');
addpath('/Users/xudo627/donghui/mylib/m/');

load('coastline_ele.mat');
frac   = ncread('/Users/xudo627/projects/cesm-inputdata/domain.lnd.nldas2_0224x0464_c110415.nc','frac');
ind = find(frac > 0 & frac < 0.99);

files = dir('projection/historical_msl_*.nc');

msl = NaN(length(lon),length(files));
for i = 1 : length(files)
    filename = fullfile(files(i).folder,files(i).name);
    if i == 1
        x = ncread(filename,'station_x_coordinate');
        y = ncread(filename,'station_y_coordinate');
        idx = NaN(length(lon),1);
        for j = 1 : length(lon)
        %     plot([lonv(:,i); lonv(1,i)],[latv(:,i); latv(1,i)],'k-','LineWidth',1); hold on;
            dist = sqrt((x - lon(j)).^2 + (y - lat(j)).^2);
            ind = find(dist == min(dist));
            idx(j) = ind(1);
        end
    end
    tmp = ncread(filename,'mean_sea_level');
    msl(:,i) = tmp(idx);
end

figure;
plot(nanmean(msl,1),'k-','LineWidth',2);

figure;
patch(lonv,latv,nanmean(msl,2),'LineStyle','none'); colormap(blue2red(11));
caxis([-0.1 0.1]); colorbar;

inund = NaN(length(lon),1);
x = 0 : 0.01 : 1;
for i = 1 : length(lon)
    tmp = ele(i,:);
    tmp = tmp(:);
    if ~any(isnan(tmp)) && ~all(tmp == 0)
        [y,ic,ia] = unique(tmp);
        inund(i) = interp1(y,x(ic),nanmean(msl(i,:)));
    end
end

figure;
cmap = getPanoply_cMap('NEO_modis_lst');
patch(lonv,latv,inund,'LineStyle','none'); colormap(cmap);
colorbar;
