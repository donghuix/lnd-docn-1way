clear;close all;clc;

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

fd_cal  = NaN(size(zwtsim,1),1);
zwt_cal = NaN(size(zwtsim,1),1);
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
        zwt_cal(i) = zwtsim(i,ind(1));
    else
        fd_cal(i) = 2.5;
    end
end

save('../data/Calibrated_fdrain.mat','fd_cal');

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

[R2(1),RMSE(1),NSE(1),PBIAS(1),MSE,NSE1] = estimate_evaluation_metric(fan8th,zwt_def);
[R2(2),RMSE(2),NSE(2),PBIAS(2),MSE,NSE1] = estimate_evaluation_metric(fan8th,zwt_cal);

% X = [fan8th zwt_cal];
% figure;
% hist3(X,'CdataMode','auto','Nbins',[100,250],'LineStyle','none');
% view(2);colormap(jet);colorbar; ylim([0 80]); xlim([0 80]); caxis([0 100]);
% colorbar;

% load('../data/outputs/Calibration01_zwt.mat');
% load('../data/domain_global_coastline_merit_90m.mat');
% zwtdef = nanmean(zwt(:,100:end),2);
% [lon,lat,zwtdef_1deg] = upscale_data(merit_x,merit_y,ones(length(zwtdef),1),zwtdef,1);
% figure;
% imAlpha = ones(size(zwtdef_1deg));
% imAlpha(isnan(zwtdef_1deg)) = 0;
% imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],-zwtdef_1deg,'AlphaData',imAlpha); 
% colormap(jet); colorbar; hold on; caxis([-100 0]); 
% set(gca,'YDir','normal');
% ylim([-60 90]);