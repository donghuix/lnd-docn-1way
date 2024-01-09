clear;close all;clc;

addpath('/qfs/people/xudo627/mylib/m/');

lon1d = ncread('../inputdata/surfdata_global_coastline_merit_90m_c221003.nc','LONGXY');
lat1d = ncread('../inputdata/surfdata_global_coastline_merit_90m_c221003.nc','LATIXY');
lon2d = ncread('/compyfs/lili400/project/ICoM/data/global_1k/hi1k/surf/8th/surfdat_global_8th.nc','lon');
lat2d = ncread('/compyfs/lili400/project/ICoM/data/global_1k/hi1k/surf/8th/surfdat_global_8th.nc','lat');

[lon2d,lat2d] = meshgrid(lon2d,lat2d);
lon2d = lon2d';
lat2d = lat2d';

fin = '/compyfs/lili400/project/ICoM/data/global_1k/hi1k/surf/8th/surfdat_global_8th.nc';
info = ncinfo(fin);
varnames = {info.Variables.Name};
varnames = varnames(3:end);

% Find mapping index from 2d global domain to 1d coastine domain
if exist('../data/ind_2d_to_1d.mat','file')
    load('../data/ind_2d_to_1d.mat');
else
    ind_2d_to_1d = NaN(length(lon1d),1);

    for i = 1 : length(lon1d)
        disp(['i = ' num2str(i) '/' num2str(length(lon1d))]);
        ind = find(lon2d == lon1d(i) & lat2d == lat1d(i));
        if isempty(ind)
            error('something wrong with coordinates');
        else
            ind_2d_to_1d(i) = ind;
        end
    end
    
    save('../data/ind_2d_to_1d.mat','ind_2d_to_1d');
end

fdrain = ones(length(lon1d),1).*2.5;

[nlon,nlat] = size(lon2d);
fout = '../inputdata/surfdata_global_coastline_merit_90m_fd2.5_c221109.nc';
ncaddvar('../inputdata/surfdata_global_coastline_merit_90m_c221003.nc', ...
         fout, 'fdrain', fdrain, 'NC_DOUBLE');

URBAN_REGION_ID = ncread(fout,'URBAN_REGION_ID');
ind = find(URBAN_REGION_ID == 0);
for i = 1 : length(ind)
    for k = 1 : 100
        if URBAN_REGION_ID(ind(i) + k) ~= 0
            URBAN_REGION_ID(ind(i)) = URBAN_REGION_ID(ind(i) + k);
            break;
        end
    end
end
ncwrite(fout,'URBAN_REGION_ID',URBAN_REGION_ID);

urban_pars = {'canyon_hwr', 'em_improad', 'em_perroad', 'em_roof', 'em_wall',           ...
              'ht_roof', 'thick_roof', 'thick_wall', 't_building_max','t_building_min', ...
              'wind_hgt_canyon', 'wtlunit_roof', 'wtroad_perv', 'alb_improad_dir',      ...
              'alb_improad_dif', 'alb_perroad_dir', 'alb_perroad_dif', 'alb_roof_dir',  ... 
              'alb_roof_dif', 'alb_wall_dir', 'alb_wall_dif', 'tk_roof', 'tk_wall',     ...
              'cv_roof', 'cv_wall'};
urban_pars = upper(urban_pars);

for i = 1 : length(urban_pars)
    var = ncread(fout,urban_pars{i});
    disp([urban_pars{i} ' dimension is ' num2str(length(size(var)))]);
    if length(size(var)) == 2
        ind = find(var(:,1) == 0);
        var(ind,:) = repmat(nanmean(var,1),length(ind),1);
    elseif length(size(var)) == 3
        var(ind,:,:) = repmat(nanmean(var,1),length(ind),1,1);
    else
        error('check the parameters!!!')
    end
    ncwrite(fout,urban_pars{i},var);
    %
end
% [status,msg] = copyfile('../inputdata/surfdata_global_coastline_merit_90m_c221003.nc', ...
%                         fout);
% disp(msg);

for i = 1 : length(varnames)
    varname = varnames{i};
    if strcmp(varname,'TOPO')
        disp([varname ' is not used!']);
%     elseif strcmp(varname,'PCT_CLAY') || strcmp(varname,'PCT_SAND') || ...
%            strcmp(varname,'ORGANIC')  || strcmp(varname,'SLOPE')    || ...
%            strcmp(varname,'STD_ELEV')
        
    else
        fprintf(['Writing ' varname]);
        var = ncread(fin,varname);
        nd  = ndims(var);
        fprintf(['...nd = ' num2str(nd) '\n']);
        sz  = size(var);
        assert(sz(1) == nlon);
        assert(sz(2) == nlat);
        if nd == 2
            var1d = var(ind_2d_to_1d);
            inan  = isnan(var1d);
            var1d(inan) = griddata(lon1d(~inan),lat1d(~inan),var1d(~inan), ...
                                   lon1d(inan),lat1d(inan),'nearest');
            ind = isnan(var1d);
            if sum(ind) > 0
                disp(['There are ' num2str(sum(ind)) ' NaNs in ' varname]);
            end
            ind2 = find(tmp(ind_2d_to_1d) > 99.9);
            if sum(ind2) > 0
                disp(['There are ' num2str(sum(ind2)) ' 100 in ' varname]);
            end
        elseif nd == 3
            var1d = NaN([length(ind_2d_to_1d) sz(3:end)]);
            for ii = 1 : sz(3)
                tmp = var(:,:,ii);
                var1d(:,ii) = tmp(ind_2d_to_1d);
                inan  = isnan(var1d(:,ii));
                var1d(inan,ii) = griddata(lon1d(~inan),lat1d(~inan),var1d(~inan,ii), ...
                                   lon1d(inan),lat1d(inan),'nearest');
                ind = isnan(var1d(:,ii));
                if ii == 1 && sum(ind) > 0
                    disp(['There are ' num2str(sum(ind)) ' NaNs in ' varname]);
                end
            end
        elseif nd == 4
            var1d = NaN([length(ind_2d_to_1d) sz(3:end)]);
            for ii = 1 : sz(3)
                for jj = 1 : sz(4)
                    tmp = var(:,:,ii,jj);
                    ind = isnan(tmp(ind_2d_to_1d));
                    if ii == 1 && jj == 1 && sum(ind) > 0
                        disp(['There are ' num2str(sum(ind)) ' NaNs in ' varname]);
                    end
                    var1d(:,ii,jj) = tmp(ind_2d_to_1d);
                end
            end
        elseif nd == 5
            var1d = NaN([length(ind_2d_to_1d) sz(3:end)]);
            for ii = 1 : sz(3)
                for jj = 1 : sz(4)
                    for kk = 1 : sz(5)
                        tmp = var(:,:,ii,jj,kk);
                        ind = isnan(tmp(ind_2d_to_1d));
                        if ii == 1 && jj == 1 && kk == 1 && sum(ind) > 0
                            disp(['There are ' num2str(sum(ind)) ' NaNs in ' varname]);
                        end
                        var1d(:,ii,jj,kk) = tmp(ind_2d_to_1d);
                    end
                end
            end
        end
        
        ncwrite(fout,varname,var1d);
        
    end
end


