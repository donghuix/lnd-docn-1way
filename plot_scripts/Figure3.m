clear;close all;clc;

load('Figure3_data.mat'); % Processed from ../code/Script_08_Calibrate_fdrain.m

figure(3); set(gcf,'Position',[10 10 1000 800],'renderer','Painters'); 
ax(1) = subplot(2,2,1);
X = [fan8th zwt_cal];
hist3(X,'CdataMode','auto','Nbins',[250,80],'LineStyle','none');
view(2);colormap(gca,cmap); ylim([-80 0]); xlim([-80 0]); caxis([0 400]);
cb1 = colorbar('east');
hold on; grid on;
h = plot3([0 -80],[0 -80],[2500 2500],'r--','LineWidth',2);
set(gca,'FontSize',15);cb1.FontSize = 15;
xlabel('Benchmark [m]','FontSize',18,'FontWeight','bold');
ylabel('Simulation [m]','FontSize',18,'FontWeight','bold');
add_title(gca,'(a)',20,'out');
ind = find(zwt_cal < 250);
[R2(1),RMSE(1),NSE(1),PBIAS(1)] = estimate_evaluation_metric(fan8th(ind),zwt_def(ind));
[R2(2),RMSE(2),NSE(2),PBIAS(2)] = estimate_evaluation_metric(fan8th(ind),zwt_cal(ind));
R2   = round(R2,2);
RMSE = round(RMSE,2);

pos1 = ax(1).Position;
dim = [pos1(1) pos1(2)+pos1(4)-0.1 0.1 0.1];
str = ['R^{2} = ' num2str(R2(2)) ', RMSE = ' num2str(RMSE(2))];
t1 = annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','none');
t1.FontSize = 18; t1.FontWeight = 'bold';
cb1.Position = [pos1(1)+pos1(3)+0.01 pos1(2) 0.01 pos1(4)];

ax(2) = subplot(2,2,2);
hist3(X,'CdataMode','auto','Nbins',[2500,800],'LineStyle','none');
view(2);colormap(gca,cmap); ylim([-5 0]); xlim([-5 0]); caxis([0 50]);
cb2 = colorbar('east');
hold on;
set(gca,'FontSize',15);cb2.FontSize = 15;
h = plot3([-5 0],[-5 0],[2500 2500],'r--','LineWidth',2);
xlabel('Benchmark [m]','FontSize',18,'FontWeight','bold');
ylabel('Simulation [m]','FontSize',18,'FontWeight','bold');
add_title(gca,'(b)',20,'out');
ind = find(zwt_cal >= -5 & fan8th >= -5);
[R2(1),RMSE(1),NSE(1),PBIAS(1)] = estimate_evaluation_metric(fan8th(ind),zwt_def(ind));
[R2(2),RMSE(2),NSE(2),PBIAS(2)] = estimate_evaluation_metric(fan8th(ind),zwt_cal(ind));
R2   = round(R2,2);
RMSE = round(RMSE,2);

pos2 = ax(2).Position;
dim = [pos2(1) pos2(2)+pos2(4)-0.1 0.1 0.1];
str = ['R^{2} = ' num2str(R2(2)) ', RMSE = ' num2str(RMSE(2))];
t2 = annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','none');
t2.FontSize = 18; t2.FontWeight = 'bold';
cb2.Position = [pos2(1)+pos2(3)+0.01 pos2(2) 0.01 pos2(4)];

ax(3) = axes('Position',[pos1(1) 0.05 pos2(1)+pos2(3)-pos1(1) pos1(2)-0.15]);
imAlpha = ones(size(zwtcal_1deg));
imAlpha(isnan(zwtcal_1deg - fan1deg)) = 0;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],zwtcal_1deg - fan1deg,'AlphaData',imAlpha); 
colormap(ax(3),flipud(blue2red(13))); cb3 = colorbar('east'); hold on; caxis([-6.5 6.5]); 
set(gca,'YDir','normal'); set(gca,'FontSize',15);
add_title(gca,'(c)', 20,'out');
ylim([-60 90]);
pos3 = ax(3).Position;
cb3.Position = [pos3(1)+pos3(3)+0.01 pos3(2) 0.01 pos3(4)];
cb3.FontSize = 15;
cb3.Label.String = 'Absolute bias [m]';
cb3.Label.FontSize = 15;
cb3.Label.FontWeight = 'bold';

exportgraphics(gcf,'Figure3.jpg','Resolution',400);