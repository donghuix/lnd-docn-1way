clear;close all;clc;
addpath('/Users/xudo627/developments/getPanoply_cMap/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');
addpath('/Users/xudo627/donghui/mylib/m/');

plot_upscale = 1;

x = ncread('../projection/historical_msl_2000_01_v1.nc','station_x_coordinate');
y = ncread('../projection/historical_msl_2000_01_v1.nc','station_y_coordinate');

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
merit_topo = [];
merit_std  = [];
merit_bathtub = NaN(84300,101);
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
    
    tmp  = load(['../MERIT_frac/' tile(1:8) 'frac.mat']);
    tmp1 = load(['../MERIT_frac/' tile(1:8) 'dem_mu.mat']);
    ii = find(tmp.frac > 0 & tmp.frac < 1);
    merit_frac = [merit_frac; tmp.frac(ii)];
    merit_x    = [merit_x; tmp.x(ii)];
    merit_y    = [merit_y; tmp.y(ii)];
    merit_topo = [merit_topo; tmp1.dem_mu];
    tmp2 = load(['../MERIT_bathtub/' tile(1:8) 'bathtub.mat']);
    tmp3 = load(['../MERIT_bathtub/' tile(1:8) 'dem_std.mat']);
    merit_std  = [merit_std; tmp3.dem_std];
    merit_bathtub(length(merit_frac)-length(ii) + 1 : length(merit_frac),:) = tmp2.bathtub_ele;
end
fclose(fileID);

if 0
[merit_xv,merit_yv,merit_area] = xc2xv(merit_x,merit_y,1/8,1/8,1);

figure;
cmap = getPanoply_cMap('NEO_modis_lst');
patch(merit_xv,merit_yv,merit_frac,'LineStyle','none'); colormap(cmap); 
caxis([0 1]); colorbar; hold on;
ylim([-60 90]);
plot(x,y,'k.'); hold on;


figure;
cmap = getPanoply_cMap('NEO_modis_lst');
patch(merit_xv,merit_yv,merit_bathtub(:,6),'LineStyle','none'); colormap(cmap); 
colorbar; hold on;
ylim([-60 90]);

SLR = 0 : 0.1 : 10;
save('bathtub_global_coastline_merit_90m.mat','merit_bathtub','SLR');

idx_GTSM2ELM = NaN(length(merit_x),1);
for i = 1 : length(merit_x)
    dist = sqrt((merit_x(i) - x).^2 + (merit_y(i) - y).^2); 
    ind  = find(dist == min(dist));
    if isempty(ind)
        disp(['Empty: ' num2str(i)]);
    elseif length(ind) > 1
        disp(['Multiple: ' num2str(i) ', len = ' num2str(length(ind))]);
        idx_GTSM2ELM(i) = ind(1);
    else
        idx_GTSM2ELM(i) = ind;
    end
end
end

%save('domain_global_coastline_merit_90m.mat','merit_x','merit_y','merit_frac','merit_topo','idx_GTSM2ELM');


if plot_upscale
%[lon,lat,inund_1deg] = upscale_data(merit_x,merit_y,merit_bathtub(:,6),1);
[lon,lat,inund_1deg] = upscale_data(merit_x,merit_y,ones(length(merit_x),1),merit_topo,2);

imAlpha = ones(size(inund_1deg));
imAlpha(isnan(inund_1deg)) = 0;
figure;
imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],inund_1deg,'AlphaData',imAlpha); 
colormap(cmap); colorbar; hold on; %caxis([0 0.2]);
set(gca,'YDir','normal');

S = shaperead('/Users/xudo627/Downloads/World_Countries_(Generalized)/World_Countries__Generalized_.shp');
for i = 1 : length(S)
    plot(S(i).X,S(i).Y,'k-','LineWidth',1); 
end
ylim([-60 90]);

inundated_area = nansum(merit_area.*merit_bathtub(:,6))./1e6;
end