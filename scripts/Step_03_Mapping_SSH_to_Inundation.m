clear;close all;clc;

addpath('../code');

load('../data/bathtub_global_coastline_merit_90m.mat');
load('../data/domain_global_coastline_merit_90m.mat');

freq = '3h';
% idx_GTSM2ELM: mapping index from GTSM grid to ELM grid
numc = length(idx_GTSM2ELM);
GCM = {'CMCC-CM2-VHR4','EC-Earth3P-HR','GFDL-CM4C192-SST',              ...
       'HadGEM3-GC31-HM-SST','HadGEM3-GC31-HM'};

SLR = 0 : 0.1 : 10;
idx = 1 : size(merit_bathtub,1);
[X,Y] = meshgrid(idx,SLR);
X = X';
Y = Y';
F = griddedInterpolant(X,Y,merit_bathtub);

days_of_month = [31;28;31;30;31;30;31;31;30;31;30;31];
slr_offsets   = [0 0.25; 0.50; 0.75; 1.00];
slr_labels    = {'000','025','050','075','100'};
for i = [1 2 4 5]%1 : length(GCM)
    for iy = 1951 : 2014
        for im = 1 : 12
            disp([GCM{i} ', year: ' num2str(iy) ', month: ' num2str(im)]);
            if iy < 2016
                period  = 'CTL';
                tag     = 'historical';
            else
                period  = 'FUT';
                tag     = 'future';
            end
            
            if im < 10
                fin  = ['../data/' period '/' GCM{i} '_' tag '_waterlevel_' num2str(iy) '_0' num2str(im) '_v1.nc'];
         
            else
                fin  = ['../data/' period '/' GCM{i} '_' tag '_waterlevel_' num2str(iy) '_'  num2str(im) '_v1.nc'];
            end
            wl0 = ncread(fin,'waterlevel');
            
            for islr = 1 
                datadir = ['../MERIT_inundation/' slr_labels{islr} '/'];
                if im < 10
                fout = [datadir GCM{i} '_' tag '_inundation_' num2str(iy) '_0' num2str(im) '.mat'];
                else
                fout = [datadir GCM{i} '_' tag '_inundation_' num2str(iy) '_' num2str(im) '.mat'];
                end

                if exist(fout,'file')
                    disp('Already processed!');
                else
                
                wl = wl0(idx_GTSM2ELM,:) + slr_offsets(islr);

                numt = size(wl,2)/18;
                if size(wl,2) < days_of_month(im)*24*6
                    disp([GCM{i} ', year: ' num2str(iy) ', month: ' num2str(im) ' is not integer!!!']);
                    tmp = days_of_month(im)*24*6;
                    % use the last available data to fill the gap
                    wl(:,numt*18+1:tmp) = repmat(wl(:,numt*18),1,tmp - size(wl,2));
                    numt = size(wl,2)/18;
                end
                frac_ocn = NaN(numc,numt);
                ssh      = NaN(numc,numt);
                for k = 1 : numt
                    wl3h = nanmean(wl(:,(k-1)*18+1:k*18),2);
                    frac_ocn(:,k) = F(idx', wl3h);
                    ssh(:,k)      = wl3h;
                end
                save(fout,'frac_ocn','ssh');
                end
            end
        end
    end
end
