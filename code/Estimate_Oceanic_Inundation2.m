clear;close all;clc;

addpath('/Users/xudo627/developments/getPanoply_cMap/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');
addpath('/Users/xudo627/donghui/mylib/m/');

load('coastline_ele.mat');

if exist('GFDL-CM4-CONUS-wl.mat','file')
    load('GFDL-CM4-CONUS-wl.mat');
else
    files = dir('projection/waterlevel/GFDL-CM4*.nc');

    wl = NaN(length(lon),6.*24.*365);
    n0 = 0;
    for i = 1 : length(files)
        filename = fullfile(files(i).folder,files(i).name);
        disp(filename);
        if i == 1
            x = ncread(filename,'station_x_coordinate');
            y = ncread(filename,'station_y_coordinate');
            idx = NaN(length(lon),1);
            for j = 1 : length(lon)
                dist = sqrt((x - lon(j)).^2 + (y - lat(j)).^2);
                ind = find(dist == min(dist));
                idx(j) = ind(1);
            end
        end
        tmp = ncread(filename,'waterlevel');
        tmp = tmp(idx,:);
        n   = size(tmp,2);
        if i == 1
            wl(:,1:n) = tmp;
        else
            wl(:,n0+1:n0+n) = tmp;
        end
        n0 = n0 + size(tmp,2);
    end

    save('GFDL-CM4-CONUS-wl.mat','wl');
end

if exist('GFDL-CM4-CONUS-inund-daily.mat','file')
    load('GFDL-CM4-CONUS-inund-daily.mat');
else
    inund_daily = NaN(length(lon),365);
    x = 0 : 0.01 : 1;

    for i = 1 : length(lon)
        ele_prof = ele(i,:);
        ele_prof = ele_prof(:);
        if ~any(isnan(ele_prof)) && ~all(ele_prof == 0)
            [y,ic,ia] = unique(ele_prof); 

            for j = 1 : 365
                disp(['i = ' num2str(i) ', j = ' num2str(j)]);
                tmp = NaN(144,1);
                for k = 1 : 144
                    if wl(i,(j-1)*144 + k) <= 0
                        tmp(k) = 0;
                    else
                        tmp(k) = interp1(y,x(ic),wl(i,(j-1)*144 + k)) - interp1(y,x(ic),0);
                    end
                end
                inund_daily(i,j) = nanmean(tmp);
            end
        end
    end
    
    save('GFDL-CM4-CONUS-inund-daily.mat','inund_daily');
end

cmap = getPanoply_cMap('NEO_modis_lst');
figure;
patch(lonv,latv,max(inund_daily,[],2),'LineStyle','none'); colormap(cmap); colorbar; caxis([0 0.3]);

figure;
patch(lonv,latv,nanmean(inund_daily,2),'LineStyle','none'); colormap(cmap); colorbar; caxis([0 0.3]);