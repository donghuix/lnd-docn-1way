clear;close all;clc;

scratch = '/compyfs/xudo627/e3sm_scratch/';
runs    = {'Calibration01_OCN2LND_sur_sub_coupling_22493fc.2022-11-14-131718', ...
           'Calibration02_OCN2LND_sur_sub_coupling_22493fc.2022-11-21-100919', ...
           'Calibration03_OCN2LND_sur_sub_coupling_22493fc.2022-11-17-115402', ...
           'Calibration04_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-102621', ...
           'Calibration05_OCN2LND_sur_sub_coupling_22493fc.2022-11-15-101154', ...
           'Calibration06_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-104615', ...
           'Calibration07_OCN2LND_sur_sub_coupling_22493fc.2022-11-18-140955', ...
           'Calibration08_OCN2LND_sur_sub_coupling_22493fc.2022-11-21-095422', ...
           'Calibration09_OCN2LND_sur_sub_coupling_22493fc.2022-11-28-144612'};

tags    = {'fd=2.5','fd=0.1','fd=0.2','fd=0.5','fd=1.0','fd=5.0','fd=10.0','fd=20','fd=cal'};

for i = 1 : length(runs)
    
    if ~exist(['../data/outputs/' tags{i} '_zwt_annual.mat'],'file')
        
    rundir = [scratch runs{i} '/run/'];
    files  = dir([rundir '*.elm.h0.*.nc']);
    assert(length(files) == 128*12);
    %files  = files(64*12 + 1 : end);
    
    for j = 1 : length(files)
        filename = fullfile(files(j).folder,files(j).name);
        disp(['Reading ' num2str(j) '/' num2str(length(files))]);
        tmp   = ncread(filename,'ZWT');
        tmp2  = ncread(filename,'ZWT_PERCH');
        if j == 1
            numc        = length(tmp); 
            zwtyr       = NaN(numc,length(files)/12);
            zwt_perchyr = NaN(numc,length(files)/12);
        end
        if mod(j,12) == 1
            zwtmon       = NaN(numc,12);
            zwt_perchmon = NaN(numc,12);
        end
        
        if mod(j,12) == 0
            zwtmon(:,12)        = tmp;
            zwt_perchmon(:,12)  = tmp2;
            zwtyr(:,j/12)       = nanmean(zwtmon,2);
            zwt_perchyr(:,j/12) = nanmean(zwt_perchmon,2);
        else
            zwtmon(:,mod(j,12))       = tmp;
            zwt_perchmon(:,mod(j,12)) = tmp2;
        end
    end
    
    save(['../data/outputs/' tags{i} '_zwt_annual.mat'],'zwtyr','zwt_perchyr');
    
    end
    
end