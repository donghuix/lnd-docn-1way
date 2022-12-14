clear;clc;close all;
addpath('/Users/xudo627/developments/getPanoply_cMap/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

longxy = ncread('/Users/xudo627/projects/cesm-inputdata/MOSART_NLDAS_8th_c210129.nc','longxy');
latixy = ncread('/Users/xudo627/projects/cesm-inputdata/MOSART_NLDAS_8th_c210129.nc','latixy');

frac   = ncread('/Users/xudo627/projects/cesm-inputdata/domain.lnd.nldas2_0224x0464_c110415.nc','frac');
xv     = ncread('/Users/xudo627/projects/cesm-inputdata/domain.lnd.nldas2_0224x0464_c110415.nc','xv');
yv     = ncread('/Users/xudo627/projects/cesm-inputdata/domain.lnd.nldas2_0224x0464_c110415.nc','yv');
ind = find(frac > 0 & frac < 0.99);
lon = longxy(ind);
lat = latixy(ind);
lonv = NaN(4,length(ind));
latv = NaN(4,length(ind));
dx = 1/8; dy = 1 / 8;
lonv(1,:) = lon - dx/2; lonv(2,:) = lon + dx/2; lonv(3,:) = lon + dx/2; lonv(4,:) = lon - dx/2; 
latv(1,:) = lat - dy/2; latv(2,:) = lat - dy/2; latv(3,:) = lat + dy/2; latv(4,:) = lat + dy/2; 
ele  = NaN(length(ind),100);
ele2 = NaN(length(ind),100);

%files = dir('/Volumes/LaCie/DATA/_processed/n*.mat');

dem2 = imread('../MERIT/n40w075_dem.tif');
dem2 = double(dem2);
dem2(dem2 == -9999) = NaN;

files = dir('../Topography/n*.mat');
load coastlines.mat;
figure;
for i = 1%1 : length(files)
 
    strs = strsplit(files(i).name,'.');
    tile = strs{1};
    ymin = str2double(tile(2:3));
    ymax = ymin + 5;
    xmin = -str2double(tile(5:7));
    xmax = xmin + 5;

    in = inpoly2([lon(:) lat(:)],[[xmin; xmax; xmax; xmin; xmin]  [ymin; ymin; ymax; ymax; ymin]]);
    in = find(in == 1);
    if ~isempty(in)
        disp(i);
    end
     
    if ~isempty(in)
        disp(tile);
        plot([xmin; xmax; xmax; xmin; xmin], [ymin; ymin; ymax; ymax; ymin],'k-','LineWidth',2); hold on;
        load(fullfile(files(i).folder,files(i).name));
        
        for j = 54 %: length(in)
            disp([tile ' ' num2str(i) ': ' num2str(j) '/' num2str(length(in))]);
%             in2 = inpoly2([X(:) Y(:)], [lonv(:,in(j)) latv(:,in(j))]);
            j1 = min(find(X(1,:) >= min(lonv(:,in(j)))));
            j2 = max(find(X(1,:) <= max(lonv(:,in(j)))));
            
            i1 = max(find(Y(:,1) >= min(latv(:,in(j)))));
            i2 = min(find(Y(:,1) <= max(latv(:,in(j)))));
            
            if ~isempty(i1)
                tmp  = dem(i2:i1,j1:j2);
                tmp2 = dem2(i2:i1,j1:j2);
                for k = 1 : 101
                    ele(in(j),k)  = prctile(tmp(:),(k-1));
                    ele2(in(j),k) = prctile(tmp2(:),(k-1));
                end
                
            end
        end
        
    end
end
%save('coastline_ele.mat','ele','ind','lon','lat','lonv','latv');

plot(coastlon,coastlat,'r-','LineWidth',2);
xlim([-160 -20]);
ylim([0 70]);
figure;
cmap = getPanoply_cMap('NEO_modis_lst',0);
imagesc(flipud(frac')); colormap(cmap);colorbar;

figure;
plot(0:0.01:1,ele(in(j),:),'k-','LineWidth',2); hold on;
plot(0:0.01:1,ele2(in(j),:),'b--','LineWidth',2); 
xlabel('Fraction','FontSize',15,'FontWeight','bold');
ylabel('Elevation','FontSize',15,'FontWeight','bold');
legend('HydroSHEDS','MERIT','FontSize',15);

figure;
plot(0:0.01:1,ele(in(j),:),'k-','LineWidth',2); hold on;
%plot(0:0.01:1,ele2(in(j),:),'b--','LineWidth',2); 


ny = (i1-i2+1);
nx = (j2-j1+1);
grid_dem = reshape(dem2(i2:i1,j1:j2),[ny,nx]);
grid_x   = X(i2:i1,j1:j2);
grid_y   = Y(i2:i1,j1:j2);

SLR_max = 5;

connect = bathtub(grid_dem,SLR_max);
%grid_dem(~connect & ~isnan(grid_dem)) = 9999;

k = 1;
for SLR = 0 : 0.1 : SLR_max
    disp(['SLR = ' num2str(SLR)]);
    below    = grid_dem <= SLR & connect;
    below0   = grid_dem <= SLR;
%     below    = bathtub(below,nx,ny);
    inund(k,1) = sum(below(:)) / length(find(~isnan(grid_dem(:))));
    inund0(k,1) = sum(below0(:)) / length(find(~isnan(grid_dem(:))));
    k = k + 1;
end

connect(isnan(grid_dem)) = -1;

hold on;
plot(inund0,0 : 0.1 : SLR_max,'b--','LineWidth',2);
plot(inund,0 : 0.1 : SLR_max,'r-o','LineWidth',1);
legend('HydroSHEDS','MERIT','Bathtub','FontSize',15);

xlim([min(inund) max(inund)]);
xlabel('Fraction','FontSize',15,'FontWeight','bold');
ylabel('Elevation','FontSize',15,'FontWeight','bold');

cmap = getPyPlot_cMap('Set1',9);

figure; set(gcf,'Position',[10 10 1400 500]);

subplot(1,2,1);
connect0 = connect;
connect0(grid_dem < SLR_max) = 1;
imagesc(connect0); colormap(cmap([2 3 1],:));
cbh = colorbar ; %Create Colorbarc
caxis([-1.5 1.5]);
cbh.Ticks = [-1 0 1];
cbh.TickLabels = {'Ocean','Land','Flooded'};
title('No connectivity','FontSize',15,'FontWeight','bold');

subplot(1,2,2);
imagesc(connect); colormap(cmap([2 3 1],:));
cbh = colorbar ; %Create Colorbarc
caxis([-1.5 1.5]);
cbh.Ticks = [-1 0 1];
cbh.TickLabels = {'Ocean','Land','Flooded'};
title('With connectivity','FontSize',15,'FontWeight','bold');

% cmap2 = getPyPlot_cMap('terrain');
% figure;
% subplot(1,3,1);
% imAlpha = ones(size(dem));
% imAlpha(isnan(dem)) = 0;
% imagesc(dem,'AlphaData',imAlpha); caxis([0 1800]); colorbar;colormap(gca,cmap2);
% title('HydroSHEDS','FontSize',13,'FontWeight','bold');
% 
% subplot(1,3,2);
% imAlpha = ones(size(dem2));
% imAlpha(isnan(dem2)) = 0;
% imagesc(dem2,'AlphaData',imAlpha); caxis([0 1800]); colorbar;colormap(gca,cmap2);
% title('MERIT','FontSize',13,'FontWeight','bold');
% 
% subplot(1,3,3);
% imAlpha = ones(size(dem));
% imAlpha(isnan(dem - dem2)) = 0;
% imagesc(dem - dem2,'AlphaData',imAlpha); colorbar;caxis([-10 10]);
% colormap(gca,blue2red(121));
% title('HydroSHEDS - MERIT','FontSize',13,'FontWeight','bold');


% ele_grid = ele2(in(j),:);
% x = 0 : 0.01 : 1;
% [y,ic,ia] = unique(ele_grid(:));
% inund = interp1(y,x(ic),0);

%{
function below = bathtub(below,nx,ny)
    inund0 = sum(below(:))./(nx * ny);
    inund1 = 0;
    
    i = 1;
    while inund1 < inund0
        disp(['Interation #' num2str(i)]);
        inund0 = sum(below(:))./(nx * ny);
        below = modify_inundated(below,nx,ny);
        inund1 = sum(below(:))./(nx * ny);
        i = i + 1;
    end
    
end

function below = modify_inundated(below,nx,ny)

    ind      = find(below == 1);
    for i = 1 : length(ind)
        [iy,ix] = ind2sub([ny,nx],ind(i));

        if iy < ny && ix < nx && iy > 1 && ix > 1
            if below(iy-1,ix) == 0 && ...
               below(iy,ix+1) == 0 && ...
               below(iy+1,ix) == 0 && ...
               below(iy,ix-1) == 0

                below(iy,ix) = 0;
            end
        elseif iy == ny && ix < nx && iy > 1 && ix > 1
            if below(iy-1,ix) == 0 && ...
               below(iy,ix+1) == 0 && ...
               below(iy,ix-1) == 0

                below(iy,ix) = 0;
            end
        elseif iy < ny && ix == nx && iy > 1 && ix > 1
            if below(iy-1,ix) == 0 && ...
               below(iy+1,ix) == 0 && ...
               below(iy,ix-1) == 0

                below(iy,ix) = 0;
            end
        elseif iy < ny && ix < nx && iy == 1 && ix > 1
            if below(iy,ix+1) == 0 && ...
               below(iy+1,ix) == 0 && ...
               below(iy,ix-1) == 0

                below(iy,ix) = 0;
            end
        elseif iy < ny && ix < nx && iy > 1 && ix == 1
            if below(iy-1,ix) == 0 && ...
               below(iy,ix+1) == 0 && ...
               below(iy+1,ix) == 0

                below(iy,ix) = 0;
            end
        end
    end

end
%}