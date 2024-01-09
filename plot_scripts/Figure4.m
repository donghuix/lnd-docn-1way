clear;close all;clc;

load('Figure4_data.mat'); % Processed from ../code/Plot_Bathtub_Inundation.m
addpath('../code/');

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
fprintf(['The ensemble inundaiton is about ' num2str(num) '%% of the mean projected inundation\n']);

exportgraphics(gcf,'Figure4.jpg','Resolution',400);