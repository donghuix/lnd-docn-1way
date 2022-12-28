clear;close all;clc;

addpath('/Users/xudo627/donghui/mylib/m/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

read_data = 0;

exs1 = {'ctl-ctl','ctl-fut','fut-ctl','fut-fut'};
tag1 = {'ctl_ctl','ctl_fut','fut_ctl','fut_fut'};
exs2 = {'ctl-ctl','ctl-025','ctl-050','ctl-075','ctl-100'};
tag2 = {'ctl_ctl','ctl_025','ctl_050','ctl_075','ctl_100'};

load('../data/domain_global_coastline_merit_90m.mat');

[xv,yv] = xc2xv(merit_x,merit_y,1/8,1/8,false);

zwt = struct([]);
amr = struct([]);
rst = struct([]);

% if exist('../data/deltarst.mat','file') && read_data
%     load('../data/deltarst.mat');
% else
%     for i = 1 : length(exs1)
%         disp(['Read ' exs1{i}]);
%         rst(1).(tag1{i}) = load(['../data/outputs/' exs1{i} '_results_annual.mat']);
%     end
% 
%     deltazwt1  = nanmean(zwt.ctl_fut.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
%     deltazwt2  = nanmean(zwt.fut_ctl.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
%     deltazwt3  = nanmean(zwt.fut_fut.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
%     
%     [~,~,deltazwt1_2deg] = upscale_data(merit_x,merit_y,merit_frac,deltazwt1,2);
%     [~,~,deltazwt2_2deg] = upscale_data(merit_x,merit_y,merit_frac,deltazwt2,2);
%     [lon,lat,deltazwt3_2deg] = upscale_data(merit_x,merit_y,merit_frac,deltazwt3,2);
% 
%     save('../data/deltazwt.mat','deltazwt1_2deg','deltazwt2_2deg','deltazwt3_2deg');
% end


if exist('../data/deltazwt.mat','file') && read_data
    load('../data/deltazwt.mat');
else
    for i = 1 : length(exs1)
        disp(['Read ' exs1{i}]);
        zwt(1).(tag1{i}) = load(['../data/outputs/' exs1{i} '_zwt_annual.mat']);
    end

    deltazwt1  = nanmean(zwt.ctl_fut.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
    deltazwt2  = nanmean(zwt.fut_ctl.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
    deltazwt3  = nanmean(zwt.fut_fut.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
    
    [~,~,deltazwt1_2deg] = upscale_data(merit_x,merit_y,merit_frac,deltazwt1,2);
    [~,~,deltazwt2_2deg] = upscale_data(merit_x,merit_y,merit_frac,deltazwt2,2);
    [lon,lat,deltazwt3_2deg] = upscale_data(merit_x,merit_y,merit_frac,deltazwt3,2);

    save('../data/deltazwt.mat','deltazwt1_2deg','deltazwt2_2deg','deltazwt3_2deg');
end

% foc_amtr1 = nanmean(amr.ctl_fut.AMTR,2) ./ nanmean(amr.ctl_ctl.AMTR,2);
% foc_amtr2 = nanmean(amr.fut_ctl.AMTR,2) ./ nanmean(amr.ctl_ctl.AMTR,2);
% foc_amtr3 = nanmean(amr.fut_fut.AMTR,2) ./ nanmean(amr.ctl_ctl.AMTR,2);
if exist('../data/deltaamtr.mat','file') && read_data
    load('../data/deltaamtr.mat');
else
    for i = 1 : length(exs1)
        disp(['Read ' exs1{i}]);
        amr(1).(tag1{i}) = load(['../data/outputs/' exs1{i} '_AMR.mat']);
    end
    foc_amtr1 = prctile(amr.ctl_fut.AMTR,99,2) - prctile(amr.ctl_ctl.AMTR,99,2);
    foc_amtr2 = prctile(amr.fut_ctl.AMTR,99,2) - prctile(amr.ctl_ctl.AMTR,99,2);
    foc_amtr3 = prctile(amr.fut_fut.AMTR,99,2) - prctile(amr.ctl_ctl.AMTR,99,2);

    [~,~,foc_amtr1_2deg]     = upscale_data(merit_x,merit_y,merit_frac,foc_amtr1,2);
    [~,~,foc_amtr2_2deg]     = upscale_data(merit_x,merit_y,merit_frac,foc_amtr2,2);
    [lon,lat,foc_amtr3_2deg] = upscale_data(merit_x,merit_y,merit_frac,foc_amtr3,2);

    save('../data/deltaamtr.mat','foc_amtr1_2deg','foc_amtr2_2deg','foc_amtr3_2deg', ...
                                 'lon','lat');
end

foc_amtr1_2deg = foc_amtr1_2deg.*86400;
foc_amtr2_2deg = foc_amtr2_2deg.*86400;
foc_amtr3_2deg = foc_amtr3_2deg.*86400;

plot_exs3(lon,lat,deltazwt1_2deg, deltazwt2_2deg, deltazwt3_2deg, -0.5, 0.5);
plot_exs3(lon,lat,foc_amtr1_2deg,foc_amtr2_2deg,foc_amtr3_2deg,-5,5);

% if exist('../data/deltazwt2.mat','file')
%     load('../data/deltazwt2.mat');
% else
%     for i = 1 : length(exs2)
%         disp(['Read ' exs2{i}]);
%         zwt(1).(tag2{i}) = load(['../data/outputs/' exs2{i} '_zwt_annual.mat']);
%     end
% 
%     deltazwt1  = nanmean(zwt.ctl_025.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
%     deltazwt2  = nanmean(zwt.ctl_050.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
%     deltazwt3  = nanmean(zwt.ctl_075.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
%     deltazwt4  = nanmean(zwt.ctl_100.zwtyr,2) - nanmean(zwt.ctl_ctl.zwtyr,2);
%     
%     [~,~,deltazwt1_2deg]     = upscale_data(merit_x,merit_y,merit_frac,deltazwt1,2);
%     [~,~,deltazwt2_2deg]     = upscale_data(merit_x,merit_y,merit_frac,deltazwt2,2);
%     [~,~,deltazwt3_2deg]     = upscale_data(merit_x,merit_y,merit_frac,deltazwt3,2);
%     [lon,lat,deltazwt4_2deg] = upscale_data(merit_x,merit_y,merit_frac,deltazwt4,2);
% 
%     save('../data/deltazwt2.mat','deltazwt1_2deg','deltazwt2_2deg', ...
%                                  'deltazwt3_2deg','deltazwt4_2deg');
% end
% 
% plot_exs4(lon,lat,deltazwt1_2deg, deltazwt2_2deg, deltazwt3_2deg, deltazwt4_2deg,...
%           -0.5, 0.5);

function plot_exs3(lon,lat,a,b,c,cmin,cmax)
    figure; set(gcf,'Position',[10 10 800 1200]);
    subplot(3,1,1);
    imAlpha = ones(size(a));
    imAlpha(isnan(a)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],a,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    subplot(3,1,2);
    imAlpha = ones(size(b));
    imAlpha(isnan(b)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],b,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    subplot(3,1,3);
    imAlpha = ones(size(c));
    imAlpha(isnan(c)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],c,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
end

function plot_exs4(lon,lat,a,b,c,d,cmin,cmax)
    figure; set(gcf,'Position',[10 10 800 1200]);
    subplot(2,2,1);
    imAlpha = ones(size(a));
    imAlpha(isnan(a)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],a,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    subplot(2,2,2);
    imAlpha = ones(size(b));
    imAlpha(isnan(b)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],b,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    subplot(2,2,3);
    imAlpha = ones(size(c));
    imAlpha(isnan(c)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],c,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    subplot(2,2,4);
    imAlpha = ones(size(d));
    imAlpha(isnan(d)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],d,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
end

% cmap = getPyPlot_cMap('BuPu');
% X = [nanmean(CTL1.zwtyr,2) nanmean(FUT1.zwtyr,2)];
% figure;
% hist3(X,'CdataMode','auto','Nbins',[200,200],'LineStyle','none');
% view(2);colormap(cmap);colorbar; ylim([0 80]); xlim([0 80]); caxis([0 50]);
% colorbar;
% hold on;
% xlabel('CTL');
% ylabel('FUT');
