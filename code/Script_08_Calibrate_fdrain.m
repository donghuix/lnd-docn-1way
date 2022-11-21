clear;close all;clc;

runs    = {'Calibration03_OCN2LND_sur_sub_coupling_22493fc.2022-11-17-115402', ...
           'Calibration04_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-102621', ...
           'Calibration06_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-104615', ...
           'Calibration07_OCN2LND_sur_sub_coupling_22493fc.2022-11-18-140955'};
tags    = {'fd=0.2','fd=0.5','fd=5.0','fd=10.'};
load('../fan/fan8th.mat');

figure;
plot(1:128,-ones(128,1).*nanmean(fan8th),'k--','LineWidth',2); hold on; grid on;
for i = 1 : length(tags)
    load(['../data/outputs/' tags{i} '_zwt_annual.mat'],'zwtyr');
    semilogy(nanmean(zwtyr,1),'-','LineWidth',2); 
end
legend(['Fan et al' tags],'FontSize',14,'FontWeight','bold');