clear;close all;clc;

% Figure 2
load('Figure2_data.mat'); % processed data from ../code/process_elevation_profile.m

figure(2); set(gcf,'Position',[10 10 1200 500]);
ax(1) = subplot(1,2,1);

imagesc([grid_X(1,1) grid_X(end,end)], [grid_Y(1,1) grid_Y(end,end)],connect2); hold on;
colormap(cmap([2 3 1 4],:)); cbh = colorbar('west');
set(gca,'YDir','normal'); clim([-1.5 2.5]);
cbh.Ticks = [-1 0 1 2];
cbh.TickLabels = {'Ocean','Land','Lower area\newlineconnected\newlineto ocean','Lower area\newlinenot connected\newlineto ocean'};

ax(2) = subplot(1,2,2);
plot(inund2,0 : 0.1 : SLR_max,'r-o','LineWidth',1.5,'MarkerSize',8);grid on;hold on;
plot(inund0,0 : 0.1 : SLR_max,'b-d','LineWidth',1.5,'MarkerSize',8);
plot(inund, 0 : 0.1 : SLR_max,'k-s','LineWidth',1.5,'MarkerSize',8); 
xlim(ax(2),[0.019 0.115]);
ylim(ax(2),[0 1.1]);
leg = legend('MERIT-consider connectivity','MERIT-ignore connectivity','HydroSHEDS','FontSize',13,...
             'NumColumns',2,'Color','none','EdgeColor','none','Location','northwest');
leg.Position(2) = leg.Position(2) + 0.02;
set(gca,'FontSize',13);
xlabel('Inundation Fraction [-]','FontSize',14,'FontWeight','bold');
ylabel('Sea Surface Height [m]','FontSize',14,'FontWeight','bold');

% Adjust axis position
ax(1).Position(1) = ax(1).Position(1) - 0.05;
cbh.Position = [ax(1).Position(1) + ax(1).Position(3) + 0.01 ax(1).Position(2) 0.02 ax(1).Position(4)];
cbh.FontSize = 12; cbh.FontWeight = 'bold';
cbh.AxisLocation = 'out';
add_title(ax(1),'(a)',20,'out');
add_title(ax(2),'(b)',20,'out');

exportgraphics(gcf,'Figure2.jpg','Resolution',400);