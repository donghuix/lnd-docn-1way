clear;close all;clc;

addpath('/Users/xudo627/donghui/mylib/m/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

exs1 = {'ctl-ctl','ctl-fut','fut-ctl','fut-fut'};
tag1 = {'ctl_ctl','ctl_fut','fut_ctl','fut_fut'};

load('../data/domain_global_coastline_merit_90m.mat');
load('merit_std.mat');
[xv,yv] = xc2xv(merit_x,merit_y,1/8,1/8,false);

idx = 6 : 35;
AMR  = struct([]); zwt  = struct([]);
load coastlines.mat; load('../data/greenland.mat'); load('../fan/fan8th.mat');
gl_mask   = inpoly2([merit_x merit_y],[x y]);
ind_small = merit_frac < 0.20;

for i = 1 : length(exs1)
    disp(['Read ' exs1{i}]);
    zwtyr(1).(tag1{i})= load(['../data/outputs/' exs1{i} '_zwt_annual.mat']);
    AMR(1).(tag1{i})  = load(['../data/outputs/' exs1{i} '_AMR.mat']);
    zwt(1).(tag1{i})  = max(zwtyr(1).(tag1{i}).zwtyr(:,idx),[],2);
end

foc_zwt_SLR  = zwt.fut_fut - zwt.fut_ctl;
ind_rm  = abs(foc_zwt_SLR) > 1;

for i = 1 : length(exs1)
    AMR(1).(tag1{i}).AMTR(gl_mask | ind_small | ind_rm,:) = [];
    AMR(1).(tag1{i}).AMSR(gl_mask | ind_small | ind_rm,:) = [];
    AMR(1).(tag1{i}).AMDR(gl_mask | ind_small | ind_rm,:) = [];
end
xv(:,gl_mask | ind_small | ind_rm) = [];
yv(:,gl_mask | ind_small | ind_rm) = [];
merit_x(gl_mask | ind_small | ind_rm) = [];
merit_y(gl_mask | ind_small | ind_rm) = [];
load('../data/map1deg.mat');


% 
% [axs, cbs] = plot_exs2(lon,lat,foc1_1deg.*86400,foc3_1deg.*86400,[-5 -5],[5 5],{'SLR','ATM'});
% 
% figure;
% imagesc(foc3_1deg.*86400); colormap("jet"); colormap(blue2red(121));clim([-2 2]);
% 
% figure;
% imagesc(foc3_1deg.*86400); colormap("jet"); colormap(blue2red(121));clim([-10 10]);

figure; set(gcf,'Position',[10 10 1200 400]);
% foc1 = nanmean(AMR.fut_fut.AMTR - AMR.fut_ctl.AMTR,2);
% foc2 = nanmean(AMR.fut_ctl.AMTR - AMR.ctl_ctl.AMTR,2);
% foc3 = nanmean(AMR.fut_fut.AMTR - AMR.ctl_ctl.AMTR,2);
% foc1_1deg = mapping_1d_to_2d(foc1,mapping,map_1dto2d,size(lon));
% foc2_1deg = mapping_1d_to_2d(foc2,mapping,map_1dto2d,size(lon));
% foc3_1deg = mapping_1d_to_2d(foc3,mapping,map_1dto2d,size(lon));
% subplot(1,3,1);
% [f,xi] = ksdensity(foc1_1deg(:).*86400,'Function','cdf');
% plot(xi,f,'b-','LineWidth',1.5); hold on; grid on;
% [f,xi] = ksdensity(foc2_1deg(:).*86400,'Function','cdf');
% plot(xi,f,'r-','LineWidth',1.5);
% [f,xi] = ksdensity(foc3_1deg(:).*86400,'Function','cdf');
% plot(xi,f,'k--','LineWidth',1.5); 
% xlim([-100 100]);

foc1 = nanmean(AMR.fut_fut.AMSR - AMR.fut_ctl.AMSR,2);
foc2 = nanmean(AMR.fut_ctl.AMSR - AMR.ctl_ctl.AMSR,2);
foc3 = nanmean(AMR.fut_fut.AMSR - AMR.ctl_ctl.AMSR,2);
foc1_1deg = mapping_1d_to_2d(foc1,mapping,map_1dto2d,size(lon));
foc2_1deg = mapping_1d_to_2d(foc2,mapping,map_1dto2d,size(lon));
foc3_1deg = mapping_1d_to_2d(foc3,mapping,map_1dto2d,size(lon));
subplot(1,2,1);
[f,xi] = ksdensity(foc1_1deg(:).*86400,'Function','cdf');
plot(xi,f,'b-','LineWidth',2); hold on; grid on;
[f,xi] = ksdensity(foc2_1deg(:).*86400,'Function','cdf');
plot(xi,f,'r-','LineWidth',2);
[f,xi] = ksdensity(foc3_1deg(:).*86400,'Function','cdf');
plot(xi,f,'k--','LineWidth',2); 
xlim([-100 100]);
set(gca,'FontSize',14);
add_title(gca,'(a). Maximum daily surface runoff');

foc1 = nanmean(AMR.fut_fut.AMTR - AMR.fut_ctl.AMTR,2);
foc2 = nanmean(AMR.fut_ctl.AMTR - AMR.ctl_ctl.AMTR,2);
foc3 = nanmean(AMR.fut_fut.AMTR - AMR.ctl_ctl.AMTR,2);

foc1_1deg = mapping_1d_to_2d(foc1,mapping,map_1dto2d,size(lon));
foc2_1deg = mapping_1d_to_2d(foc2,mapping,map_1dto2d,size(lon));
foc3_1deg = mapping_1d_to_2d(foc3,mapping,map_1dto2d,size(lon));
leg = legend('SLR-induced changes','ATM-induced changes','Total changes');
leg.FontSize = 14; %leg.FontWeight = 'bold';
leg.Location = 'northwest';

subplot(1,2,2);
[f,xi] = ksdensity(foc1_1deg(:).*86400,'Function','cdf');
plot(xi,f,'b-','LineWidth',2); hold on; grid on;
[f,xi] = ksdensity(foc2_1deg(:).*86400,'Function','cdf');
plot(xi,f,'r-','LineWidth',2);
[f,xi] = ksdensity(foc3_1deg(:).*86400,'Function','cdf');
plot(xi,f,'k--','LineWidth',2); 
xlim([-100 100]);
set(gca,'FontSize',14);
add_title(gca,'(b). Maximum daily total runoff');

han=axes(gcf,'visible','off'); 
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Frequency','FontSize',15,'FontWeight','bold');
xlabel(han,'Changes [mm/day]','FontSize',15,'FontWeight','bold');
han.Position(1) = han.Position(1) - 0.015;
han.Position(2) = han.Position(2) - 0.015;
han.Position(3) = 0.80;

catogrory = 2;
SubR   = GetWorldSubRegions(catogrory,[]);
lon1d = lon(map_1dto2d); lat1d = lat(map_1dto2d);
for i = 1 : length(SubR)
    in = inpolygon(lon1d,lat1d,SubR(i).X,SubR(i).Y);
    Sub1d(in) = i;
end

foc1_1deg = foc1_1deg(map_1dto2d);
foc2_1deg = foc2_1deg(map_1dto2d);
foc3_1deg = foc3_1deg(map_1dto2d);
figure;
for i = 1 : length(SubR)
    subplot(4,4,i)
    [f,xi] = ksdensity(foc1_1deg(Sub1d == i).*86400,'Function','cdf');
    plot(xi,f,'b-','LineWidth',1.5); hold on; grid on;
    [f,xi] = ksdensity(foc2_1deg(Sub1d == i).*86400,'Function','cdf');
    plot(xi,f,'r-','LineWidth',1.5);
    [f,xi] = ksdensity(foc3_1deg(Sub1d == i).*86400,'Function','cdf');
    plot(xi,f,'k--','LineWidth',1.5); 
    xlim([-100 100]);
    add_title(gca,SubR(i).Name);
end

figure; set(gcf,'Position',[10 10 1200 600]);
colors = distinguishable_colors(16);

S = m_shaperead('/Users/xudo627/DATA/natural_earth_vector/10m_physical/ne_10m_coastline');
for i = 1 : length(S.ncst)
    plot(gca,S.ncst{i}(:,1),S.ncst{i}(:,2),'k-','LineWidth',1); hold on
end
for i = 1 : length(SubR)
    plot(SubR(i).X,SubR(i).Y,'-','Color',colors(i,:),'LineWidth',2); hold on;
    text(SubR(i).X(1),SubR(i).Y(4)-2,SubR(i).Name,'FontSize',15,'Color',colors(i,:));
end
xlim([-180 180]); ylim([-60 90]);