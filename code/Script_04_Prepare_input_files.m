clear;close all;clc;

addpath('/Users/xudo627/donghui/CODE/Setup-E3SM-Mac/matlab-scripts-to-process-inputs/');
addpath('/Users/xudo627/donghui/mylib/m/');

load('domain_global_coastline_merit_90m.mat');

[merit_xv,merit_yv,merit_area] = xc2xv(merit_x,merit_y,1/8,1/8,1);
mask = ones(length(merit_x),1);
fname_out = 'domain_global_coastline_merit_90m.nc';

if ~exist('domain_global_coastline_merit_90m.nc','file')
    generate_lnd_domain(merit_x,merit_y,merit_xv,merit_yv,merit_frac,mask,[],fname_out);
    clm_gridded_surfdata_filename = ...
    '/Users/xudo627/projects/cesm-inputdata/surfdata_0.5x0.5_simyr2000_c190418.nc';
    lon = ncread(clm_gridded_surfdata_filename,'LONGXY');
    lat = ncread(clm_gridded_surfdata_filename,'LATIXY');

    in = NaN(length(merit_x),1);
    for i = 1 : length(merit_x)
        if mod(i,100) == 0
            disp(i);
        end
        dist = (lon - merit_x(i)).^2 + (lat - merit_y(i)).^2;
        in(i) = find(dist == min(dist(:)));
    end
end
if ~exist('surfdata_global_coastline_merit_90m_c220913.nc','file')
fname_out2 = CreateCLMUgridSurfdatForE3SM(  ...
                    in,                             ...
                    clm_gridded_surfdata_filename,  ...
                    '.', 'global_coastline_merit_90m',...
                    [],[],[],[],[], ...
                    [],[],[],[],[],[],[],[],[]);
end
ncwrite(fname_out2,'TOPO',merit_topo);
ncwrite(fname_out2,'LONGXY',merit_x);
ncwrite(fname_out2,'LATIXY',merit_y);

if 0
for i = 1 : 12
    if i < 10
        mon_tag = ['0' num2str(i)];
    else
        mon_tag = num2str(i);
    end
    disp(mon_tag);
    
    load(['../GFDL-CM4C192-SST_future_inundation_2050_' mon_tag '.mat']);
    
    nt = size(frac_ocn,2);
    varnames = {'T','Inund','SSH'};
    vars = cell(3,1);
    vars{1} = ones(84300,1,nt).*10;
    tmp = NaN(84300,1,nt);
    tmp = frac_ocn;
    tmp(isnan(tmp)) = 0;
    vars{2} = tmp;
    tmp = ones(84300,1,nt);
    vars{3} = tmp;

    t3h = 0:3/24:nt/8-1/24;
    fname = ['coastal_inundation.1981-' mon_tag '.nc'];
    create_stream(fname,merit_x,merit_y,['1981-' mon_tag '-01'],t3h',varnames,vars);
end
end
