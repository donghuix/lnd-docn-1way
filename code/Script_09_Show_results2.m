clear;close all;clc;

addpath('/Users/xudo627/donghui/mylib/m/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

read_data = 1;
res       = 2;

exs1 = {'ctl-ctl','ctl-fut','fut-ctl','fut-fut'};
tag1 = {'ctl_ctl','ctl_fut','fut_ctl','fut_fut'};

load('../data/domain_global_coastline_merit_90m.mat');
[xv,yv] = xc2xv(merit_x,merit_y,1/8,1/8,false);

zwt = struct([]);
rst = struct([]);

load('../data/greenland.mat');
gl_mask   = inpoly2([merit_x merit_y],[x y]);
ind_small = merit_frac < 0.05;

idx = 6 : 35;

for i = 1 : length(exs1)
    disp(['Read ' exs1{i}]);
    rst(1).(tag1{i}) = load(['../data/outputs/' exs1{i} '_results_annual.mat']);
end

for i = 1 : length(exs1)
    disp(['Read ' exs1{i}]);
    zwt(1).(tag1{i}) = load(['../data/outputs/' exs1{i} '_zwt_annual.mat']);
end

zwt0 = nanmean(zwt.ctl_ctl.zwtyr(:,idx),2); zwt0(gl_mask | ind_small) = [];
zwt1 = nanmean(zwt.ctl_fut.zwtyr(:,idx),2); zwt1(gl_mask | ind_small) = [];
zwt2 = nanmean(zwt.fut_ctl.zwtyr(:,idx),2); zwt2(gl_mask | ind_small) = [];
zwt3 = nanmean(zwt.fut_fut.zwtyr(:,idx),2); zwt3(gl_mask | ind_small) = [];

zwt.ctl_ctl.zwtyr(gl_mask | ind_small,:) = [];
zwt.fut_fut.zwtyr(gl_mask | ind_small,:) = [];
zwt.fut_ctl.zwtyr(gl_mask | ind_small,:) = [];
zwt.ctl_fut.zwtyr(gl_mask | ind_small,:) = [];

rst.ctl_ctl.h2osoisur(gl_mask | ind_small,:) = [];
rst.fut_fut.h2osoisur(gl_mask | ind_small,:) = [];
rst.fut_ctl.h2osoisur(gl_mask | ind_small,:) = [];
rst.ctl_fut.h2osoisur(gl_mask | ind_small,:) = [];

levels = [2; 5; 10; 20; 40];
area = merit_frac.*merit_area;

figure(1); set(gcf,'Position',[10 10 1400 800]);
figure(2); set(gcf,'Position',[10 10 1400 800]);

for i = 1 : 6
    if i == 1
        ind = find(zwt0 <= levels(i));
    elseif i == 6
        ind = find(zwt0 > levels(i-1));
    else
        ind = find(zwt0 > levels(i-1) & zwt0 <= levels(i));
    end

    zwt_fut_fut = -nansum(zwt.fut_fut.zwtyr(ind,idx).*area(ind),1)./nansum(area(ind));
    zwt_fut_ctl = -nansum(zwt.fut_ctl.zwtyr(ind,idx).*area(ind),1)./nansum(area(ind));
    zwt_ctl_ctl = -nansum(zwt.ctl_ctl.zwtyr(ind,idx).*area(ind),1)./nansum(area(ind));
    zwt_ctl_fut = -nansum(zwt.ctl_fut.zwtyr(ind,idx).*area(ind),1)./nansum(area(ind));

    soi_fut_fut = nansum(rst.fut_fut.h2osoisur(ind,idx).*area(ind),1)./nansum(area(ind));
    soi_fut_ctl = nansum(rst.fut_ctl.h2osoisur(ind,idx).*area(ind),1)./nansum(area(ind));
    soi_ctl_ctl = nansum(rst.ctl_ctl.h2osoisur(ind,idx).*area(ind),1)./nansum(area(ind));
    soi_ctl_fut = nansum(rst.ctl_fut.h2osoisur(ind,idx).*area(ind),1)./nansum(area(ind));

    qch_fut_fut = nansum(rst.fut_fut.qcharge(ind,idx).*area(ind),1)./nansum(area(ind));
    qch_fut_ctl = nansum(rst.fut_ctl.qcharge(ind,idx).*area(ind),1)./nansum(area(ind));
    qch_ctl_ctl = nansum(rst.ctl_ctl.qcharge(ind,idx).*area(ind),1)./nansum(area(ind));
    qch_ctl_fut = nansum(rst.ctl_fut.qcharge(ind,idx).*area(ind),1)./nansum(area(ind));
    
    figure(1)
    subplot_tight(2,3,i,[0.06 0.04]);
    plot(1985:2014,soi_ctl_ctl,'k-','LineWidth',2); hold on; grid on;
    plot(2021:2050,soi_fut_ctl,'b--','LineWidth',2); 

    figure(2)
    subplot_tight(2,3,i,[0.06 0.04]);
    plot(1985:2014,qch_ctl_ctl,'k-','LineWidth',2); hold on; grid on;
    plot(1985:2014,qch_ctl_fut,'g--','LineWidth',2); 
    plot(2021:2050,qch_fut_ctl,'b--','LineWidth',2); 
    plot(2021:2050,qch_fut_fut,'r-','LineWidth',2); 

end