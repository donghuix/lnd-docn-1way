clear;close all;clc;
addpath('/Users/xudo627/Developments/getPanoply_cMap/');
addpath('/Users/xudo627/Developments/inpoly/');
addpath('/Users/xudo627/Developments/mylib/m/');
addpath('/Users/xudo627/Developments/m_map/');

cmap = getPanoply_cMap('NEO_modis_lst');

filename = '../inputdata/domain.lnd.r0125_WC14to60E2r3.200924.nc';
frac = ncread(filename,'frac');
xc   = ncread(filename,'xc');
yc   = ncread(filename,'yc');
ind  = find(frac > 0 & frac < 1 & yc >= -60);

fileID = fopen('../MERIT/MERIT_tiles.txt');
C = textscan(fileID,'%s');
tiles = cell(length(C{1}),1);

merit_frac = [];
merit_x = [];
merit_y = [];
figure;
for j = 1 : length(C{1})
    tiles{j} = C{1}{j};
    tile = tiles{j};
    if strcmp(tile(1),'n')
        ymin = str2double(tile(2:3));
    elseif strcmp(tile(1),'s')
        ymin = -str2double(tile(2:3));
    end

    ymax = ymin + 5;

    if strcmp(tile(4),'w')
        xmin = -str2double(tile(5:7));
    elseif strcmp(tile(4),'e')
        xmin = str2double(tile(5:7));
    end

    xmax = xmin + 5;

    %plot([xmin; xmax; xmax; xmin; xmin], [ymin; ymin; ymax; ymax; ymin],'k-','LineWidth',2); hold on;
    in = inpoly2([xc(ind) yc(ind)],[[xmin; xmax; xmax; xmin; xmin] [ymin; ymin; ymax; ymax; ymin]]);
    if sum(in) > 0
        disp(tile);
        plot([xmin; xmax; xmax; xmin; xmin], [ymin; ymin; ymax; ymax; ymin],'k-','LineWidth',2); hold on;
    end
    
    tmp = load(['../MERIT_frac/' tile(1:8) 'frac.mat']);
    ii = find(tmp.frac > 0 & tmp.frac < 1);
    merit_frac = [merit_frac; tmp.frac(ii)];
    merit_x    = [merit_x; tmp.x(ii)];
    merit_y    = [merit_y; tmp.y(ii)];
end
fclose(fileID);

[merit_xv,merit_yv,merit_area] = xc2xv(merit_x,merit_y,1/8,1/8);

%S = shaperead('/Users/xudo627/Downloads/World_Countries_(Generalized)/World_Countries__Generalized_.shp');
S = m_shaperead('/Users/xudo627/DATA/ne_10m_coastline/ne_10m_coastline');
figure;
cmap = getPanoply_cMap('NEO_modis_lst');
% patch(merit_xv,merit_yv,merit_frac,'LineStyle','none'); colormap(cmap); 
% caxis([0 1]); colorbar; hold on;
% ylim([-60 90]);

% dd = 1;
% lon = [-180 + dd/2 : dd : 180 - dd/2];
% lat = [90 - dd/2 : -dd : -90 + dd/2];
% [lon,lat] = meshgrid(lon,lat);
% [nx,ny] = size(lon);
% frac1deg = NaN(nx,ny);
% for i = 1 : nx
%     disp(i);
%     for j = 1 : ny
%         lonv = [lon(i,j) - dd/2; lon(i,j) + dd/2; lon(i,j) + dd/2; lon(i,j) - dd/2];
%         latv = [lat(i,j) - dd/2; lat(i,j) - dd/2; lat(i,j) + dd/2; lat(i,j) + dd/2;];
%         
%         in = inpoly2([merit_x merit_y],[lonv latv]);
%         if ~isempty(in)
%             frac1deg(i,j) = nanmean(merit_frac(in));
%         end
%     end
% end
% imAlpha = ones(size(frac1deg));
% imAlpha(isnan(frac1deg)) = 0;
% figure;
% imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],frac1deg,'AlphaData',imAlpha); 
% colormap(cmap); colorbar; caxis([0 1]); hold on;
% set(gca,'YDir','normal');
% ylim([-60 90]);

% ind = find(~isnan(frac1deg));
% coastline_countary = NaN(length(ind),1);
% for i = 1 : length(ind)
%     disp(i);
%     lonv = [lon(ind(i)) - dd/2; lon(ind(i)) + dd/2; lon(ind(i)) + dd/2; lon(ind(i)) - dd/2];
%     latv = [lat(ind(i)) - dd/2; lat(ind(i)) - dd/2; lat(ind(i)) + dd/2; lat(ind(i)) + dd/2;];
%         
%     for j = 1 : length(S)
%         in = inpoly2([S(j).X' S(j).Y'],[lonv latv]);
%         if sum(in) >= 1
%             coastline_countary(i,1) = j;
%         end
%     end
% end
% 
% a = unique(coastline_countary(~isnan(coastline_countary)));
% for i = 1 : length(S)
%     if any(a == i)
%         plot(S(i).X,S(i).Y,'k-','LineWidth',0.5); hold on;
%     end
% end
ylim([-60 90]);

sub_regions = struct([]);

sub_regions(1).xmin = -80; sub_regions(1).xmax = -75;
sub_regions(1).ymin = 34;  sub_regions(1).ymax = 39;
sub_regions(1).col  = 'b';

sub_regions(2).xmin = 8;   sub_regions(2).xmax = 13;
sub_regions(2).ymin = 38; sub_regions(2).ymax = 43;
sub_regions(2).col  = 'r';

sub_regions(3).xmin = 39;  sub_regions(3).xmax = 44;
sub_regions(3).ymin = -15; sub_regions(3).ymax = -10;
sub_regions(3).col  = 'g';

sub_regions(4).xmin = 108; sub_regions(4).xmax = 113;
sub_regions(4).ymin = 19;  sub_regions(4).ymax = 24;
sub_regions(4).col  = 'm';


[xv,yv] = xc2xv(xc(ind),yc(ind),1/8,1/8);
if 1 

labels = {'(b)','(c)','(d)','(e)','(f)','(g)','(h)','(i)','(j)','(k)'};
figure; set(gcf,'Position',[10 10 600 1200]);
ax = subplot(5,2,[1 2]);
patch(ax,merit_xv,merit_yv,merit_frac,'LineStyle','none'); colormap(cmap); hold on;
for i = 1 : length(S.ncst)
    plot(ax,S.ncst{i}(:,1),S.ncst{i}(:,2),'k-','LineWidth',1); hold on
end
set(ax,'xtick',[],'ytick',[]);
ax.Position(1) = ax.Position(1) - 0.050;
ax.Position(2) = ax.Position(2) - 0.025;
ax.Position(4) = ax.Position(4) + 0.075;
add_title(gca,'(a)',18,'in');
for i = 1 : length(sub_regions)
    xmin = sub_regions(i).xmin;
    xmax = sub_regions(i).xmax;
    ymin = sub_regions(i).ymin;
    ymax = sub_regions(i).ymax;
    plot(ax,[xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],'-','Color',sub_regions(i).col,'LineWidth',1.5);
    ylim(ax,[-60 90]);
%     ax1 = axes('Position',[0.15 0.425 0.125 0.225]);
%     ax2 = axes('Position',[0.15 0.175 0.125 0.225]);
    ax1(i) = subplot(5,2,i*2+1);
    patch(ax1(i),merit_xv,merit_yv,merit_frac,'LineStyle','none'); colormap(cmap); hold on;
    for j = 1 : length(S.ncst)
        plot(ax1(i),S.ncst{j}(:,1),S.ncst{j}(:,2),'k-','LineWidth',1); hold on
    end
    xlim(ax1(i),[xmin xmax]);
    ylim(ax1(i),[ymin ymax]); clim([0 1]);
    plot(ax1(i),[xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],'-','Color',sub_regions(i).col,'LineWidth',2);
    set(ax1(i),'xtick',[],'ytick',[]);
    %disp(['1: xmin = ' num2str(xmin) ', xmax = ' num2str(xmax) ', ymin = ' num2str(ymin) ', ymax = ' num2str(ymax)])
    ax1(i).Position(1) = ax1(i).Position(1) - 0.05;
    ax1(i).Position(2) = ax1(i).Position(2) - 0.02;
    ax1(i).Position(3) = ax1(i).Position(3) + 0.02;
    ax1(i).Position(4) = ax1(i).Position(4) + 0.02;
    add_title(gca,labels{(i-1)*2+1},18,'in');

    ax2(i) =subplot(5,2,i*2+2);
    patch(ax2(i),xv,yv,frac(ind),'LineStyle','none'); colormap(cmap); hold on;
    for j = 1 : length(S.ncst)
        plot(ax2(i),S.ncst{j}(:,1),S.ncst{j}(:,2),'k-','LineWidth',1); hold on
    end
    xlim(ax2(i),[xmin xmax]);
    ylim(ax2(i),[ymin ymax]); clim([0 1]);
    plot(ax2(i),[xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],'-','Color',sub_regions(i).col,'LineWidth',2);
    set(ax2(i),'xtick',[],'ytick',[]);
    ax2(i).Position(1) = ax2(i).Position(1) - 0.02 - 0.05;
    ax2(i).Position(2) = ax2(i).Position(2) - 0.02;
    ax2(i).Position(3) = ax2(i).Position(3) + 0.02;
    ax2(i).Position(4) = ax2(i).Position(4) + 0.02;
    %disp(['2: xmin = ' num2str(xmin) ', xmax = ' num2str(xmax) ', ymin = ' num2str(ymin) ', ymax = ' num2str(ymax)])
    add_title(gca,labels{(i-1)*2+2},18,'in');
    if i == 4
        cb = colorbar('east');
    end
end

cb.Position(1) = ax2(4).Position(1) + ax2(4).Position(3) + 0.02;
cb.Position(4) = ax2(1).Position(2) + ax2(1).Position(4) - cb.Position(2);
cb.FontSize = 13; cb.FontWeight = 'bold'; cb.YAxisLocation = 'right';
% xlim([xmin1 xmax1]);
% ylim([ymin1 ymax1]); colorbar; caxis([0 1]);

end

exportgraphics(gcf,'../writing/Figure_S1.jpg','Resolution',400);