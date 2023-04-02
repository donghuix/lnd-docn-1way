clear;close all;clc;

addpath('/Users/xudo627/donghui/mylib/m/');

frac = ncread('/Users/xudo627/projects/cesm-inputdata/domain.lnd.r05_oEC60to30v3.190418.nc','frac');
lon  = ncread('/Users/xudo627/projects/cesm-inputdata/domain.lnd.r05_oEC60to30v3.190418.nc','xc');
lat  = ncread('/Users/xudo627/projects/cesm-inputdata/domain.lnd.r05_oEC60to30v3.190418.nc','yc');
load('/Users/xudo627/projects/lnd-docn-1way/data/outputs/ctl-ctl_results_annual.mat');
load('../data/domain_global_coastline_merit_90m.mat');

ind = find(nanmean(qrunoff,2) < 0);
plot_globalspatial(lon,lat,frac'); colormap("jet"); hold on;
plot(merit_x(ind),merit_y(ind),'g.');