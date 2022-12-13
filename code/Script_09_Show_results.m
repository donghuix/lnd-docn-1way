clear;close all;clc;

addpath('/Users/xudo627/donghui/mylib/m/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

load('../data/domain_global_coastline_merit_90m.mat');

[xv,yv] = xc2xv(merit_x,merit_y,1/8,1/8,false);

CTL1 = load('../data/outputs/historical_zwt_annual.mat');
FUT1 = load('../data/outputs/ssp585_zwt_annual.mat');
CTL2 = load('../data/outputs/historical_results_annual.mat');
FUT2 = load('../data/outputs/ssp585_results_annual.mat');


cmap = getPyPlot_cMap('BuPu');
X = [nanmean(CTL1.zwtyr,2) nanmean(FUT1.zwtyr,2)];
figure;
hist3(X,'CdataMode','auto','Nbins',[200,200],'LineStyle','none');
view(2);colormap(cmap);colorbar; ylim([0 80]); xlim([0 80]); caxis([0 50]);
colorbar;
hold on;
xlabel('CTL');
ylabel('FUT');

zwtdelta   = nanmean(FUT1.zwtyr(:,end),2) - nanmean(CTL1.zwtyr,2);
qtotdelta  = (nanmean(FUT2.qrunoff,2) - nanmean(CTL2.qrunoff,2)).*86400.*365;
qoverdelta = (nanmean(FUT2.qover,2) - nanmean(CTL2.qover,2)).*86400.*365;
qocndelta  = (nanmean(FUT2.qh2oocn,2) - nanmean(CTL2.qh2oocn,2)).*86400.*365;
ql2odelta  = (nanmean(FUT2.qlnd2ocn,2) - nanmean(CTL2.qlnd2ocn,2)).*86400.*365;
qinfdelta  = (nanmean(FUT2.qinfl,2) - nanmean(CTL2.qinfl,2)).*86400.*365;

[lon,lat,zwtdelta_2deg]  = upscale_data(merit_x,merit_y,ones(length(zwtdelta),1),zwtdelta,2);
[lon,lat,qtotdelta_2deg] = upscale_data(merit_x,merit_y,ones(length(qtotdelta),1),qtotdelta,2);
[lon,lat,qoverdelta_2deg]= upscale_data(merit_x,merit_y,ones(length(qoverdelta),1),qoverdelta,2);
[lon,lat,qocndelta_2deg] = upscale_data(merit_x,merit_y,ones(length(qocndelta),1),qocndelta,2);
[lon,lat,ql2odelta_2deg] = upscale_data(merit_x,merit_y,ones(length(ql2odelta),1),ql2odelta,2);
[lon,lat,qinfdelta_2deg] = upscale_data(merit_x,merit_y,ones(length(qinfdelta),1),qinfdelta,2);

figure;
imAlpha = ones(size(zwtdelta_2deg));
imAlpha(isnan(zwtdelta_2deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],zwtdelta_2deg,'AlphaData',imAlpha); 
colormap(blue2red(121)); colorbar; hold on; caxis([-1 1]); 
set(gca,'YDir','normal');
ylim([-60 90]);

figure;
imAlpha = ones(size(qtotdelta_2deg));
imAlpha(isnan(qtotdelta_2deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],qtotdelta_2deg,'AlphaData',imAlpha); 
colormap(blue2red(121)); colorbar; hold on; caxis([-50 50]); 
set(gca,'YDir','normal');
ylim([-60 90]);

figure;
imAlpha = ones(size(qoverdelta_2deg));
imAlpha(isnan(qoverdelta_2deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],qoverdelta_2deg,'AlphaData',imAlpha); 
colormap(blue2red(121)); colorbar; hold on; caxis([-50 50]); 
set(gca,'YDir','normal');
ylim([-60 90]);


figure;
subplot(2,2,1);
imAlpha = ones(size(qocndelta_2deg));
imAlpha(isnan(qocndelta_2deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],qocndelta_2deg,'AlphaData',imAlpha); 
colormap(blue2red(121)); colorbar; hold on; caxis([-50 50]); 
set(gca,'YDir','normal');
ylim([-60 90]);

subplot(2,2,2);
imAlpha = ones(size(ql2odelta_2deg));
imAlpha(isnan(ql2odelta_2deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],ql2odelta_2deg,'AlphaData',imAlpha); 
colormap(blue2red(121)); colorbar; hold on; caxis([-50 50]); 
set(gca,'YDir','normal');
ylim([-60 90]);

subplot(2,2,3);
imAlpha = ones(size(qinfdelta_2deg));
imAlpha(isnan(qinfdelta_2deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],qinfdelta_2deg,'AlphaData',imAlpha); 
colormap(blue2red(121)); colorbar; hold on; caxis([-50 50]); 
set(gca,'YDir','normal');
ylim([-60 90]);

subplot(2,2,4);
tmp = qinfdelta_2deg./(qinfdelta_2deg + qocndelta_2deg - ql2odelta_2deg);
imAlpha = ones(size(tmp));
imAlpha(isnan(tmp)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],tmp,'AlphaData',imAlpha); 
colormap(blue2red(121)); colorbar; hold on; caxis([0 1]); 
set(gca,'YDir','normal');
ylim([-60 90]);
