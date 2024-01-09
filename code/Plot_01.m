clear;close all;clc;

addpath('/Users/xudo627/Developments/inpoly/');
addpath('/Users/xudo627/Developments/mylib/m/');
addpath('/Users/xudo627/Developments/getPanoply_cMap/');
addpath('/Users/xudo627/Developments/mylib/data/');

exs1 = {'ctl-ctl','ctl-fut','fut-ctl','fut-fut'};
tag1 = {'ctl_ctl','ctl_fut','fut_ctl','fut_fut'};

load('../data/domain_global_coastline_merit_90m.mat');
load('merit_std.mat');
[xv,yv] = xc2xv(merit_x,merit_y,1/8,1/8,false);

read_mapping = 1;
plot_cities  = 0;

rst = struct([]); zwtyr = struct([]);

qinf = struct([]); qver = struct([]); qlat = struct([]); qrot = struct([]);
h2os = struct([]); tgrd = struct([]); evap = struct([]); zwt  = struct([]);
rain = struct([]);
AMR  = struct([]);
qamr = struct([]);

load coastlines.mat; load('../data/greenland.mat'); load('../fan/fan8th.mat');
gl_mask   = inpoly2([merit_x merit_y],[x y]);
ind_small = merit_frac < 0.20;

idx = 6 : 35;

for i = 1 : length(exs1)
    disp(['Read ' exs1{i}]);
    rst(1).(tag1{i})  = load(['../data/outputs/' exs1{i} '_results_annual.mat']);
    zwtyr(1).(tag1{i})= load(['../data/outputs/' exs1{i} '_zwt_annual.mat']);
    AMR(1).(tag1{i})  = load(['../data/outputs/' exs1{i} '_AMR.mat']);

    qinf(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).qinfl(:,idx),2);
    qver(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).qh2oocn(:,idx),2);
    qlat(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).qlnd2ocn(:,idx),2);
    qrot(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).qrunoff(:,idx),2);
    qsur(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).qover(:,idx),2) + nanmean(rst(1).(tag1{i}).qh2osfc(:,idx),2);
    h2os(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).h2osoisur(:,idx),2);
    tgrd(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).tgrnd(:,idx),2);
    evap(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).lambdaE(:,idx),2);
    zwt(1).(tag1{i})  = max(zwtyr(1).(tag1{i}).zwtyr(:,idx),[],2);
    rain(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).rain(:,idx),2);
    qamr(1).(tag1{i}) = nanmean(AMR(1).(tag1{i}).AMSF(:,idx),2);
end

CTL = load('../data/outputs/GFDL-CM4C192-SST_sshyr_CTL.mat');
FUT = load('../data/outputs/GFDL-CM4C192-SST_sshyr_FUT.mat');

foc_qinf     = (qinf.fut_fut - qinf.ctl_ctl).*86400.*365.25;
foc_qlat     = (qlat.fut_fut - qlat.ctl_ctl).*86400.*365.25;
foc_qinf_SLR = (qinf.fut_fut - qinf.fut_ctl).*86400.*365.25;
foc_qlat_SLR = (qlat.fut_fut - qlat.fut_ctl).*86400.*365.25;
foc_qver_SLR = (qver.fut_fut - qver.fut_ctl).*86400.*365.25;
foc_qrot_SLR = (qrot.fut_fut - qrot.fut_ctl).*86400.*365.25;
foc_qsur     = (qsur.fut_fut - qsur.ctl_ctl).*86400.*365.25;
foc_qsur_SLR = (qsur.fut_fut - qsur.fut_ctl).*86400.*365.25;
foc_qsur_ATM = (qsur.fut_ctl - qsur.ctl_ctl).*86400.*365.25;
foc_qrot_ATM = (qrot.fut_ctl - qrot.ctl_ctl).*86400.*365.25;
foc_qamr_SLR = (qamr.fut_fut - qamr.fut_ctl).*86400.*365.25;
foc_qamr_ATM = (qamr.fut_ctl - qamr.ctl_ctl).*86400.*365.25;

foc_h2os_ATM = (h2os.fut_ctl - h2os.ctl_ctl);
foc_rain_ATM = (rain.fut_ctl - rain.ctl_ctl);
foc_tgrd_ATM = tgrd.fut_ctl - tgrd.ctl_ctl;
foc_tgrd_SLR = tgrd.fut_fut - tgrd.fut_ctl;
foc_tgrd_ALL = tgrd.fut_fut - tgrd.ctl_ctl;
fut_tgrd     = tgrd.fut_fut;
fut_h2os     = h2os.ctl_ctl;
foc_evap_SLR = evap.fut_fut - evap.fut_ctl;
foc_zwt_FUT  = zwt.fut_fut - zwt.ctl_ctl;
foc_zwt_ATM  = zwt.fut_fut - zwt.ctl_fut;
foc_zwt_SLR  = zwt.fut_fut - zwt.fut_ctl;
foc_SLR      = nanmean(FUT.SSHyr(:,6:35),2) - nanmean(CTL.SSHyr(:,35:64),2);

%ind_rm = abs((qrot.fut_fut - qrot.ctl_ctl) ./ qrot.ctl_ctl) > 3 | qrot.ctl_ctl < 0 | foc_qinf > 1000 | foc_qinf < -200 | foc_qver_SLR > 500 | foc_qver_SLR < -200;
%ind_rm = qrot.ctl_ctl < 0 | foc_qinf > 1000 | foc_qinf < -200 | foc_qver_SLR > 500 | foc_qver_SLR < -200;
%ind_rm = false(length(foc_SLR),1);
ind_rm  = abs(foc_zwt_SLR) > 1;

fan8th(gl_mask | ind_small | ind_rm) = [];
foc_qinf(gl_mask | ind_small | ind_rm) = [];
foc_qlat(gl_mask | ind_small | ind_rm) = [];
foc_qinf_SLR(gl_mask | ind_small | ind_rm) = [];
foc_qlat_SLR(gl_mask | ind_small | ind_rm) = [];
foc_qver_SLR(gl_mask | ind_small | ind_rm) = [];
foc_qrot_SLR(gl_mask | ind_small | ind_rm) = [];
foc_qsur(gl_mask | ind_small | ind_rm)     = [];
foc_qsur_SLR(gl_mask | ind_small | ind_rm) = [];
foc_qsur_ATM(gl_mask | ind_small | ind_rm) = [];
foc_qrot_ATM(gl_mask | ind_small | ind_rm) = [];
foc_qamr_SLR(gl_mask | ind_small | ind_rm) = [];
foc_qamr_ATM(gl_mask | ind_small | ind_rm) = [];

foc_h2os_ATM(gl_mask | ind_small | ind_rm) = [];
foc_rain_ATM(gl_mask | ind_small | ind_rm) = [];
foc_tgrd_ALL(gl_mask | ind_small | ind_rm) = [];
foc_tgrd_ATM(gl_mask | ind_small | ind_rm) = [];
fut_tgrd(gl_mask | ind_small | ind_rm)     = [];
fut_h2os(gl_mask | ind_small | ind_rm)     = [];
foc_tgrd_SLR(gl_mask | ind_small | ind_rm) = [];
foc_evap_SLR(gl_mask | ind_small | ind_rm) = [];
qlat.fut_fut(gl_mask | ind_small | ind_rm) = [];
qlat.ctl_ctl(gl_mask | ind_small | ind_rm) = [];
qlat.fut_ctl(gl_mask | ind_small | ind_rm) = [];
qrot.fut_ctl(gl_mask | ind_small | ind_rm) = [];
qrot.ctl_ctl(gl_mask | ind_small | ind_rm) = [];
qsur.fut_ctl(gl_mask | ind_small | ind_rm) = [];
qsur.ctl_ctl(gl_mask | ind_small | ind_rm) = [];
qamr.fut_ctl(gl_mask | ind_small | ind_rm) = [];
qamr.ctl_ctl(gl_mask | ind_small | ind_rm) = [];
rain.fut_ctl(gl_mask | ind_small | ind_rm) = [];
rain.ctl_ctl(gl_mask | ind_small | ind_rm) = [];
foc_zwt_FUT(gl_mask | ind_small | ind_rm)  = [];
foc_zwt_ATM(gl_mask | ind_small | ind_rm)  = [];
foc_zwt_SLR(gl_mask | ind_small | ind_rm)  = [];
foc_SLR(gl_mask | ind_small | ind_rm)      = [];
merit_x(gl_mask | ind_small | ind_rm)      = [];
merit_y(gl_mask | ind_small | ind_rm)      = [];
merit_frac(gl_mask | ind_small | ind_rm)   = [];
merit_topo(gl_mask | ind_small | ind_rm)   = [];
merit_std(gl_mask | ind_small | ind_rm)    = [];
merit_area(gl_mask | ind_small | ind_rm)   = [];
xv(:,gl_mask | ind_small | ind_rm)         = [];
yv(:,gl_mask | ind_small | ind_rm)         = [];

if exist('../data/map1deg.mat','file') && read_mapping
    load('../data/map1deg.mat');
else
    [lon,lat,fan1deg,mapping,map_1dto2d] = upscale_data(merit_x,merit_y,merit_frac,fan8th,1);
    save('../data/map1deg.mat','mapping','map_1dto2d','lon','lat');
end

load('../data/map1deg.mat');
foc1_1deg = mapping_1d_to_2d(foc_qinf,mapping,map_1dto2d,size(lon));
foc_h2os_ATM1deg = mapping_1d_to_2d(foc_h2os_ATM,mapping,map_1dto2d,size(lon));
foc_rain_ATM1deg = mapping_1d_to_2d(foc_rain_ATM,mapping,map_1dto2d,size(lon));
foc_qlat_SLR1deg = mapping_1d_to_2d(foc_qlat_SLR,mapping,map_1dto2d,size(lon));
foc_qinf_SLR1deg = mapping_1d_to_2d(foc_qinf_SLR,mapping,map_1dto2d,size(lon));
foc_qver_SLR1deg = mapping_1d_to_2d(foc_qver_SLR,mapping,map_1dto2d,size(lon));
foc_qrot_SLR1deg = mapping_1d_to_2d(foc_qrot_SLR,mapping,map_1dto2d,size(lon));
foc_qrot_ATM1deg = mapping_1d_to_2d(foc_qrot_ATM,mapping,map_1dto2d,size(lon));
foc_qsur_SLR1deg = mapping_1d_to_2d(foc_qsur_SLR,mapping,map_1dto2d,size(lon));
foc_qsur_ATM1deg = mapping_1d_to_2d(foc_qsur_ATM,mapping,map_1dto2d,size(lon));
foc_qamr_SLR1deg = mapping_1d_to_2d(foc_qamr_SLR,mapping,map_1dto2d,size(lon));
foc_qamr_ATM1deg = mapping_1d_to_2d(foc_qamr_ATM,mapping,map_1dto2d,size(lon));
qrot_fut_ctl1deg = mapping_1d_to_2d(qrot.fut_ctl,mapping,map_1dto2d,size(lon)).*86400.*365;
qrot_ctl_ctl1deg = mapping_1d_to_2d(qrot.ctl_ctl,mapping,map_1dto2d,size(lon)).*86400.*365;
qsur_ctl_ctl1deg = mapping_1d_to_2d(qsur.ctl_ctl,mapping,map_1dto2d,size(lon)).*86400.*365;
qsur_fut_ctl1deg = mapping_1d_to_2d(qsur.fut_ctl,mapping,map_1dto2d,size(lon)).*86400.*365;
qamr_fut_ctl1deg = mapping_1d_to_2d(qamr.fut_ctl,mapping,map_1dto2d,size(lon)).*86400.*365;
qamr_ctl_ctl1deg = mapping_1d_to_2d(qamr.ctl_ctl,mapping,map_1dto2d,size(lon)).*86400.*365;
foc_tgrd_SLR1deg = mapping_1d_to_2d(foc_tgrd_SLR,mapping,map_1dto2d,size(lon));
foc_tgrd_ATM1deg = mapping_1d_to_2d(foc_tgrd_ATM,mapping,map_1dto2d,size(lon));
foc_evap_SLR1deg = mapping_1d_to_2d(foc_evap_SLR,mapping,map_1dto2d,size(lon));
foc3_1deg        = mapping_1d_to_2d(foc_qlat,mapping,map_1dto2d,size(lon));
foc_zwt_FUT1deg  = mapping_1d_to_2d(foc_zwt_FUT,mapping,map_1dto2d,size(lon));
foc_zwt_SLR1deg  = mapping_1d_to_2d(foc_zwt_SLR,mapping,map_1dto2d,size(lon));
foc_zwt_ATM1deg  = mapping_1d_to_2d(foc_zwt_ATM,mapping,map_1dto2d,size(lon));
foc_SLR1deg      = mapping_1d_to_2d(foc_SLR,mapping,map_1dto2d,size(lon));
area1deg         = mapping_1d_to_2d(merit_area.*merit_frac,mapping,map_1dto2d,size(lon));
labels = {'(a) \Delta GWT_{ATM} [m]','(b) \Delta GWT_{ATM+SLR} [m]','\Delta Seawater infiltration [mm/yr]'};
% plot_exs3(lon,lat, foc1_1deg, foc2_1deg, foc3_1deg, -50, 50, labels);

cmin = [-0.5 -0.5 -0.5]; cmax = [+0.5 +0.5 +0.5];

[axs1, cbs1] = plot_exs2(lon,lat,foc_zwt_ATM1deg,foc_zwt_FUT1deg,cmin,cmax,labels);
cbs1(1).FontSize = 15;
cbs1(2).FontSize = 15;

%exportgraphics(gcf,'../writing/Figure_S4.jpg','Resolution',400);

[axs2, cbs2] = plot_exs2(lon,lat,foc_qinf_SLR1deg,foc_qlat_SLR1deg,[-100 -1],[100 1],{'(a). \Delta Seawater infiltration','(b). \Delta Lateral flow'});
% exportgraphics(gcf,'../writing/Change_of_seawater_infiltration.jpg','Resolution',400);

cities = GetCities();
catogrory = 2;
SubR   = GetWorldSubRegions(catogrory,[]);

lon1d = lon(map_1dto2d); lat1d = lat(map_1dto2d);

Sub1d = NaN(length(lon1d),1);
if catogrory == 1
    for i = 1 : length(lon1d)
        dist = NaN(length(SubR),1);
        for j = 1 : length(SubR)
            tmp = (lon1d(i) - SubR(j).X).^2 + (lat1d(i) - SubR(j).Y).^2;
            dist(j) = min(tmp);
        end
        tmp = find(dist == min(dist));
        Sub1d(i) = tmp(1);
    end
elseif catogrory == 2
    for i = 1 : length(SubR)
        in = inpolygon(lon1d,lat1d,SubR(i).X,SubR(i).Y);
        Sub1d(in) = i;
    end
end

foc_zwt_SLR1d = foc_zwt_SLR1deg(map_1dto2d);
foc_SLR1d     = foc_SLR1deg(map_1dto2d);
area1d        = area1deg(map_1dto2d);
figure;
for i = 1 : length(SubR)
    SubR(i).foc_zwt_SLR1d = nanmedian(foc_zwt_SLR1d(Sub1d == i));
    SubR(i).foc_SLR1d     = nanmedian(foc_SLR1d(Sub1d == i));
    SubR(i).topo          = nanmedian(merit_topo(Sub1d == i));
%     SubR(i).foc_zwt_SLR1d = nansum(foc_zwt_SLR1d(Sub1d == i).*area1d(Sub1d == i))./nansum(area1d(Sub1d == i));
%     SubR(i).foc_SLR1d     = nansum(foc_SLR1d(Sub1d == i).*area1d(Sub1d == i))./nansum(area1d(Sub1d == i)); 
    subplot(4,4,i);
    ecdf(-foc_zwt_SLR1d(Sub1d == i));
    title(SubR(i).Name);
end

figure; set(gcf,'Position',[10 10 1200 800]);
ax3(1) = subplot(2,1,1);
h = bar(-[SubR(:).foc_zwt_SLR1d]); grid on;
set(gca,'XTick',[]); ylim([0 0.2]);
set(gca,'FontSize',13);
add_title(gca,'(a). Median GWL changes [m]');

ax3(2) = subplot(2,1,2);
h = bar([SubR(:).foc_SLR1d ]); grid on;
set(gca,'XTick',1:length(SubR),'XTickLabel',{SubR(:).Name}); ylim([0 0.2]);
set(gca,'FontSize',13);
%ax1.Position(2) = ax1.Position(2) - 0.075;
add_title(gca,'(b). Median SLR [m]');

ax3(2).Position(2) = ax3(2).Position(2) + 0.075;

exportgraphics(gcf,'../writing/GWL_VS_SLR.pdf','ContentType','vector');


% subplot(3,1,3);
% h = bar([SubR(:).topo]); grid on;
% set(gca,'XTick',1:length(SubR),'XTickLabel',{SubR(:).Name}); %ylim([0 0.2]);
% set(gca,'FontSize',13);
% %ax1.Position(2) = ax1.Position(2) - 0.075;
% add_title(gca,'(c). Topo [m]');


figure;
cols = jet(length(SubR));
for i = 1 : length(SubR)
    plot(lon1d(Sub1d == i), lat1d(Sub1d == i),'x', 'Color', cols(i,:)); hold on;
end
legend([SubR(:).Name]);

figure;
cmap = getPanoply_cMap('NEO_modis_cld_rd');
X = [foc_qver_SLR1deg(:) foc_qrot_SLR1deg(:)];
hist3(X,'CdataMode','auto','Nbins',[150,150],'LineStyle','none');
view(2);colormap(gca,cmap); clim([0 200]);
cb1 = colorbar('east');
hold on; grid on;
plot3([-20 400],[-20 400],[1000 1000],'r--','LineWidth',1);
xlim([-20 200]); ylim([-20 200]);

for ii = 1 : 4
    rst.(tag1{ii}).qinfl(gl_mask | ind_small | ind_rm,:)     = [];
    rst.(tag1{ii}).qh2oocn(gl_mask | ind_small | ind_rm,:)   = [];
    rst.(tag1{ii}).qrunoff(gl_mask | ind_small | ind_rm,:)   = [];
    rst.(tag1{ii}).qover(gl_mask | ind_small | ind_rm,:)     = [];
    rst.(tag1{ii}).qh2osfc(gl_mask | ind_small | ind_rm,:)   = [];
    rst.(tag1{ii}).h2osoisur(gl_mask | ind_small | ind_rm,:) = [];
    zwtyr.(tag1{ii}).zwtyr(gl_mask | ind_small | ind_rm,:)   = [];
end

if plot_cities
qinf_cities = struct([]);
qver_cities = struct([]);
qlat_cities = struct([]);
qrot_cities = struct([]);
qsur_cities = struct([]);
zwt_cities  = struct([]);
slr_cities  = NaN(20,30);
fld_cities  = NaN(20,30);
slr_cities0 = NaN(20,64);
fld_cities0 = NaN(20,64);


figure(101); set(gcf,'Position',[10 10 1200 800]);
figure(102); set(gcf,'Position',[10 10 1200 800]);
figure(103); set(gcf,'Position',[10 10 1200 800]);
figure(104); set(gcf,'Position',[10 10 1200 800]);
figure(201); set(gcf,'Position',[10 10 1200 800]);

end


CTL.SSHyr(gl_mask | ind_small | ind_rm,:) = [];
FUT.SSHyr(gl_mask | ind_small | ind_rm,:) = [];
CTL.Inundyr(gl_mask | ind_small | ind_rm,:) = [];
FUT.Inundyr(gl_mask | ind_small | ind_rm,:) = [];

fname = '../inputdata/surfdata_global_coastline_merit_90m_c221003.nc';
PCT_SAND   = ncread(fname,'PCT_SAND');
PCT_CLAY   = ncread(fname,'PCT_CLAY');
ORGANIC    = ncread(fname,'ORGANIC');
SOIL_COLOR = ncread(fname,'SOIL_COLOR');
SOIL_ORDER = ncread(fname,'SOIL_ORDER');
PCT_NAT_PFT= ncread(fname,'PCT_NAT_PFT');
MONTHLY_LAI= ncread(fname,'MONTHLY_LAI');
LAI        = nansum(nanmean(MONTHLY_LAI,3).*PCT_NAT_PFT./100,2);

load('../data/bathtub_global_coastline_merit_90m.mat');
merit_bathtub(gl_mask | ind_small | ind_rm,:) = [];
PCT_SAND = PCT_SAND(:,1);
PCT_CLAY = PCT_CLAY(:,1);
ORGANIC  = ORGANIC(:,1);

PCT_SAND(gl_mask | ind_small | ind_rm,:)    = [];
PCT_CLAY(gl_mask | ind_small | ind_rm,:)    = [];
ORGANIC(gl_mask | ind_small | ind_rm,:)     = [];
PCT_NAT_PFT(gl_mask | ind_small | ind_rm,:) = [];
SOIL_COLOR(gl_mask | ind_small | ind_rm)    = [];
SOIL_ORDER(gl_mask | ind_small | ind_rm)    = [];
LAI(gl_mask | ind_small | ind_rm)           = [];
x1 = nanmean(merit_bathtub(:,1:101),2);
x2 = nanmean(FUT.SSHyr(:,6:35),2)-nanmean(CTL.SSHyr(:,35:64),2);
x3 = nanstd(merit_bathtub(:,1:101),[],2);
x4 = foc_tgrd_ATM; %fut_tgrd;%_ATM;%foc_tgrd_SLR;
x5 = PCT_SAND;
x6 = PCT_CLAY;
x7 = nanmean(FUT.Inundyr(:,6:35),2)-nanmean(CTL.Inundyr(:,35:64),2);
x8 = PCT_NAT_PFT(:,1:15);
x9 = foc_rain_ATM;

inan = find(foc_qver_SLR > 500);
y  = foc_qver_SLR;
X = [ones(size(x1)) x2 x1 x3 x5 x6 x8 x2.*x1 x2.*x3 x2.*x8 x1.*x3 x1.*x8 x3.*x8];
y(inan)   = NaN;
X(inan,:) = NaN;
X1 = [ones(size(x1)) x2];       
X2 = [ones(size(x1)) x1 x3];    
X3 = [ones(size(x1)) x5 x6 x8]; 
X4 = [ones(size(x1)) x2 x1 x3 x5 x6 x8];

load('colorblind_colormap.mat');
cmap = colorblind([11 6 10 2 1 ],:);

y  = foc_qver_SLR;
X = [x2 x1 x3 x4 x9 x5 x6 x8];
y(inan)   = NaN;
X(inan,:) = NaN;

figure; set(gcf,'Position',[10 10 1200 900]);
for i = 1 : 16
    in = inpolygon(merit_x,merit_y,SubR(i).X,SubR(i).Y);
    sy  = y(in); sX = X(in,:); sX1 = X1(in,:); sX2 = X2(in,:); sX3 = X3(in,:); sX4 = X4(in,:);
    disp(nanmean(merit_topo(in)))
    % NOTE: using log transformation doesn't improve the fit.
    %       adding change of evap, soil moisture doesn't improve the fit.
    %       using LAI instead of PFT percentagy result in bad fit.
    [b,bint,r,rint,stats]  = regress(sy,sX); 
    [b,bint,r,rint,stats1] = regress(sy,sX1); 
    [b,bint,r,rint,stats2] = regress(sy,sX2); 
    [b,bint,r,rint,stats3] = regress(sy,sX3); 
    [b,bint,r,rint,stats4] = regress(sy,sX4); 

    rho = [stats1(1) stats2(1) stats3(1) stats4(1) stats(1)]; 
    rho = sqrt(rho);
    subplot_tight(4,4,i,[0.08 0.02]);
    h = bar(1:5,rho); 
    xticks(1:5)
    xticklabels({'SLR','Topo','Hydro','All','All+Interactions'});
    ylim([0 0.75]);
    title(SubR(i).Name,'FontSize',15,'FontWeight','bold');
    h.FaceColor = 'flat';
    for j = 1 : 5
        h.CData(j,:) = cmap(j,:);
    end
    h.LineWidth = 2;
    if i <= 12
        set(gca,'XTick',[]);
    else
        set(gca,'FontSize',12);
    end
    if i == 1 || i == 5 || i == 9 || i == 13
        set(gca,'FontSize',12);
    else
        set(gca,'YTick',[]);
    end
    sy  = y(in); sX = X(in,:); 
    ind = find(isnan(sy));
    sy(ind) = [];
    sX(ind,:) = [];
    save(['train' num2str(i) '.mat'],'sy','sX');
end

[b,bint,r,rint,stats]  = regress(y,X);
c      = b .* nanmean(X)';
cSLR   = c(2);
cTOPO  = c(3) + c(4);
cHYDRO = sum(c(5:21));
cInter = sum(c(22:end));

[b1,bint,r,rint,stats1] = regress(y,X1); 
[b2,bint,r,rint,stats2] = regress(y,X2); 
[b3,bint,r,rint,stats3] = regress(y,X3); 
[b4,bint,r,rint,stats4] = regress(y,X4); 

c4     = b4 .* nanmean(X4)';
cSLR   = c4(2);
cTOPO  = c4(3) + c4(4);
cHYDRO = sum(c4(5:21));

X = [x2 x1 x3 x4 x5 x6 x8];
inan = find(foc_qver_SLR > 500);
y  = foc_qver_SLR;
y(inan)   = [];
X(inan,:) = [];
save('train.mat','X','y');

rho = [stats1(1) stats2(1) stats3(1) stats4(1) stats(1)];
rho = sqrt(rho);  


figure; set(gcf,'Position',[10 10 800 400]);
h = bar(rho); grid on;
set(gca,'FontSize',14);
ylabel('Correlation coefficient','FontSize',15,'FontWeight','bold');
set(gca,'XTickLabel',{'SLR','Topo','Hydro','All','All+Interactions'},'FontSize',16);

h.FaceColor = 'flat';
for i = 1 : 5
    h.CData(i,:) = cmap(i,:);
end
h.LineWidth = 2;
exportgraphics(gcf,'../writing/Attribution.pdf','ContentType','vector');

if plot_cities
i = 4;
for j = 1 : length(cities)
dist = (lon1d - cities(j).X).^2 + (lat1d - cities(j).Y).^2;
ind = find(dist == min(dist));

ind2 = find(mapping(:,ind));
wght = full(mapping(ind2,ind));
if j == 13
    ind2(1) = [];
    wght(1) = [];
    wght = wght ./ sum(wght);
end

qinf_cities(j).(tag1{i}) = sum(rst.(tag1{i}).qinfl(ind2,idx).*wght)   .* 86400 .* 365;
% qver_cities(j).(tag1{i}) = sum(rst.(tag1{i}).qh2oocn(ind2,idx).*wght) .* 86400 .* 365;
qver_cities(j).(tag1{i}) = (sum(rst.(tag1{4}).qinfl(ind2,idx).*wght) - ...
                            sum(rst.(tag1{3}).qinfl(ind2,idx).*wght)).* 86400 .* 365;
qrot_cities(j).(tag1{i}) = sum(rst.(tag1{4}).qrunoff(ind2,idx).*wght).* 86400 .* 365;
qsur_cities(j).(tag1{i}) = (sum(rst.(tag1{4}).qover(ind2,idx).*wght)   + ...
                            sum(rst.(tag1{4}).qh2osfc(ind2,idx).*wght)).* 86400 .* 365;
qrot_cities(j).(tag1{3}) = sum(rst.(tag1{3}).qrunoff(ind2,idx).*wght).* 86400 .* 365;
qrot_cities(j).(tag1{2}) = sum(rst.(tag1{2}).qrunoff(ind2,idx).*wght).* 86400 .* 365;
qrot_cities(j).(tag1{1}) = sum(rst.(tag1{1}).qrunoff(ind2,idx).*wght).* 86400 .* 365;

qsur_cities(j).(tag1{3}) = (sum(rst.(tag1{3}).qover(ind2,idx).*wght)   + ...
                            sum(rst.(tag1{3}).qh2osfc(ind2,idx).*wght)).* 86400 .* 365;
qsur_cities(j).(tag1{1}) = (sum(rst.(tag1{1}).qover(ind2,idx).*wght)   + ...
                            sum(rst.(tag1{1}).qh2osfc(ind2,idx).*wght)).* 86400 .* 365;

zwt_cities(j).(tag1{i}) = nansum(zwtyr.(tag1{4}).zwtyr(ind2,idx).*wght);
zwt_cities(j).(tag1{3}) = nansum(zwtyr.(tag1{3}).zwtyr(ind2,idx).*wght);
zwt_cities(j).(tag1{1}) = nansum(zwtyr.(tag1{1}).zwtyr(ind2,idx).*wght);

a = sum(rst.(tag1{4}).qinfl(ind2,idx).*wght).* 86400 .* 365;
b = sum(rst.(tag1{3}).qinfl(ind2,idx).*wght).* 86400 .* 365;

slr_cities0(j,:) = nansum(CTL.SSHyr(ind2,:).*wght);
fld_cities0(j,:) = nansum(CTL.Inundyr(ind2,:).*wght);
slr_cities(j,:)  = nansum(FUT.SSHyr(ind2,idx).*wght);
fld_cities(j,:)  = nansum(FUT.Inundyr(ind2,idx).*wght);

fld_cities(j,:)  = fld_cities(j,:)  - nanmean(fld_cities0(j,:));
fld_cities0(j,:) = fld_cities0(j,:) - nanmean(fld_cities0(j,:));

fld_cities(fld_cities<0)   = 0;
fld_cities0(fld_cities0<0) = 0;

figure(101);
subplot(6,5,j);
plot(2021:2050,qver_cities(j).(tag1{i}),'b-','LineWidth',1); hold on;
plot(2021:2050,slr_cities(j,:).*1000,'k-','LineWidth',1);
plot(1951:2014,slr_cities0(j,:).*1000,'k-','LineWidth',1);
title(cities(j).Name,'FontSize',14,'FontWeight','bold');

figure(102);
subplot(6,5,j);
plot(zwt_cities(j).(tag1{i}) - nanmean(zwt_cities(j).(tag1{1})),'r-','LineWidth',1); hold on; grid on;
plot(zwt_cities(j).(tag1{3}) - nanmean(zwt_cities(j).(tag1{1})),'b-','LineWidth',1);
title(cities(j).Name,'FontSize',14,'FontWeight','bold');

figure(103);
subplot(6,5,j);
plot(2021:2050,fld_cities(j,:),'k-','LineWidth',1); hold on;
plot(1951:2014,fld_cities0(j,:),'k-','LineWidth',1);
title(cities(j).Name,'FontSize',14,'FontWeight','bold');

figure(104);
subplot(6,5,j);
plot(qsur_cities(j).(tag1{4}),'r-','LineWidth',1); hold on;
plot(qsur_cities(j).(tag1{1}),'k-','LineWidth',1);
title(cities(j).Name,'FontSize',14,'FontWeight','bold');

qrot_RC(j,1) = nanmean(qrot_cities(j).(tag1{4}) - qrot_cities(j).(tag1{3}))/nanmean(qrot_cities(j).(tag1{3}));
qrot_RC(j,2) = nanmean(qrot_cities(j).(tag1{4}) - qrot_cities(j).(tag1{1}))/nanmean(qrot_cities(j).(tag1{1}));
qsur_RC(j,1) = nanmean(qsur_cities(j).(tag1{4}) - qsur_cities(j).(tag1{3}))/nanmean(qsur_cities(j).(tag1{1}));
qsur_RC(j,2) = nanmean(qsur_cities(j).(tag1{4}) - qsur_cities(j).(tag1{1}))/nanmean(qsur_cities(j).(tag1{1}));

end
end

[axs, cbs] = plot_exs2(lon,lat,-foc_zwt_SLR1deg,foc_qver_SLR1deg,[-0.2 -0.2],[0.2 0.2],{'(a) \Delta GWT_{SLR}',' '});
cbs(1).Label.String = '[m]';
cbs(1).Label.FontWeight = 'bold';
cbs(1).FontSize = 15;
tmp = GetWorldSubRegions(catogrory,axs(1)); clear tmp;
pos = get(axs(1),'Position'); 
for i = 1 : length(SubR)
    minsz = 40;  minv = 0.01;
    maxsz = 400; maxv = 0.1;
    if -SubR(i).foc_zwt_SLR1d > maxv
        sz = maxsz;
    elseif -SubR(i).foc_zwt_SLR1d < minv
        sz = minsz;
    else
        sz = (maxsz - minsz)/(maxv - minv).^2*(-SubR(i).foc_zwt_SLR1d).^2;
    end
    scatter(axs(1),mean(SubR(i).X(1:4)),mean(SubR(i).Y(1:4)),sz,'o','LineWidth',2.5, ...
            'MarkerEdgeColor',[0, 255, 127]./255);
end

% Add legend
vs = [0.02; 0.04; 0.06; 0.08; 0.1];
xbot = 60;
ybot = -55;
for i = 1 : length(vs)
    sz = (maxsz - minsz)/(maxv - minv).^2*(vs(i)).^2;
    scatter(axs(1),xbot,ybot+(i-1)*10,sz,'o','LineWidth',2.5, ...
            'MarkerEdgeColor',[0, 255, 127]./255);
    text(axs(1),xbot+10,ybot+(i-1)*10,[num2str(vs(i)) ' [m]'],'FontSize',13,'FontWeight','bold')
end
% City Scale
% axes('Position',[0.14 0.55 0.1 0.175]);
% tmp = NaN(length(cities),1);
% for i = 1 : length(cities)
%     tmp(i) = -nanmean(zwt_cities(i).(tag1{4}) - zwt_cities(i).(tag1{3}));
% end
% [~,I] = sort(tmp,'descend');
% num_of_cities = 10;
% barh(flipud(tmp(I(1:num_of_cities)))); grid on;
% set(gca,'YTick',[1:num_of_cities],'YTickLabel',{cities(flipud(I(1:num_of_cities))).Name});
% set(gca,'box','off');
% t = annotation('textbox',[0.175 0.55 0.030 0.025],'String','[m]','FitBoxToText','on','FontSize',13,'FontWeight','bold');
% t.EdgeColor = 'none';

delete(axs(2));
pos = get(axs(1),'Position');

w0 = (pos(3)-0.15)/4;
d0 = 0.20;

k = 1;
labels2 = {'(b) ', '(c) ', '(d) ', '(e) '};

for i = [6 9 14 8]
    in = inpolygon(merit_x,merit_y,SubR(i).X,SubR(i).Y);
    a  = merit_frac(in).*merit_area(in);

%     d1 = -nansum((zwtyr.fut_fut.zwtyr(in,idx) - zwtyr.fut_ctl.zwtyr(in,idx)).*a)./nansum(a);
%     d2 = -nansum((zwtyr.ctl_fut.zwtyr(in,idx) - zwtyr.ctl_ctl.zwtyr(in,idx)).*a)./nansum(a);
    d1 = -nanmedian(zwtyr.fut_fut.zwtyr(in,idx) - zwtyr.fut_ctl.zwtyr(in,idx));
    d2 = -nanmedian(zwtyr.ctl_fut.zwtyr(in,idx) - zwtyr.ctl_ctl.zwtyr(in,idx));
    
    axes('Position',[pos(1)+(k-1)*(w0+0.05) pos(2)-0.25 w0 d0]);
    h(1) = plot(2021:2050,d1,'x','Color',[0,153,143]./255,'LineWidth',1); hold on; grid on;
    [theta1,theta2]=LSE(2021:2035,d1(1 :15));
    plot([2021 2035],theta1 + theta2.*[2021 2035],'k-','LineWidth',1);
    [theta1,theta2]=LSE(2036:2050,d1(16:30));
    plot([2035 2050],theta1 + theta2.*[2035 2050],'k-','LineWidth',1);
    h(2) = plot(1985:2014,d2,'x','Color',[240,163,255]./255,'LineWidth',1); 
    [theta1,theta2]=LSE(1985:1999,d2(1 :15));
    plot([1985 1999],theta1 + theta2.*[1985 1999],'k-','LineWidth',1);
    [theta1,theta2]=LSE(2000:2014,d2(16:30));
    plot([1999 2014],theta1 + theta2.*[1999 2014],'k-','LineWidth',1);

    xlim([1985 2050]); %ylim([min([d1 d2]) max([d1 d2])]);
    ylim([0 0.15]);
    set(gca,'FontSize',15);
    add_title(gca,[labels2{k} SubR(i).Name],16,'out');
    if k == 1
        ylabel('\Delta GWT_{SLR}','FontSize',15,'FontWeight','bold');
    end
    k = k + 1;
end

%exportgraphics(gcf,'../writing/Figure_5.jpg','Resolution',400);

labels3 = {'(a) ', '(b) ', '(c) ', '(d) '};
figure; set(gcf,'Position',[10 10 1000 800]);
k = 1;
for i = [6 9 14 8]
    subplot(2,2,k);
    in = inpolygon(merit_x,merit_y,SubR(i).X,SubR(i).Y);
    a  = merit_frac(in).*merit_area(in);
    d1 = nanmedian(rst.fut_ctl.h2osoisur(in,idx));
    d2 = nanmedian(rst.ctl_ctl.h2osoisur(in,idx));
    h(1) = plot(2021:2050,d1,'x-','Color',[0,153,143]./255,'LineWidth',2); hold on; grid on;
    h(2) = plot(1985:2014,d2,'x-','Color',[240,163,255]./255,'LineWidth',2); 
    add_title(gca,[labels3{k} SubR(i).Name]);
    set(gca,'FontSize',14);
    k = k + 1;
end
han=axes(gcf,'visible','off'); 
han.YLabel.Visible='on';
ylabel(han,'Surface soil moisture [-]','FontSize',15,'FontWeight','bold');
han.Position(1) = han.Position(1) - 0.025;

[axs2, cbs2] = plot_exs2(lon,lat,foc_qver_SLR1deg,foc_qlat_SLR1deg,[-50 -50],[50 50],{'\Delta Seawater infiltration [mm/year]','\Delta Lateral flow [mm/year]'});
cbs2(1).FontSize = 15;
cbs2(2).FontSize = 15;
% rc = foc_qrot_SLR1deg./qrot_fut_ctl1deg.*100;
% rc = foc_qamr_SLR1deg./qamr_ctl_ctl1deg.*100;
[ foc_evap_SLR     ] = E1toE2( foc_evap_SLR,2     ).*365; % Convert ET from W/m^2 to mm/year
[ foc_evap_SLR1deg ] = E1toE2( foc_evap_SLR1deg,2 ).*365; 
%[axs3, cbs3] = plot_exs2(lon,lat,foc_tgrd_SLR1deg,foc_qrot_SLR1deg,[-0.5 -100],[0.5 100],{'\Delta T_{S} [^{\circ}C]','\Delta Runoff [mm]'});
[axs3, cbs3] = plot_exs2(lon,lat,foc_tgrd_SLR1deg,foc_qrot_SLR1deg,[-0.5 -100],[0.5 100],...
               {'',''});
cmap10 = getPanoply_cMap('NEO_meltseason_anom');
colormap(axs3(1),cmap10);
%(c) \Delta Runoff [mm/yr]
%(a) \Delta Surface Temperature [{\circ}C]
cbs3(1).FontSize = 13; cbs3(2).FontSize = 13;
axs3(1).Position(1) = axs3(1).Position(1) - 0.05;
axs3(2).Position(1) = axs3(2).Position(1) - 0.05;
ARAB_X = [10 60 60 10 10];
ARAB_Y = [10 10 35 35 10];
plot(axs3(1),ARAB_X,ARAB_Y,'k:','LineWidth',2);
plot(axs3(2),ARAB_X,ARAB_Y,'k:','LineWidth',2);

axs3(1).Position(2) = axs3(1).Position(2) + 0.025;
axs3(1).Position(3) = axs3(1).Position(3) - 0.05;
axs3(2).Position(3) = axs3(2).Position(3) - 0.05;
axs3(1).Position(1) = axs3(1).Position(1) + 0.025;
axs3(2).Position(1) = axs3(2).Position(1) + 0.025;
pos = axs3(1).Position;
t1 = annotation('textbox',[pos(1) pos(2)+pos(4)-0.02 0.2 0.05] ,'String','(a) \Delta Surface Temperature [{\circ}C]','FitBoxToText','on');
t1.FontSize = 20; t1.FontWeight = 'bold'; t1.EdgeColor = 'none';
axes('Position',[pos(1)+pos(3)+0.01 pos(2) 0.1 pos(4)]);
plot(nanmean(foc_tgrd_SLR1deg,2),89.5 : -1 : -89.5,'k-','LineWidth',1.5); grid on;
set(gca, 'box','off','YAxisLocation','right','FontSize',14);
cbs3(1).Location = 'south';
cbs3(1).Position = [pos(1) pos(2)-0.02 pos(3)-0.025 0.02];
cbs3(1).YAxisLocation = 'bottom';
ylim([-60 90]);
pos = get(gca,'Position');  
t2 = annotation('textbox',[pos(1) pos(2)+pos(4)-0.02 0.2 0.05] ,'String','(b)','FitBoxToText','on');
t2.FontSize = 20; t2.FontWeight = 'bold'; t2.EdgeColor = 'none';

pos = axs3(1).Position;
axes('Position',[pos(1)+0.04 pos(2) + 0.04 0.15 0.135]);
X = [foc_tgrd_SLR foc_tgrd_ATM];
hist3(X,'CdataMode','auto','Nbins',[75,75],'LineStyle','none');
view(2);clim(gca,[0 100]);
cb = colorbar('north'); cb.YAxisLocation = 'top'; cb.Position(2) = cb.Position(2) + 0.02;
hold on; grid on; 
plot3([0.5 -4.5],[-0.5 4.5],[1000,1000],'r--','LineWidth',2);
%plot3([1.5 -4.5],[-0.5 5.5],[1000,1000],'g--','LineWidth',2);
xlim([-3 0]);
ylim([-0 4.0]);
cmap = plasma(); cmap(1,:) = [1 1 1];
colormap(gca,cmap);
xlabel('SLR-induced \Delta T_{S}','FontSize',13,'FontWeight','bold');
ylabel('ATM-induced \Delta T_{S}','FontSize',13,'FontWeight','bold');

pos = axs3(2).Position;
t3 = annotation('textbox',[pos(1) pos(2)+pos(4)-0.02 0.2 0.05] ,'String','(c) \Delta Runoff [mm/yr]','FitBoxToText','on');
t3.FontSize = 20; t3.FontWeight = 'bold'; t3.EdgeColor = 'none';
cbs3(2).Location = 'south';
cbs3(2).Position = [pos(1) pos(2)-0.02 pos(3)-0.025 0.02];
axes('Position',[pos(1)+pos(3)+0.01 pos(2) 0.1 pos(4)]);
% plot(nanmean(foc_qrot_SLR1deg,2),89.5 : -1 : -89.5,'k-','LineWidth',1.5); grid on;
% plot(nanmean(foc_qrot_ATM1deg,2),89.5 : -1 : -89.5,'r-','LineWidth',1.5); grid on;

plot(nanmean(foc_qrot_SLR1deg,2),89.5 : -1 : -89.5,'k-','LineWidth',1.5); grid on; hold on;
plot(nanmean(foc_qrot_ATM1deg,2),89.5 : -1 : -89.5,'r-','LineWidth',1.5); grid on;
set(gca, 'box','off','YAxisLocation','right','FontSize',14);
ylim([-60 90]);
pos = get(gca,'Position');
t4 = annotation('textbox',[pos(1) pos(2)+pos(4)-0.02 0.2 0.05] ,'String','(d)','FitBoxToText','on');
t4.FontSize = 20; t4.FontWeight = 'bold'; t4.EdgeColor = 'none';

pos = axs3(2).Position;
axes('Position',[pos(1)+0.04 pos(2) + 0.04 0.15 0.135]);
X = [foc_qrot_SLR foc_evap_SLR];
hist3(X,'CdataMode','auto','Nbins',[450,150],'LineStyle','none');
view(2);clim(gca,[0 100]);
cb = colorbar('north'); cb.YAxisLocation = 'top'; cb.Position(2) = cb.Position(2) + 0.02;
hold on; grid on; 

xlim([-100 500]);
ylim([-50 250]);
colormap(gca,cmap);
xlabel('SLR-induced \Delta Runoff','FontSize',13,'FontWeight','bold');
ylabel('SLR-induced \Delta ET','FontSize',13,'FontWeight','bold');
exportgraphics(gcf,'../writing/Figure_7.jpg','Resolution',400);

foc_zwt_SLR = foc_zwt_SLR.*1000; %[m] --> [mm]
% set(gcf,'renderer','Painters');

% [axs2, cbs2] = plot_exs2(lon,lat,foc_h2os_ATM1deg,foc_rain_ATM1deg,[-0.02],[50 50],{'\Delta Seawater infiltration [mm/year]','\Delta Lateral flow [mm/year]'});
% cbs2(1).FontSize = 15;
% cbs2(2).FontSize = 15;
foc_zwt_SLR1deg = foc_zwt_SLR1deg.*1000;

f1 = abs(foc_zwt_SLR1deg)./(abs(foc_zwt_SLR1deg)  + abs(foc_evap_SLR1deg) + abs(foc_qrot_SLR1deg));
f2 = abs(foc_qrot_SLR1deg)./(abs(foc_zwt_SLR1deg) + abs(foc_evap_SLR1deg) + abs(foc_qrot_SLR1deg));
f3 = abs(foc_evap_SLR1deg)./(abs(foc_zwt_SLR1deg) + abs(foc_evap_SLR1deg) + abs(foc_qrot_SLR1deg));

figure; set(gcf,'Position',[10 10 1000 600]);
for i = 1 : 180
    for j = 1 : 360
        x = f1(i,j); y = f2(i,j); z = f3(i,j);
        if ~isnan(x) && ~isnan(y) && ~isnan(z)
            %disp(['x = ' num2str(x) ', y = ' num2str(y) ', z = ' num2str(z)]);
            tmpx = [lon(i,j) - 0.5 lon(i,j) + 0.5 lon(i,j) + 0.5 lon(i,j) - 0.5];
            tmpy = [lat(i,j) - 0.5 lat(i,j) - 0.5 lat(i,j) + 0.5 lat(i,j) + 0.5];
            fill(tmpx,tmpy,[x y z],'EdgeColor','none'); hold on;
        end
    end
end
xlim([-180 180]); ylim([-60 90]);

xlab = 'GWT [%]'   ;
ylab = 'Runoff [%]';
zlab = 'ET [%]'    ;

ax = axes('Position',[0.125 0.175 0.2 0.25]);
[tx, ty, tc] = add_triangle(ax,xlab,ylab,zlab);
exportgraphics(gcf,'../writing/Figure_8.jpg','Resolution',400);
%exportgraphics(gcf,'../writing/Figure_8.pdf','ContentType','vector');
f1 = abs(foc_zwt_SLR)./(abs(foc_zwt_SLR)  + abs(foc_evap_SLR) + abs(foc_qrot_SLR));
f2 = abs(foc_qrot_SLR)./(abs(foc_zwt_SLR) + abs(foc_evap_SLR) + abs(foc_qrot_SLR));
f3 = abs(foc_evap_SLR)./(abs(foc_zwt_SLR) + abs(foc_evap_SLR) + abs(foc_qrot_SLR));

cmap = getPanoply_cMap('NEO_modis_lst');
[axs3, cbs3] = plot_exs2(lon,lat,foc_qsur_SLR1deg./foc_qrot_SLR1deg,foc_qsur_SLR1deg./foc_qrot_SLR1deg,[0 -1.5],[1 1.5],...
               {'(a) \Delta Surface Runoff / \Delta Total Runoff [-]','(b) \Delta Surface Runoff [mm/year]'});
colormap(axs3(1),cmap);
cbs3(1).FontSize = 15; cbs3(2).FontSize = 15;
%exportgraphics(gcf,'../writing/Figure_S9.jpg','Resolution',400);
