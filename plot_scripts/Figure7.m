clear;close all;clc;

load('Figure7_data.mat'); % Processed from ../code/Plot_01.m
addpath('../code/');

[axs3, cbs3] = plot_exs2(lon,lat,foc_tgrd_SLR1deg,foc_qrot_SLR1deg,[-0.5 -100],[0.5 100],...
               {'',''});
colormap(axs3(1),cmap10);
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

exportgraphics(gcf,'Figure7.jpg','Resolution',400);