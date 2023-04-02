clear;close all;clc;

load('../data/domain_global_coastline_merit_90m.mat');
load coastlines.mat;
load('../data/greenland.mat');
gl_mask   = inpoly2([merit_x merit_y],[x y]);
ind_small = merit_frac < 0.05;

cities = GetCities();

merit_x(gl_mask | ind_small) = [];
merit_y(gl_mask | ind_small) = [];
merit_frac(gl_mask | ind_small) = [];
merit_topo(gl_mask | ind_small) = [];
merit_area(gl_mask | ind_small) = [];


load('../data/outputs/GFDL-CM4C192-SST_sshyr.mat');
SSHyr(gl_mask | ind_small,:) = [];

dx = 5; dy = 5;
for i = 1 : length(cities)
    figure(101);
    subplot(4,5,i);
    x  = cities(i).X; y = cities(i).Y;
    xb = [x - dx/2; x + dx/2; x + dx/2; x - dx/2; x - dx/2];
    yb = [y - dy/2; y - dy/2; y + dy/2; y + dy/2; y - dy/2];
    ind = inpoly2([merit_x merit_y],[xb yb]);
    
    ssh = nanmean(SSHyr(ind,:),1).*1000;
    plot(2016:2050,ssh,'k-','LineWidth',2);
    title(cities(i).Name);
    ylim([0 400]);
end