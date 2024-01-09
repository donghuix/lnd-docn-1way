close all;clc; clear;

load('../code/rf/rf_region.dat'); % Processed from ../code/rf/test_RF.ipynb

if exist('colorblind_colormap.mat','file')
    load('colorblind_colormap.mat');
    cmap = colorblind([11 6 10 2 1 ],:);
else
    cmap = jet(5);
end

catogrory = 2;
SubR   = GetWorldSubRegions(catogrory,[]);
nfeatures = 4;

labels = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(h)','(i)','(g)','(k)','(l)','(m)','(n)','(o)','(p)'};
figure; set(gcf,'Position',[10 10 1200 900]);
for i = 1 : 16
    axs(i) = subplot_tight(4,4,i,[0.06 0.04]);
    h = bar(1:nfeatures,rf_region(i,3:end)); ylim([0 1]); grid on;
    h.FaceColor = 'flat';
    for j = 1 : nfeatures
        h.CData(j,:) = cmap(j,:);
    end
    h.LineWidth = 2;
    set(gca,'FontSize',13);
    xticks(1:nfeatures)
    xticklabels({'SLR','\mu_{topo}','\sigma_{topo}','\Delta T_{air}','\Delta Pr'});
    set(get(gca, 'XAxis'), 'FontWeight', 'bold','FontSize',15);
    strs = {['\rho_{train} = ' num2str(round(rf_region(i,1),2))], ...
            ['\rho_{val}   = ' num2str(round(rf_region(i,2),2))]};
    add_title(gca,strs,12,'in');
    
    if i <= 12
        xticklabels("");
    end
    if i ~= 1 && i ~= 5 && i ~= 9 && i ~= 13
        yticklabels("");
    end
    add_title(gca,[labels{i} ' ' SubR(i).Name],16,'out');
end
%exportgraphics(gcf,'Figure_S8.pdf','ContentType','vector');

load('../code/rf/rf_global.dat');
figure; set(gcf,'Position',[10 10 600 400]);
h = bar(1:nfeatures,rf_global(3:end)); ylim([0 0.4]); grid on;
h.FaceColor = 'flat';
for j = 1 : nfeatures
    h.CData(j,:) = cmap(j,:);
end
h.LineWidth = 2;

strs = {['\rho_{train} = ' num2str(round(rf_global(1),2))], ...
        ['\rho_{val}   = ' num2str(round(rf_global(2),2))]};
set(gca,'FontSize',12);
add_title(gca,strs,12,'in');
ylabel('Mean decrease in impurity','FontSize',15,'FontWeight','bold');
xticks(1:nfeatures)
xticklabels({'SLR','\mu_{topo}','\sigma_{topo}','\Delta T_{air}','\Delta Pr'});
set(get(gca, 'XAxis'), 'FontWeight', 'bold','FontSize',15);
xlim([0.5 nfeatures+0.5]);
exportgraphics(gcf,'Figure6.jpg','Resolution',400);
