clear;close all;clc;

type = 'sim';

scratch = '/compyfs/xudo627/e3sm_scratch/';
if strcmp(type,'cal')
    
    runs = {'Calibration01_OCN2LND_sur_sub_coupling_22493fc.2022-11-14-131718', ...
            'Calibration02_OCN2LND_sur_sub_coupling_22493fc.2022-11-21-100919', ...
            'Calibration03_OCN2LND_sur_sub_coupling_22493fc.2022-11-17-115402', ...
            'Calibration04_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-102621', ...
            'Calibration05_OCN2LND_sur_sub_coupling_22493fc.2022-11-15-101154', ...
            'Calibration06_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-104615', ...
            'Calibration07_OCN2LND_sur_sub_coupling_22493fc.2022-11-18-140955', ...
            'Calibration08_OCN2LND_sur_sub_coupling_22493fc.2022-11-21-095422', ...
            'Calibration09_OCN2LND_sur_sub_coupling_22493fc.2022-11-28-144612'};
    tags    = {'fd=2.5','fd=0.1','fd=0.2','fd=0.5','fd=1.0','fd=5.0','fd=10.0','fd=20','fd=cal'};
elseif strcmp(type,'sim')
    
    runs = {'OCN2LND_sur_sub_gfdl-esm4_historical_39b1f87.2022-12-05-220419',        ...
            'OCN2LND_sur_sub_gfdl-esm4_historical_ssp585_39b1f87.2022-12-17-153813', ...
            'OCN2LND_sur_sub_gfdl-esm4_ssp585_historical_39b1f87.2022-12-17-104600', ...
            'OCN2LND_sur_sub_gfdl-esm4_ssp585_39b1f87.2022-12-10-165041',            ...
            'OCN2LND_sur_sub_gfdl-esm4_historical_ssp585_SLR0.25_39b1f87.2022-12-19-215706', ...
            'OCN2LND_sur_sub_gfdl-esm4_historical_ssp585_SLR0.50_39b1f87.2022-12-19-220754', ...
            'OCN2LND_sur_sub_gfdl-esm4_historical_ssp585_SLR0.75_39b1f87.2022-12-20-084505', ...
            'OCN2LND_sur_sub_gfdl-esm4_historical_ssp585_SLR1.00_39b1f87.2022-12-20-085815'};
        
    tags = {'ctl-ctl','ctl-fut','fut-ctl','fut-fut','ctl-025','ctl-050','ctl-075','ctl-100'}; 
    
end

           

for i = 1 : length(runs)
    
    rundir = [scratch runs{i} '/run/'];
    
    if ~exist(['../data/outputs/' tags{i} '_zwt_annual.mat'],'file')
    
    files  = dir([rundir '*.elm.h0.*.nc']);
    assert(length(files) == 128*12 || length(files) == 35*12 || length(files) == 64*12);
    %files  = files(64*12 + 1 : end);
    
    for j = 1 : length(files)
        filename = fullfile(files(j).folder,files(j).name);
        disp(['Reading ' num2str(j) '/' num2str(length(files))]);
        tmp   = ncread(filename,'ZWT');
        tmp2  = ncread(filename,'ZWT_PERCH');
        
        if strcmp(type,'sim')
           tmp3  = ncread(filename,'QRUNOFF');
           tmp4  = ncread(filename,'QOVER');
           tmp5  = ncread(filename,'QH2OOCN');
           tmp6  = ncread(filename,'QLND2OCN');
           tmp7  = ncread(filename,'QINFL');
        end
        
        if j == 1
            numc        = length(tmp); 
            zwtyr       = NaN(numc,length(files)/12);
            zwt_perchyr = NaN(numc,length(files)/12);
            if strcmp(type,'sim')
                qrunoff     = NaN(numc,length(files)/12);
                qover       = NaN(numc,length(files)/12);
                qh2oocn     = NaN(numc,length(files)/12);
                qlnd2ocn    = NaN(numc,length(files)/12);
                qinfl       = NaN(numc,length(files)/12);
            end
        end
        
        if mod(j,12) == 1
            zwtmon       = NaN(numc,12);
            zwt_perchmon = NaN(numc,12);
            if strcmp(type,'sim')
                qrunoff_mon  = NaN(numc,12);
                qover_mon    = NaN(numc,12);
                qh2oocn_mon  = NaN(numc,12);
                qlnd2ocn_mon = NaN(numc,12);
                qinfl_mon    = NaN(numc,12);
            end
        end
        
        if mod(j,12) == 0
            zwtmon(:,12)       = tmp;
            zwt_perchmon(:,12) = tmp2;
            zwtyr(:,j/12)       = nanmean(zwtmon,2);
            zwt_perchyr(:,j/12) = nanmean(zwt_perchmon,2);
            
            if strcmp(type,'sim')
                qrunoff_mon(:,12)  = tmp3;
                qover_mon(:,12)    = tmp4;
                qh2oocn_mon(:,12)  = tmp5;
                qlnd2ocn_mon(:,12) = tmp6;
                qinfl_mon(:,12)    = tmp7;
                qrunoff(:,j/12)  = nanmean(qrunoff_mon,2);
                qover(:,j/12)    = nanmean(qover_mon,2);
                qh2oocn(:,j/12)  = nanmean(qh2oocn_mon,2);
                qlnd2ocn(:,j/12) = nanmean(qlnd2ocn_mon,2);
                qinfl(:,j/12)    = nanmean(qinfl_mon,2);
            end
            
        else
            
            zwtmon(:,mod(j,12))       = tmp;
            zwt_perchmon(:,mod(j,12)) = tmp2;
            if strcmp(type,'sim')
                qrunoff_mon(:,mod(j,12))  = tmp3;
                qover_mon(:,mod(j,12))    = tmp4;
                qh2oocn_mon(:,mod(j,12))  = tmp5;
                qlnd2ocn_mon(:,mod(j,12)) = tmp6;
                qinfl_mon(:,mod(j,12))    = tmp7;
            end
            
        end
    end
    
    save(['../data/outputs/' tags{i} '_zwt_annual.mat'],'zwtyr','zwt_perchyr');
    
    if strcmp(type,'sim')
        save(['../data/outputs/' tags{i} '_results_annual.mat'],'qrunoff', ...
              'qover','qh2oocn','qlnd2ocn','qinfl');
    end
    
    end
    
    if ~exist(['../data/outputs/' tags{i} '_AMR.mat'],'file')
        % Read daily outputs
        if i == 1 || i == 2 || i > 4
            yr1 = 1971; yr2 = 2005;
        elseif i == 3 || i == 4
            yr1 = 2016; yr2 = 2050;
        end

        AMTR = NaN(84300,yr2-yr1+1);
        AMDR = NaN(84300,yr2-yr1+1);
        for yr = yr1 : yr2
            files = dir([rundir '*.elm.h1.' num2str(yr) '*.nc']);
            assert(length(files) == 365 || length(files) == 366);
            tmp1 = NaN(84300,length(files));
            tmp2 = NaN(84300,length(files));
            for ii = 1 : length(files)
                filename = fullfile(files(ii).folder,files(ii).name);
                disp(filename);
                tmp1(:,ii) = ncread(filename,'QRUNOFF');
                tmp2(:,ii) = ncread(filename,'QDRAI');
            end
            AMTR(:,yr-yr1+1) = max(tmp1,[],2);
            AMDR(:,yr-yr1+1) = max(tmp2,[],2);
        end

        save(['../data/outputs/' tags{i} '_AMR.mat'],'AMTR','AMDR');
    end
    
end