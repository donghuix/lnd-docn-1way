clear;close all;clc;

addpath('/Users/xudo627/donghui/mylib/m/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

exs1 = {'ctl-ctl','ctl-fut','fut-ctl','fut-fut'};
tag1 = {'ctl_ctl','ctl_fut','fut_ctl','fut_fut'};

load('../data/domain_global_coastline_merit_90m.mat');
[xv,yv] = xc2xv(merit_x,merit_y,1/8,1/8,false);

read_mapping = 1;

rst = struct([]);
zwtyr = struct([]);

qinf = struct([]);
qver = struct([]);
qlat = struct([]);
qrot = struct([]);
zwt  = struct([]);

load coastlines.mat;
load('../data/greenland.mat');
gl_mask   = inpoly2([merit_x merit_y],[x y]);
ind_small = merit_frac < 0.05;

load('../fan/fan8th.mat');

idx = 6 : 35;

for i = 1 : length(exs1)
    disp(['Read ' exs1{i}]);
    rst(1).(tag1{i})  = load(['../data/outputs/' exs1{i} '_results_annual.mat']);
    zwtyr(1).(tag1{i})= load(['../data/outputs/' exs1{i} '_zwt_annual.mat']);
    qinf(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).qinfl(:,idx),2);
    qver(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).qh2oocn(:,idx),2);
    qlat(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).qlnd2ocn(:,idx),2);
    qrot(1).(tag1{i}) = nanmean(rst(1).(tag1{i}).qrunoff(:,idx),2);
    zwt(1).(tag1{i})  = max(zwtyr(1).(tag1{i}).zwtyr(:,idx),[],2);
end

foc_qinf = (qinf.fut_fut - qinf.ctl_ctl).*86400.*365.25;
foc_qlat     = (qlat.fut_fut - qlat.ctl_ctl).*86400.*365.25;
foc_qlat_SLR = (qlat.fut_fut - qlat.fut_ctl).*86400.*365.25;
foc_qver_SLR = (qver.fut_fut - qver.fut_ctl).*86400.*365.25;
foc_qrot_SLR = (qrot.fut_fut - qrot.fut_ctl).*86400.*365.25;
foc_zwt_FUT  = zwt.fut_fut - zwt.ctl_ctl;
foc_zwt_ATM  = zwt.fut_fut - zwt.ctl_fut;
foc_zwt_SLR  = zwt.fut_fut - zwt.fut_ctl;

ind_rm = abs((qrot.fut_fut - qrot.ctl_ctl) ./ qrot.ctl_ctl) > 3 | qrot.ctl_ctl < 0 | foc_qinf > 1000 | foc_qinf < -200 | foc_qver_SLR > 500 | foc_qver_SLR < -200;
 
fan8th(gl_mask | ind_small | ind_rm) = [];
foc_qinf(gl_mask | ind_small | ind_rm) = [];
foc_qlat(gl_mask | ind_small | ind_rm) = [];
foc_qlat_SLR(gl_mask | ind_small | ind_rm) = [];
foc_qver_SLR(gl_mask | ind_small | ind_rm) = [];
foc_qrot_SLR(gl_mask | ind_small | ind_rm) = [];
qlat.fut_fut(gl_mask | ind_small | ind_rm) = [];
qlat.ctl_ctl(gl_mask | ind_small | ind_rm) = [];
qlat.fut_ctl(gl_mask | ind_small | ind_rm) = [];

foc_zwt_FUT(gl_mask | ind_small | ind_rm) = [];
foc_zwt_ATM(gl_mask | ind_small | ind_rm) = [];
foc_zwt_SLR(gl_mask | ind_small | ind_rm) = [];
merit_x(gl_mask | ind_small | ind_rm) = [];
merit_y(gl_mask | ind_small | ind_rm) = [];
merit_frac(gl_mask | ind_small | ind_rm) = [];
merit_topo(gl_mask | ind_small | ind_rm) = [];
merit_area(gl_mask | ind_small | ind_rm) = [];
xv(:,gl_mask | ind_small | ind_rm) = [];
yv(:,gl_mask | ind_small | ind_rm) = [];

if exist('../data/map1deg.mat','file') && read_mapping
    load('../data/map1deg.mat');
else
    [lon,lat,fan1deg,mapping,map_1dto2d] = upscale_data(merit_x,merit_y,merit_frac,fan8th,1);
    save('../data/map1deg.mat','mapping','map_1dto2d','lon','lat');
end

load('../data/map1deg.mat');
foc1_1deg = mapping_1d_to_2d(foc_qinf,mapping,map_1dto2d,size(lon));
foc_qlat_SLR1deg = mapping_1d_to_2d(foc_qlat_SLR,mapping,map_1dto2d,size(lon));
foc_qver_SLR1deg = mapping_1d_to_2d(foc_qver_SLR,mapping,map_1dto2d,size(lon));
foc_qrot_SLR1deg = mapping_1d_to_2d(foc_qrot_SLR,mapping,map_1dto2d,size(lon));
foc3_1deg = mapping_1d_to_2d(foc_qlat,mapping,map_1dto2d,size(lon));
foc_zwt_FUT1deg =  mapping_1d_to_2d(foc_zwt_FUT,mapping,map_1dto2d,size(lon));
foc_zwt_SLR1deg =  mapping_1d_to_2d(foc_zwt_SLR,mapping,map_1dto2d,size(lon));
foc_zwt_ATM1deg =  mapping_1d_to_2d(foc_zwt_ATM,mapping,map_1dto2d,size(lon));
area1deg        =  mapping_1d_to_2d(merit_area.*merit_frac,mapping,map_1dto2d,size(lon));
labels = {'\Delta ZWT','\Delta ZWT_{SLR}','\Delta Seawater infiltration'};
% plot_exs3(lon,lat, foc1_1deg, foc2_1deg, foc3_1deg, -50, 50, labels);

cmin = [-0.5 -0.2 -50];
cmax = [+0.5 +0.2 +50];

plot_exs3(lon,lat,foc_zwt_FUT1deg,foc_zwt_SLR1deg,foc_qver_SLR1deg,cmin,cmax,labels);

cities = GetCities();
catogrory = 2;
SubR   = GetWorldSubRegions(catogrory,[]);


lon1d = lon(map_1dto2d);
lat1d = lat(map_1dto2d);

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
area1d        = area1deg(map_1dto2d);
figure;
for i = 1 : length(SubR)
    SubR(i).foc_zwt_SLR1d = nanmedian(foc_zwt_SLR1d(Sub1d == i));
    %SubR(i).foc_zwt_SLR1d = nansum(foc_zwt_SLR1d(Sub1d == i).*area1d(Sub1d == i))./nansum(area1d(Sub1d == i));
    subplot(4,4,i);
    ecdf(-foc_zwt_SLR1d(Sub1d == i));
    title(SubR(i).Name);
end

figure;
h = bar(-[SubR(:).foc_zwt_SLR1d]);
set(gca,'XTick',1:length(SubR),'XTickLabel',{SubR(:).Name});

figure;
cols = jet(length(SubR));
for i = 1 : length(SubR)
    plot(lon1d(Sub1d == i), lat1d(Sub1d == i),'x', 'Color', cols(i,:)); hold on;
end
legend([SubR(:).Name]);

cmap = getPyPlot_cMap('Blues',200); cmap(1,:) = [1 1 1];
figure; set(gcf,'Position',[10 10 1200 600],'renderer','Painters'); 
subplot(1,2,1);
X = [merit_topo foc_qver_SLR];
hist3(X,'CdataMode','auto','Nbins',[100,100],'LineStyle','none');
view(2);colormap(gca,cmap); clim([0 200]);
cb1 = colorbar('east');
hold on; grid on;
ylim([-20 400]); xlim([-20 1000]);

subplot(1,2,2);
X = [foc_qver_SLR -foc_zwt_SLR];
hist3(X,'CdataMode','auto','Nbins',[200,1000],'LineStyle','none');
view(2);colormap(gca,cmap); clim([0 300]);
cb1 = colorbar('east');
hold on; grid on;
xlim([-20 120]); ylim([-0.05 0.3]);

figure;
X = [foc_qver_SLR1deg(:) foc_qrot_SLR1deg(:)];
hist3(X,'CdataMode','auto','Nbins',[150,150],'LineStyle','none');
view(2);colormap(gca,cmap); clim([0 200]);
cb1 = colorbar('east');
hold on; grid on;
plot3([-20 400],[-20 400],[1000 1000],'r--','LineWidth',1);
xlim([-20 200]); ylim([-20 200]);

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

for ii = 1 : 4
    rst.(tag1{ii}).qinfl(gl_mask | ind_small | ind_rm,:)   = [];
    rst.(tag1{ii}).qh2oocn(gl_mask | ind_small | ind_rm,:) = [];
    rst.(tag1{ii}).qrunoff(gl_mask | ind_small | ind_rm,:) = [];
    rst.(tag1{ii}).qover(gl_mask | ind_small | ind_rm,:)   = [];
    rst.(tag1{ii}).qh2osfc(gl_mask | ind_small | ind_rm,:) = [];
    zwtyr.(tag1{ii}).zwtyr(gl_mask | ind_small | ind_rm,:) = [];
end

figure(101); set(gcf,'Position',[10 10 1200 800]);
figure(102); set(gcf,'Position',[10 10 1200 800]);
figure(103); set(gcf,'Position',[10 10 1200 800]);
figure(104); set(gcf,'Position',[10 10 1200 800]);
figure(201); set(gcf,'Position',[10 10 1200 800]);

CTL = load('../data/outputs/GFDL-CM4C192-SST_sshyr_CTL.mat');
FUT = load('../data/outputs/GFDL-CM4C192-SST_sshyr_FUT.mat');
CTL.SSHyr(gl_mask | ind_small | ind_rm,:) = [];
FUT.SSHyr(gl_mask | ind_small | ind_rm,:) = [];
CTL.Inundyr(gl_mask | ind_small | ind_rm,:) = [];
FUT.Inundyr(gl_mask | ind_small | ind_rm,:) = [];

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
plot(qrot_cities(j).(tag1{4})-qrot_cities(j).(tag1{3}),'r-','LineWidth',1);
title(cities(j).Name,'FontSize',14,'FontWeight','bold');

qrot_RC(j,1) = nanmean(qrot_cities(j).(tag1{4}) - qrot_cities(j).(tag1{3}))/nanmean(qrot_cities(j).(tag1{3}));
qrot_RC(j,2) = nanmean(qrot_cities(j).(tag1{4}) - qrot_cities(j).(tag1{1}))/nanmean(qrot_cities(j).(tag1{1}));
qsur_RC(j,1) = nanmean(qsur_cities(j).(tag1{4}) - qsur_cities(j).(tag1{3}))/nanmean(qsur_cities(j).(tag1{1}));
qsur_RC(j,2) = nanmean(qsur_cities(j).(tag1{4}) - qsur_cities(j).(tag1{1}))/nanmean(qsur_cities(j).(tag1{1}));

end

axs = plot_exs2(lon,lat,-foc_zwt_SLR1deg,foc_qver_SLR1deg,cmin(2:3),cmax(2:3),labels(2:3));
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
axes('Position',[0.14 0.55 0.1 0.175]);
tmp = NaN(length(cities),1);
for i = 1 : length(cities)
    tmp(i) = -nanmean(zwt_cities(i).(tag1{4}) - zwt_cities(i).(tag1{3}));
end
[~,I] = sort(tmp,'descend');
barh(flipud(tmp(I(1:15))));
set(gca,'YTick',[1:15],'YTickLabel',{cities(flipud(I(1:15))).Name});
set(gca,'box','off');

delete(axs(2));
pos = get(axs(1),'Position');

w0 = (pos(3)-0.15)/4;
d0 = 0.20;

k = 1;
labels2 = {'(b) ', '(c) ', '(d) ', '(e) '};

for i = [6 8 14 1]
    in = inpolygon(merit_x,merit_y,SubR(i).X,SubR(i).Y);
    a  = merit_frac(in).*merit_area(in);

    d1 = -nansum((zwtyr.fut_fut.zwtyr(in,idx) - zwtyr.fut_ctl.zwtyr(in,idx)).*a)./nansum(a);
    d2 = -nansum((zwtyr.ctl_fut.zwtyr(in,idx) - zwtyr.ctl_ctl.zwtyr(in,idx)).*a)./nansum(a);
    
    axes('Position',[pos(1)+(k-1)*(w0+0.05) pos(2)-0.25 w0 d0]);
    plot(2021:2050,d1,'x','Color',[0,153,143]./255,'LineWidth',1); hold on; grid on;
    [theta1,theta2]=LSE(2021:2035,d1(1 :15));
    plot([2021 2035],theta1 + theta2.*[2021 2035],'k--','LineWidth',1);
    [theta1,theta2]=LSE(2036:2050,d1(16:30));
    plot([2035 2050],theta1 + theta2.*[2035 2050],'k--','LineWidth',1);
    plot(1985:2014,d2,'x','Color',[240,163,255]./255,'LineWidth',1); 
    [theta1,theta2]=LSE(1985:1999,d2(1 :15));
    plot([1985 1999],theta1 + theta2.*[1985 1999],'k--','LineWidth',1);
    [theta1,theta2]=LSE(2000:2014,d2(16:30));
    plot([1999 2014],theta1 + theta2.*[1999 2014],'k--','LineWidth',1);

    xlim([1985 2050]); ylim([min([d1 d2]) max([d1 d2])]);
    set(gca,'FontSize',13);
    add_title(gca,[labels2{k} SubR(i).Name]);
    if k == 1
        ylabel('\Delta ZWT_{SLR}','FontSize',15,'FontWeight','bold');
    end
    k = k + 1;
end

axs2 = plot_exs2(lon,lat,foc_qver_SLR1deg,foc_qlat_SLR1deg.*1000,[-50 -50],[50 50],{'\Delta Seawater infiltration [mm/year]','\Delta Lateral flow [mm/year]'});
