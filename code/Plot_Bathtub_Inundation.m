clear;close all;clc;

addpath('/Users/xudo627/Developments/inpoly/');
addpath('/Users/xudo627/Developments/mylib/m/');
addpath('/Users/xudo627/Developments/getPanoply_cMap/');

CTL = load('../data/outputs/GFDL-CM4C192-SST_sshyr_CTL.mat');
load('../data/outputs/GFDL-CM4C192-SST_sshyr_FUT.mat');
load('../data/domain_global_coastline_merit_90m.mat');
load coastlines.mat; load('../data/greenland.mat'); load('../fan/fan8th.mat');
gl_mask   = inpoly2([merit_x merit_y],[x y]);
ind_small = merit_frac < 0.20;

exs1 = {'ctl-ctl','ctl-fut','fut-ctl','fut-fut'};
tag1 = {'ctl_ctl','ctl_fut','fut_ctl','fut_fut'};

zwt  = struct([]); zwtyr = struct([]);
idx = 6 : 35;

for i = 1 : length(exs1)
    disp(['Read ' exs1{i}]);
    zwtyr(1).(tag1{i})= load(['../data/outputs/' exs1{i} '_zwt_annual.mat']);
    zwt(1).(tag1{i})  = max(zwtyr(1).(tag1{i}).zwtyr(:,idx),[],2);
end
foc_zwt_SLR  = zwt.fut_fut - zwt.fut_ctl;
ind_rm  = abs(foc_zwt_SLR) > 1;

Inundyr = Inundyr - nanmean(CTL.Inundyr,2);
load('../data/inund_ann.mat');
inund_ann = inund_ann - nanmean(CTL.Inundyr,2);
CTL.Inundyr = CTL.Inundyr -  nanmean(CTL.Inundyr,2);
Inundyr(gl_mask | ind_small | ind_rm,:) = [];
CTL.Inundyr(gl_mask | ind_small | ind_rm,:) = [];
merit_area(gl_mask | ind_small | ind_rm) = [];
merit_frac(gl_mask | ind_small | ind_rm) = [];
inund_ann(gl_mask | ind_small | ind_rm,:,:) = [];
area = merit_area.*merit_frac;
wght = area./sum(area);
nyrs = size(Inundyr,2);

Inundyr(Inundyr < 0) = 0;
CTL.Inundyr(CTL.Inundyr < 0) = 0;
inund0 = nansum(CTL.Inundyr.*repmat(merit_area,1,64).*repmat(merit_frac,1,64))./1e6; 
inund  = nansum(Inundyr.*repmat(merit_area,1,nyrs).*repmat(merit_frac,1,nyrs))./1e6; %[m^2] -> [km^{2}]
inund_enb = NaN(35,5);
for i = 1 : 5
    inund_enb(:,i) = nansum(inund_ann(:,:,i).*repmat(merit_area,1,35).*repmat(merit_frac,1,35))./1e6; 
end
inund_enb(:,6) = inund;
ssh   = nanmean(SSHyr);

coastarea = nansum(merit_area.*merit_frac)./1e6;
figure;
plot(ssh,inund,'bo'); grid on;

load('../data/map1deg.mat');
inund_ctl1deg = mapping_1d_to_2d(CTL.Inundyr(:,end).*merit_frac,mapping,map_1dto2d,size(lon));
inund_fut1deg = mapping_1d_to_2d(Inundyr(:,end).*merit_frac,mapping,map_1dto2d,size(lon));

cmap = getPanoply_cMap('NEO_imperv_surf');
cmap = create_nonlinear_cmap(cmap,0,200,200,3);

figure;
[xv,yv,area1deg] = xc2xv(lon,lat,1,1,true);

[axs, cbs] = plot_exs2(lon,lat,inund_fut1deg.*100,inund_ctl1deg*100,[0 0],[5 5],{'(a). % of grid cell below SLR by 2050',' '});
colormap(cmap);
delete(axs(2));
ax2 = axes('Position',[axs(1).Position(1) axs(1).Position(2) 0.2 0.2]);
inBetween = [min(inund_enb,[],2)', flipud(max(inund_enb,[],2))'];
fill([2016:2050, 2050:-1:2016],inBetween, 'r','FaceAlpha',0.2,'EdgeColor','none'); hold on;
plot(2016:2050,inund,'r-','LineWidth',2); grid on; hold on;
plot(1981:2014,inund0(31:end),'k-','LineWidth',2); grid on; 
%plot(2016:2050,inund_enb,'--','LineWidth',2);
set(gca,'FontSize',13);
ylabel('[km^{2}]','FontSize',14,'FontWeight','bold');
cbs(1).FontSize=14; cbs(1).Label.String = '[%]'; cbs(1).Label.FontSize = 15; cbs(1).Label.FontWeight = 'bold';
[slope,  intercept] = sens_slope(inund(6:end)');
[slope0, intercept] = sens_slope(inund0(31:end)');
slope  = round(slope);
slope0 = round(slope0);
add_title(ax2,'(b)',20,'in');

dim1 = [axs(1).Position(1)+0.11 axs(1).Position(2) + 0.040   0.1 0.05];
t1 = annotation("textbox",dim1,'String',[num2str(slope)  ' km^{2}/yr'],'FitBoxToText','on','EdgeColor','none');
t1.Color = 'r'; t1.FontWeight = 'bold'; t1.FontSize = 14;

dim2 = [axs(1).Position(1) axs(1).Position(2)+0.01 0.1 0.05];
t2 = annotation("textbox",dim2,'String',[num2str(slope0) ' km^{2}/yr'],'FitBoxToText','on','EdgeColor','none');
t2.Color = 'k'; t2.FontWeight = 'bold'; t2.FontSize = 14;

num = mean(max(inund_enb,[],2)' - min(inund_enb,[],2)')/mean(inund)*100;
fprintf(['The ensemble inundaiton is about ' num2str(num) '% of the mean projected inundation\n']);

save('../plot_scripts/Figure4_data.mat','xv','yv','area1deg','lon','lat','inund_fut1deg', ...
                                      'inund_ctl1deg','inund_enb','inund','inund0','cmap','-v7.3');

%exportgraphics(gcf,'../writing/Figure_4.pdf','Resolution',400);
%exportgraphics(gcf,'../writing/Bathtub_Inundation.pdf','ContentType','vector');