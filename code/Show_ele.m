clear;clc;close all;
addpath('/Users/xudo627/developments/getPanoply_cMap/');

longxy = ncread('/Users/xudo627/projects/cesm-inputdata/MOSART_NLDAS_8th_c210129.nc','longxy');
latixy = ncread('/Users/xudo627/projects/cesm-inputdata/MOSART_NLDAS_8th_c210129.nc','latixy');
ele    = ncread('/Users/xudo627/projects/cesm-inputdata/MOSART_NLDAS_8th_c210129.nc','ele');

frac   = ncread('/Users/xudo627/projects/cesm-inputdata/domain.lnd.nldas2_0224x0464_c110415.nc','frac');

ind = find(frac > 0 & frac < 0.99);
[ix,iy] = find(frac > 0 & frac < 0.99);
figure;
scatter(longxy(ind),latixy(ind),16,frac(ind),'filled'); colorbar;

SLR = 0.3;
x = 0 : 0.1 : 1;

inund = NaN(length(ind),1);

for i = 1 : length(ind)
    tmp = ele(ix(i),iy(i),:);
    tmp = tmp(:);
    if ~any(isnan(tmp)) && ~all(tmp == 0)
        [y,ic,ia] = unique(tmp);
        inund(i) = interp1(y,x(ic),SLR) - interp1(y,x(ic),0);
    end
end
cmap = getPanoply_cMap('NEO_modis_lst');
figure;
scatter(longxy(ind),latixy(ind),8,inund,'filled'); colorbar; colormap(cmap); caxis([0 0.2]);

figure;
imagesc(flipud(frac')); colormap(cmap);colorbar;
