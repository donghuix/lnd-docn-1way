clear;close all;clc;

addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');
addpath('/Users/xudo627/donghui/mylib/m/');

data1 = load('zwt_test.mat');
data0 = load('zwt_test_no_coupling.mat');

load('domain_global_coastline_merit_90m.mat');

ind1 = find(merit_x > -95  & merit_x < -85  & merit_y > 25 & merit_y < 35);
%ind2 = find(merit_x > -125 & merit_x < -115 & merit_y > 30 & merit_y < 45);
ind2 = find(merit_x < 60);
%ind = find(merit_x < 60);
%

zwt0 = nanmean(reshape(nanmean(merit_topo(ind1) - data0.zwt(ind1,:),1)',[12 100]),1);
zwt1 = nanmean(reshape(nanmean(data1.zwt(ind1,:),1)',[12 103]),1);

zwt1 = zwt1(1:80);

figure;
plot(zwt0,'k-','LineWidth',2); hold on; grid on;
plot(zwt1,'r--','LineWidth',2);
xlabel('Simulation Year','FontSize',15,'FontWeight','bold');
ylabel('Water table depth [m]','FontSize',15,'FontWeight','bold');
legend('No coupling','one-way coupling','FontSize',15);

zwt0 = nanmean(reshape(nanmean(merit_topo(ind2) - data0.zwt(ind2,:),1)',[12 100]),1);
zwt1 = nanmean(reshape(nanmean(data1.zwt(ind2,:),1)',[12 103]),1);

zwt1 = zwt1(1:80);

figure;
plot(zwt0,'k-','LineWidth',2); hold on; grid on;
plot(zwt1,'r--','LineWidth',2);
xlabel('Simulation Year','FontSize',15,'FontWeight','bold');
ylabel('Water table depth [m]','FontSize',15,'FontWeight','bold');
legend('No coupling','one-way coupling','FontSize',15);



zwt = merit_topo - nanmean(data1.zwt,2);
[lon,lat,zwt_1deg] = upscale_data(merit_x,merit_y,ones(length(merit_x),1),zwt,1);

cmap = getPyPlot_cMap('jet');

figure;
imAlpha = ones(size(zwt_1deg));
imAlpha(isnan(zwt_1deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],zwt_1deg,'AlphaData',imAlpha); 
colormap(cmap); colorbar; hold on; caxis([0 100]);
set(gca,'YDir','normal');
ylim([-60 90]);

figure;
plot(nanmean(data0.zwt,2),nanmean(data1.zwt,2),'bo');

zwt_abs = merit_topo - nanmean(data0.zwt,2);
[lon,lat,zwt_abs_1deg] = upscale_data(merit_x,merit_y,ones(length(merit_x),1),zwt_abs,1);

figure;
imAlpha = ones(size(zwt_abs_1deg));
imAlpha(isnan(zwt_abs_1deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],zwt_abs_1deg,'AlphaData',imAlpha); 
colormap(jet); colorbar; hold on; %caxis([-1 1]);
set(gca,'YDir','normal');
ylim([-60 90]);


[merit_xv,merit_yv,merit_area] = xc2xv(merit_x,merit_y,1/8,1/8,1);
figure;
patch(merit_xv,merit_yv,data0.zwt(:,end),'LineStyle','none');

figure;
patch(merit_xv,merit_yv,merit_topo,'LineStyle','none');

sens = NaN(length(merit_x),1);

for i = 1 : length(merit_x)
    disp(i);
    zwt     = nanmean(reshape(nanmean(data1.zwt(i,:),1)',[12 103]),1);
    zwt     = zwt(71:90);
    sens(i) = sens_slope(zwt');
end

[lon,lat,sens_1deg] = upscale_data(merit_x,merit_y,ones(length(merit_x),1),sens,1);

figure;
imAlpha = ones(size(sens_1deg));
imAlpha(isnan(sens_1deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],sens_1deg,'AlphaData',imAlpha); 
colormap(blue2red(121)); colorbar; hold on; caxis([-0.01 0.01]); 
set(gca,'YDir','normal');
ylim([-60 90]);

