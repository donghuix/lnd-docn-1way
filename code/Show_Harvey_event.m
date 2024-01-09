clear;close all;clc;
addpath('/Users/xudo627/donghui/mylib/m/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

event = 'Irene';%'Harvey';


if strcmp(event,'Harvey')
    wl = ncread('reanalysis_waterlevel_hourly_2017_08_v1.nc','waterlevel');
    time = ncread('reanalysis_waterlevel_hourly_2017_08_v1.nc','time');
    xc = ncread('reanalysis_waterlevel_hourly_2017_08_v1.nc','station_x_coordinate');
    yc = ncread('reanalysis_waterlevel_hourly_2017_08_v1.nc','station_y_coordinate');
    st = ncread('reanalysis_waterlevel_hourly_2017_08_v1.nc','stations');
    time = time./86400 + datenum(1900,1,1,0,0,0);
    [yrs,mos,das,hrs] = datevec(time);
    
    ind = find(das >= 23 & das <= 30 & mos == 8 & yrs == 2017);
    
    xb2 = [-95 -93 -93 -95 -95];
    yb2 = [28 28 30 30 28];
elseif strcmp(event,'Irene')
    wl = ncread('reanalysis_waterlevel_hourly_2011_08_v1.nc','waterlevel');
    time = ncread('reanalysis_waterlevel_hourly_2011_08_v1.nc','time');
    xc = ncread('reanalysis_waterlevel_hourly_2011_08_v1.nc','station_x_coordinate');
    yc = ncread('reanalysis_waterlevel_hourly_2011_08_v1.nc','station_y_coordinate');
    st = ncread('reanalysis_waterlevel_hourly_2011_08_v1.nc','stations');
    time = time./86400 + datenum(1900,1,1,0,0,0);
    [yrs,mos,das,hrs] = datevec(time);
    
    ind = find(das >= 21 & das <= 28 & mos == 8 & yrs == 2011);
    
    xb2 = [-77 -75 -75 -77 -77];
    yb2 = [37 37 39 39 37];
end

% US eastern Coastline
xb = [-105 -60 -60 -105];
yb = [25 25 55 55];
in = inpoly2([xc yc],[xb' yb']);

wl = wl(:,ind);
in2 = inpoly2([xc yc],[xb2' yb2']);

cmap = getPyPlot_cMap('seismic');
vidObj = VideoWriter([event '.avi']);
vidObj.FrameRate = 5;    
open(vidObj);

fig = figure; set(gcf,'Position',[10 10 1200 500]);
for i = 1 : length(ind)
    subplot(1,2,1);
    h(1) = scatter(xc(in),yc(in),8,wl(in,i),'filled'); colorbar; hold on; axis equal;
    h(2) = plot(xb2,yb2,'g-','LineWidth',2);
    caxis([-3 3]); colormap(cmap);
    subplot(1,2,2);
    h(3) = plot(time(ind),nanmean(wl(in2,:),1),'-','Color',[0.5 0.5 0.5],'LineWidth',1);
    h(4) = plot(time(ind(1:i)),nanmean(wl(in2,1:i),1),'r-','LineWidth',2); hold on;
    xlim([time(ind(1)) time(ind(end))]); ylim([-1 1]);
    datetick('x','mm/dd','keeplimits');
    datetag = [num2str(yrs(ind(i))) '-0' num2str(mos(ind(i))) '-' num2str(das(ind(i))) ', ' num2str(hrs(ind(i)))];
    title(datetag,'FontSize',15,'FontWeight','bold');
    pause(0.2);
    currFrame = getframe(fig);
    writeVideo(vidObj,currFrame);
    
    delete(h);
end
close(vidObj);
