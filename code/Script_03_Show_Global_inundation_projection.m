clear;close all;clc;
addpath('/Users/xudo627/developments/getPanoply_cMap/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');
addpath('/Users/xudo627/donghui/mylib/m/');

plot_upscale = 0;

load('domain_global_coastline_merit_90m.mat');
load('bathtub_global_coastline_merit_90m.mat');
load('../GFDL-CM4C192-SST_future_inundation_month.mat');

[merit_xv,merit_yv,merit_area] = xc2xv(merit_x,merit_y,1/8,1/8,1);

yr_plot = 2050;
yr0     = 2016;

frac_ocn_mon(frac_ocn_mon < 0) = 0;
frac_ocn_max(frac_ocn_max < 0) = 0;

figure;
frac_ocn1 = frac_ocn_mon(:,(yr_plot - yr0) * 12 + 1 : (yr_plot - yr0 + 1) * 12);
frac_ocn2 = frac_ocn_max(:,(yr_plot - yr0) * 12 + 1 : (yr_plot - yr0 + 1) * 12);

frac_ocn1 = nanmean(frac_ocn1,2);
frac_ocn2 = max(frac_ocn2,[],2);

[lon,lat,frac_ocn1_1deg] = upscale_data(merit_x,merit_y,merit_frac,frac_ocn1,1);
cmap = getPanoply_cMap('NEO_modis_lst');
figure;
imAlpha = ones(size(frac_ocn1_1deg));
imAlpha(isnan(frac_ocn1_1deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],frac_ocn1_1deg,'AlphaData',imAlpha); 
colormap(cmap); colorbar; hold on; caxis([0 0.2]);
set(gca,'YDir','normal');
ylim([-60 90]);

%load coastlines.mat;
%plot(coastlon,coastlat,'g-','LineWidth',2);

nansum(frac_ocn1 .* merit_frac .* merit_area)./1e6
nansum(frac_ocn2 .* merit_frac .* merit_area)./1e6

nanmean(frac_ocn1) - nanmean(merit_bathtub(:,1))
nanmean(frac_ocn2)

nt = (2050 - 2016 + 1) * 12;
global_inundation_area = NaN(nt,2);
for i = 1 : nt
    tmp1 = frac_ocn_mon(:,i);
    tmp2 = frac_ocn_max(:,i);
    global_inundation_area(i,1) = nansum(tmp1 .* merit_frac .* merit_area)./1e6;
    global_inundation_area(i,2) = nansum(tmp2 .* merit_frac .* merit_area)./1e6;
end
figure;
plot(2016:2050,nanmean(reshape(global_inundation_area(:,1),[12 nt/12]),1),'b-','LineWidth',2); grid on; hold on;
plot(2016:2050,nanmean(reshape(global_inundation_area(:,2),[12 nt/12]),1),'r--','LineWidth',2); 


if plot_upscale

S = shaperead('/Users/xudo627/Downloads/World_Countries_(Generalized)/World_Countries__Generalized_.shp');
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
ylim([-60 90]);

inundated_area = nansum(merit_area.*merit_bathtub(:,6))./1e6
end