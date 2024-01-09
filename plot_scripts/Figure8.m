clear;close all;clc;

load('Figure8_data.mat'); % Processed from ../code/Plot_01.m
addpath('../code/');

figure(8); set(gcf,'Position',[10 10 1000 600]);
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

exportgraphics(gcf,'Figure8.jpg','Resolution',400);