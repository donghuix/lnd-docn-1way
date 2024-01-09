clear;close all;clc;

addpath('/qfs/people/xudo627/Setup-E3SM-Mac/matlab-scripts-to-process-inputs/');
addpath('/qfs/people/xudo627/mylib/m/');
addpath('../code/');

noleap = true; % no leap year

load('../data/domain_global_coastline_merit_90m.mat');

[merit_xv,merit_yv,merit_area] = xc2xv(merit_x,merit_y,1/8,1/8,1);
mask = ones(length(merit_x),1);
fname_out = 'domain_global_coastline_merit_90m.nc';

% if ~exist('../inputdata/domain_global_coastline_merit_90m.nc','file')
%     generate_lnd_domain(merit_x,merit_y,merit_xv,merit_yv,merit_frac,mask,[],fname_out);
%     clm_gridded_surfdata_filename = ...
%     '/Users/xudo627/projects/cesm-inputdata/surfdata_0.5x0.5_simyr2000_c190418.nc';
%     lon = ncread(clm_gridded_surfdata_filename,'LONGXY');
%     lat = ncread(clm_gridded_surfdata_filename,'LATIXY');
% 
%     in = NaN(length(merit_x),1);
%     for i = 1 : length(merit_x)
%         if mod(i,100) == 0
%             disp(i);
%         end
%         dist = (lon - merit_x(i)).^2 + (lat - merit_y(i)).^2;
%         in(i) = find(dist == min(dist(:)));
%     end
% end
% if ~exist('../inputdata/surfdata_global_coastline_merit_90m_c220913.nc','file')
%     fname_out2 = CreateCLMUgridSurfdatForE3SM(  ...
%                         in,                             ...
%                         clm_gridded_surfdata_filename,  ...
%                         '.', 'global_coastline_merit_90m',...
%                         [],[],[],[],[], ...
%                         [],[],[],[],[],[],[],[],[]);
%     ncwrite(fname_out2,'TOPO',merit_topo);
%     ncwrite(fname_out2,'LONGXY',merit_x);
%     ncwrite(fname_out2,'LATIXY',merit_y);
% end

yrs      = [1951:2014 2016:2050];
model    = 'GFDL-CM4C192-SST';
datadir  = '../MERIT_inundation/';
inputdir = '/compyfs/inputdata/ocn/docn7/GTSM/';

%inline function to determine leap year
ly=@(yr)~rem(yr,400)|rem(yr,100)&~rem(yr,4);

for i = yrs
    for j = 1 : 12
        if j < 10
            mon_tag = ['0' num2str(j)];
        else
            mon_tag = num2str(j);
        end
        
        fname = [inputdir 'coastal_inundation.' num2str(i) '-' mon_tag '.nc'];
        
        fix_leap = false;
        if ly(i) && j == 2 && noleap
            disp(['Fixing year: ' num2str(i) ', month: ' num2str(j)]);
            fix_leap = true;
        end
            
        if ~exist(fname,'file') || fix_leap
            if i <= 2014
            load([datadir model '_historical_inundation_' num2str(i) '_' mon_tag '.mat']);
            else
            load([datadir model '_future_inundation_'     num2str(i) '_' mon_tag '.mat']);    
            end
            
            disp(mon_tag);

            nt = size(frac_ocn,2);
            if fix_leap
                disp('Fixing');
                assert(nt == 29*8);
                nt = 28*8;
            end
            varnames = {'T','Inund','SSH'};
            vars = cell(3,1);
            vars{1} = ones(84300,1,nt).*10;
            tmp = NaN(84300,1,nt);
            tmp = frac_ocn(:,1:nt);
            tmp(isnan(tmp)) = 0;
            vars{2} = tmp;
            tmp = ssh(:,1:nt);
            tmp(isnan(tmp)) = 0;
            vars{3} = tmp;

            t3h = 0:3/24:nt/8-1/24;
            create_stream(fname,merit_x,merit_y,[num2str(i) '-' mon_tag '-01'],t3h',varnames,vars);
        end
    end
end
