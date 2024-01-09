clear;close all;clc;

files1 = dir('projection/CTL/*.nc');
files2 = dir('projection/FUT/*.nc');

msl_ctl = NaN(43119,length(files1));
msl_fut = NaN(43119,length(files2));

for i = 1 : length(files1)
    filename = fullfile(files1(i).folder,files1(i).name);
    msl_ctl(:,i) = ncread(filename,'mean_sea_level');
    if i == 1
        lon = ncread(filename,'station_x_coordinate');
        lat = ncread(filename,'station_y_coordinate');
    end
end

for i = 1 : length(files2)
    filename = fullfile(files2(i).folder,files2(i).name);
    msl_fut(:,i) = ncread(filename,'mean_sea_level');
end

msl_foc = nanmean(msl_fut,2) - nanmean(msl_ctl,2);

figure;
scatter(lon,lat,9,nanmean(msl_ctl,2),'filled'); colorbar;
caxis([-0.3,0.3]); colormap(blue2red(11));