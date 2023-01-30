clear;close all;clc;

addpath('/Users/xudo627/donghui/mylib/m/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

write_calibration = 0;
use_calibration   = 1;
runs    = {'Calibration01_OCN2LND_sur_sub_coupling_22493fc.2022-11-14-131718', ...
           'Calibration02_OCN2LND_sur_sub_coupling_22493fc.2022-11-21-100919', ...
           'Calibration03_OCN2LND_sur_sub_coupling_22493fc.2022-11-17-115402', ...
           'Calibration04_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-102621', ...
           'Calibration05_OCN2LND_sur_sub_coupling_22493fc.2022-11-15-101154', ...
           'Calibration06_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-104615', ...
           'Calibration07_OCN2LND_sur_sub_coupling_22493fc.2022-11-18-140955', ...
           'Calibration08_OCN2LND_sur_sub_coupling_22493fc.2022-11-21-095422'};

tags    = {'fd=2.5','fd=0.1','fd=0.2','fd=0.3','fd=0.4','fd=0.5','fd=1.0','fd=5.0','fd=10.0','fd=20'};
fds     = [2.5 0.1 0.2 0.3 0.4 0.5 1 5 10 20];

% tags = tags(1:8);
% fds  = fds(1:8);
% tags(9) = [];
% fds(9)  = [];
load('../fan/fan8th.mat');

figure;
plot(1:128,ones(128,1).*nanmean(-fan8th),'k--','LineWidth',2); hold on; grid on;
zwtsim = NaN(size(fan8th,1),length(tags));
zwtglobal = NaN(128,length(tags));

for i = 1 : length(tags)
    load(['../data/outputs/' tags{i} '_zwt_annual.mat'],'zwtyr');
    if strcmp(tags{i},'fd=2.5')
        zwt_def = nanmean(zwtyr(:,109:end-5),2);
    end
    zwtsim(:,i) = nanmean(zwtyr(:,109:end-5),2);
    zwtglobal(:,i) = -nanmean(zwtyr,1);
    if mod(i,2) == 0
        semilogy(-nanmean(zwtyr(:,1:end-5),1),':','LineWidth',3); 
    else
        semilogy(-nanmean(zwtyr(:,1:end-5),1),'-','LineWidth',3); 
    end
end
legend(['Fan et al' tags],'FontSize',14,'FontWeight','bold');

if exist('../data/Calibrated_fdrain.mat','file')
    
    load('../data/Calibrated_fdrain.mat');
    
else
    
    fd_cal  = NaN(size(zwtsim,1),1);
    zwt_cal = NaN(size(zwtsim,1),1);
    fan8th  = -fan8th;
    for i = 1 : size(zwtsim)
        disp([num2str(i) '/' num2str(size(zwtsim,1))]);
        if ~isnan(fan8th(i)) && ~isnan(zwtsim(i,1))
            if fan8th(i) > max(zwtsim(i,:))
                fd_cal(i) = 0.1;
                zwt_cal(i) =  max(zwtsim(i,:));
            elseif fan8th(i) < min(zwtsim(i,:))
                fd_cal(i) = 20;
                zwt_cal(i) =  min(zwtsim(i,:));
            else
                [a, b] = unique(zwtsim(i,:));
                fd_cal(i)  = interp1(zwtsim(i,b),fds(b),fan8th(i));
                zwt_cal(i) = interp1(fds(b),zwtsim(i,b),fd_cal(i));
            end

            d = abs(zwtsim(i,:) - fan8th(i));
            ind = find(d == min(d));
            %zwt_cal(i) = zwtsim(i,ind(1));
        else
            fd_cal(i) = 2.5;
        end
    end
    
    if write_calibration
        save('../data/Calibrated_fdrain.mat','fd_cal');
    end

end

load('../data/domain_global_coastline_merit_90m.mat');
if use_calibration
    load('../data/outputs/fd=cal_zwt_annual.mat','zwtyr','zwt_perchyr');
    zwt_cal      = nanmean(zwtyr(:,109:end),2);
    zwt_perchcal = nanmean(zwt_perchyr(:,109:end),2);
    load('../data/greenland.mat');
    gl_mask   = inpoly2([merit_x merit_y],[x y]);
    ind_small = merit_frac < 0.05;
    zwt_cal(gl_mask | ind_small) = [];
    fan8th(gl_mask | ind_small) = [];
    merit_x(gl_mask | ind_small) = [];
    merit_y(gl_mask | ind_small) = [];
    merit_frac(gl_mask | ind_small) = [];
    merit_topo(gl_mask | ind_small) = [];
    zwt_def(gl_mask | ind_small) = [];
end

fan8th = -fan8th;

figure;
plot(1:128,ones(128,1).*nanmean(fan8th),'k--','LineWidth',2); hold on; grid on;
plot(nanmean(zwtyr,1),'r-','LineWidth',2);

figure;
plot(fan8th, zwt_cal,'b.'); hold on; grid on;
plot([0 80],[0 80],'r-','LineWidth',2); 
ylim([0 250]); xlim([0 250]);
xlabel('Fan et al','FontSize',15,'FontWeight','bold');
ylabel('Calibration','FontSize',15,'FontWeight','bold');

figure;
plot(fan8th, zwt_def,'b.'); hold on; grid on;
plot([0 80],[0 80],'r-','LineWidth',2); 
ylim([0 250]); xlim([0 250]);
xlabel('Fan et al','FontSize',15,'FontWeight','bold');
ylabel('Default','FontSize',15,'FontWeight','bold');

cmap = getPyPlot_cMap('BuPu',10);

% load('../data/outputs/Calibration01_zwt.mat');
% % zwtdef = nanmean(zwt(:,100:end),2);
if exist('../data/map1deg.mat','file')
    load('../data/map1deg.mat');
    zwtcal_1deg = mapping_1d_to_2d(zwt_cal,mapping,map_1dto2d,size(lon));
    fan1deg = mapping_1d_to_2d(fan8th,mapping,map_1dto2d,size(lon));
else
    [lon,lat,zwtcal_1deg] = upscale_data(merit_x,merit_y,merit_frac,zwt_cal,1);
    [~,~,fan1deg,mapping,map_1dto2d] = upscale_data(merit_x,merit_y,merit_frac,fan8th,1);
    save('../data/map1deg.mat','mapping','map_1dto2d','lon','lat');
end
% [lon,lat,fd1deg]      = upscale_data(merit_x,merit_y,ones(length(fan8th),1),fd_cal,1);
% ind1 = find(zwt_cal > fan8th & (zwt_cal > 8.7 & zwt_cal < 8.9));
% plot(merit_x(ind1),merit_y(ind1),'g.'); hold on;
% ind2 = find(zwt_cal < fan8th & zwt_cal > 20);
% plot(merit_x(ind2),merit_y(ind2),'r.'); hold on;
% 
% figure;
% subplot(2,1,1);
% imAlpha = ones(size((-fan1deg)));
% imAlpha(isnan((-fan1deg))) = 0;
% imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],fan1deg,'AlphaData',imAlpha); 
% colormap(jet); colorbar; hold on; caxis([0 80]); 
% set(gca,'YDir','normal');
% ylim([-60 60]);
% 
% subplot(2,1,2);
% imAlpha = ones(size(fd1deg));
% imAlpha(isnan(fd1deg)) = 0;
% imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],fd1deg,'AlphaData',imAlpha); 
% colormap(jet); colorbar; hold on; caxis([0.1 5]); 
% set(gca,'YDir','normal');
% ylim([-60 60]);

clear zwtyr;
clear zwt_perchyr;
cmap(1,:) = 1;
figure; set(gcf,'Position',[10 10 1000 800]);
ax(1) = subplot(2,2,1);
X = [fan8th zwt_cal];
hist3(X,'CdataMode','auto','Nbins',[250,80],'LineStyle','none');
view(2);colormap(gca,cmap); ylim([0 80]); xlim([0 80]); caxis([0 400]);
cb1 = colorbar('east');
hold on;
h = plot3([0 80],[0 80],[2500 2500],'r--','LineWidth',1);
xlabel('Fan et al','FontSize',15,'FontWeight','bold');
ylabel('Calibration','FontSize',15,'FontWeight','bold');
%ind = find(zwt_cal <= 80 & fan8th <= 80);
ind = find(zwt_cal < 250);
[R2(1),RMSE(1),NSE(1),PBIAS(1)] = estimate_evaluation_metric(fan8th(ind),zwt_def(ind));
[R2(2),RMSE(2),NSE(2),PBIAS(2)] = estimate_evaluation_metric(fan8th(ind),zwt_cal(ind));
R2   = round(R2,2);
RMSE = round(RMSE,2);

pos1 = ax(1).Position;
dim = [pos1(1) pos1(2)+pos1(4)-0.1 0.1 0.1];
str = ['R^{2} = ' num2str(R2(2)) ', RMSE = ' num2str(RMSE(2))];
t1 = annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','none');
t1.FontSize = 14; t1.FontWeight = 'bold';
cb1.Position = [pos1(1)+pos1(3)+0.01 pos1(2) 0.01 pos1(4)];

%axes('Position',[0.425 0.15 0.25 0.25]);
ax(2) = subplot(2,2,2);
hist3(X,'CdataMode','auto','Nbins',[2500,800],'LineStyle','none');
view(2);colormap(gca,cmap); ylim([0 5]); xlim([0 5]); caxis([0 100]);
cb2 = colorbar('east');
hold on;
h = plot3([0 5],[0 5],[2500 2500],'r--','LineWidth',1);
xlabel('Fan et al','FontSize',15,'FontWeight','bold');
ylabel('Calibration ','FontSize',15,'FontWeight','bold');
ind = find(zwt_cal <= 5 & fan8th <= 5);
[R2(1),RMSE(1),NSE(1),PBIAS(1)] = estimate_evaluation_metric(fan8th(ind),zwt_def(ind));
[R2(2),RMSE(2),NSE(2),PBIAS(2)] = estimate_evaluation_metric(fan8th(ind),zwt_cal(ind));
R2   = round(R2,2);
RMSE = round(RMSE,2);

pos2 = ax(2).Position;
dim = [pos2(1) pos2(2)+pos2(4)-0.1 0.1 0.1];
str = ['R^{2} = ' num2str(R2(2)) ', RMSE = ' num2str(RMSE(2))];
t2 = annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','none');
t2.FontSize = 14; t2.FontWeight = 'bold';
cb2.Position = [pos2(1)+pos2(3)+0.01 pos2(2) 0.01 pos2(4)];

ax(3) = axes('Position',[pos1(1) 0.05 pos2(1)+pos2(3)-pos1(1) pos1(2)-0.15]);
imAlpha = ones(size(zwtcal_1deg));
imAlpha(isnan(zwtcal_1deg - fan1deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],zwtcal_1deg - fan1deg,'AlphaData',imAlpha); 
colormap(ax(3),blue2red(13)); cb3 = colorbar('east'); hold on; caxis([-6.5 6.5]); 
set(gca,'YDir','normal');
ylim([-60 90]);
pos3 = ax(3).Position;
cb3.Position = [pos3(1)+pos3(3)+0.01 pos3(2) 0.01 pos3(4)];

figure;
X = [fan8th zwt_def];
hist3(X,'CdataMode','auto','Nbins',[250,80],'LineStyle','none');
view(2);colormap(cmap);colorbar; ylim([0 80]); xlim([0 80]); caxis([0 300]);
colorbar;
hold on;
h = plot3([0 80],[0 80],[2500 2500],'g--','LineWidth',2);
xlabel('Fan et al','FontSize',15,'FontWeight','bold');
ylabel('Default','FontSize',15,'FontWeight','bold');



[xv,yv] = xc2xv(merit_x,merit_y,1/8,1/8,false);