clear;close all;clc;

re = 6.37122e6;% Earth radius

addpath('/Users/xudo627/developments/getPanoply_cMap/');
cmap = getPanoply_cMap('NEO_modis_lst');

GCM = {'CMCC-CM2-VHR4','EC-Earth3P-HR','GFDL-CM4C192-SST','HadGEM3-GC31-HM-SST','HadGEM3-GC31-HM'};

load('../data/domain.mat');
load('../data/ICOM_bathtub_ele.mat');

aream2 = NaN(length(xc),1);

for i = 1 : length(aream2)
    aream2(i) = areaint(yv(:,i),xv(:,i))*4*pi.*(re^2); 
end

t1 = datenum(2016,1,1,0,0,0);
t2 = datenum(2050,12,31,0,0,0);
t  = t1 : t2;
[yrs,mos,das] = datevec(t);

figure;
for i = 1 : length(GCM)
    disp(GCM{i});
    load(['../results/Inund_daily_' GCM{i} '.mat']);
    if size(inund_daily,2) ~= length(yrs)
        inund_daily(:,size(inund_daily,2)+1:length(yrs)) = NaN;
    end
    inund_yr = NaN(length(xc),2050-2016+1);
    for iy = 2016 : 2050
        tmp = inund_daily(:, yrs == iy);
        inund_yr(:,iy - 2015) = nanmean(tmp,2);
    end
    
    inund_area = nansum(inund_yr.* aream2 .* frac,1)  ./ 1e6;
    plot(2016:2050,inund_area,'-','LineWidth',2); hold on; grid on;
end
leg = legend(GCM,'FontSize',15,'FontWeight','bold');
ylabel('Inundation area [km^{2}]','FontSize',14,'FontWeight','bold');

yyaxis right;
ylim([min(nanmean(inund_yr)) max(nanmean(inund_yr))]);

figure;
patch(xv,yv,nanmean(inund_yr,2),'LineStyle','none'); hold on;
colormap(cmap); colorbar;
