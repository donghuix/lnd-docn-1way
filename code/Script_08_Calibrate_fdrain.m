clear;close all;clc;

addpath('/Users/xudo627/donghui/mylib/m/');

runs    = {'Calibration01_OCN2LND_sur_sub_coupling_22493fc.2022-11-14-131718', ...
           'Calibration02_OCN2LND_sur_sub_coupling_22493fc.2022-11-21-100919', ...
           'Calibration03_OCN2LND_sur_sub_coupling_22493fc.2022-11-17-115402', ...
           'Calibration04_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-102621', ...
           'Calibration05_OCN2LND_sur_sub_coupling_22493fc.2022-11-15-101154', ...
           'Calibration06_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-104615', ...
           'Calibration07_OCN2LND_sur_sub_coupling_22493fc.2022-11-18-140955', ...
           'Calibration08_OCN2LND_sur_sub_coupling_22493fc.2022-11-21-095422'};

tags    = {'fd=0.1','fd=0.2','fd=0.5','fd=1.0','fd=2.5','fd=5.0','fd=10.0','fd=20'};
fds     = [0.1 0.2 0.5 1 2.5 5 10 20];

load('../fan/fan8th.mat');

figure;
plot(1:128,ones(128,1).*nanmean(fan8th),'k--','LineWidth',2); hold on; grid on;
zwtsim = NaN(size(fan8th,1),length(tags));

for i = 1 : length(tags)
    load(['../data/outputs/' tags{i} '_zwt_annual.mat'],'zwtyr');
    if strcmp(tags{i},'fd=2.5')
        zwt_def = nanmean(zwtyr(:,109:end),2);
    end
    zwtsim(:,i) = nanmean(zwtyr(:,109:end),2);
    if mod(i,2) == 0
        semilogy(-nanmean(zwtyr,1),':','LineWidth',3); 
    else
        semilogy(-nanmean(zwtyr,1),'-','LineWidth',3); 
    end
end
legend(['Fan et al' tags],'FontSize',14,'FontWeight','bold');

if exist('../data/Calibrated_fdrain.mat','file')
    
    load('../data/Calibrated_fdrain.mat');
    
else
    
    fd_cal  = NaN(size(zwtsim,1),1);
    %zwt_cal = NaN(size(zwtsim,1),1);
    fan8th  = -fan8th;
    for i = 1 : size(zwtsim)
        disp([num2str(i) '/' num2str(size(zwtsim,1))]);
        if ~isnan(fan8th(i)) && ~isnan(zwtsim(i,1))
            if fan8th(i) > max(zwtsim(i,:))
                fd_cal(i) = 0.1;
            elseif fan8th(i) < min(zwtsim(i,:))
                fd_cal(i) = 20;
            else
                [a, b] = unique(zwtsim(i,:));
                fd_cal(i) = interp1(zwtsim(i,b),fds(b),fan8th(i));
            end

            d = abs(zwtsim(i,:) - fan8th(i));
            ind = find(d == min(d));
            %zwt_cal(i) = zwtsim(i,ind(1));
        else
            fd_cal(i) = 2.5;
        end
    end

    save('../data/Calibrated_fdrain.mat','fd_cal');

end

load('../data/outputs/fd=cal_zwt_annual.mat','zwtyr','zwt_perchyr');
zwt_cal      = nanmean(zwtyr(:,109:end),2);
zwt_perchcal = nanmean(zwt_perchyr(:,109:end),2);

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

cmap = getPyPlot_cMap('BuPu');

load('../data/outputs/Calibration01_zwt.mat');
load('../data/domain_global_coastline_merit_90m.mat');
% zwtdef = nanmean(zwt(:,100:end),2);
[lon,lat,zwtcal_1deg] = upscale_data(merit_x,merit_y,ones(length(zwt_cal),1),zwt_cal,1);
[lon,lat,fan1deg]     = upscale_data(merit_x,merit_y,ones(length(fan8th),1),fan8th,1);
[lon,lat,fd1deg]      = upscale_data(merit_x,merit_y,ones(length(fan8th),1),fd_cal,1);
figure;
imAlpha = ones(size(zwtcal_1deg));
imAlpha(isnan(zwtcal_1deg - (-fan1deg))) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],zwtcal_1deg - (-fan1deg),'AlphaData',imAlpha); 
colormap(blue2red(11)); colorbar; hold on; caxis([-6 6]); 
set(gca,'YDir','normal');
ylim([-60 90]);
ind1 = find(zwt_cal > fan8th & (zwt_cal > 8.7 & zwt_cal < 8.9));
plot(merit_x(ind1),merit_y(ind1),'g.'); hold on;
ind2 = find(zwt_cal < fan8th & zwt_cal > 20);
plot(merit_x(ind2),merit_y(ind2),'r.'); hold on;

figure;
subplot(2,1,1);
imAlpha = ones(size((-fan1deg)));
imAlpha(isnan((-fan1deg))) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],(-fan1deg),'AlphaData',imAlpha); 
colormap(jet); colorbar; hold on; caxis([0 80]); 
set(gca,'YDir','normal');
ylim([-60 60]);

subplot(2,1,2);
imAlpha = ones(size(fd1deg));
imAlpha(isnan(fd1deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],fd1deg,'AlphaData',imAlpha); 
colormap(jet); colorbar; hold on; caxis([0.1 5]); 
set(gca,'YDir','normal');
ylim([-60 60]);

zwt_cal(merit_y >= 60) = NaN; 
zwt_def(merit_y >= 60) = NaN;
X = [-fan8th zwt_cal];
figure;
hist3(X,'CdataMode','auto','Nbins',[250,80],'LineStyle','none');
view(2);colormap(cmap);colorbar; ylim([0 80]); xlim([0 80]); caxis([0 300]);
colorbar;
hold on;
h = plot3([0 80],[0 80],[2500 2500],'g--','LineWidth',2);
xlabel('Fan et al','FontSize',15,'FontWeight','bold');
ylabel('Calibration','FontSize',15,'FontWeight','bold');

ind = find(zwt_cal <= 25);

[R2(1),RMSE(1),NSE(1),PBIAS(1)] = estimate_evaluation_metric(-fan8th(ind),zwt_def(ind));
[R2(2),RMSE(2),NSE(2),PBIAS(2),MSE,NSE1] = estimate_evaluation_metric(-fan8th(ind),zwt_cal(ind));


[xv,yv] = xc2xv(merit_x,merit_y,1/8,1/8,false);