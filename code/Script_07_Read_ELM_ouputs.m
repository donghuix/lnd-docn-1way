clear;close all;clc;

scratch = '/compyfs/xudo627/e3sm_scratch/';
runs    = {'Calibration03_OCN2LND_sur_sub_coupling_22493fc.2022-11-17-115402', ...
           'Calibration04_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-102621', ...
           'Calibration06_OCN2LND_sur_sub_coupling_22493fc.2022-11-16-104615', ...
           'Calibration07_OCN2LND_sur_sub_coupling_22493fc.2022-11-18-140955'};
tags    = {'fd=0.2','fd=0.5','fd=5.0','fd=10.'};

for i = 1 : length(runs)
    rundir = [scratch runs{i} '/run/'];
    files  = dir([rundir '*.elm.h0.*.nc']);
    assert(length(files) == 128*12);
    %files  = files(64*12 + 1 : end);
    
    for j = 1 : length(files)
        filename = fullfile(files(j).folder,files(j).name);
        disp(['Reading ' num2str(j) '/' num2str(length(files))]);
        tmp  = ncread(filename,'ZWT');
        if j == 1
            numc = length(tmp); 
            zwtyr  = NaN(numc,length(files)/12);
        end
        if mod(j,12) == 1
            zwtmon = NaN(numc,12);
        end
        
        if mod(j,12) == 0
            zwtmon(:,12) = tmp;
            zwtyr(:,j/12)  = nanmean(zwtmon,2);
        else
            zwtmon(:,mod(j,12)) = tmp;
        end
    end
    save(['../data/outputs/' tags{i} '_zwt_annual.mat'],'zwtyr');
end