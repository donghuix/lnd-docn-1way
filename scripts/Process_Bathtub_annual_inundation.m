clear;close all;clc;

GCM = {'CMCC-CM2-VHR4','EC-Earth3P-HR','GFDL-CM4C192-SST',              ...
       'HadGEM3-GC31-HM-SST','HadGEM3-GC31-HM'};

datadir = '/compyfs/xudo627/lnd-docn-1way/MERIT_inundation/000/';
inund_ann = NaN(84300,35,5);
for i = 1 : length(GCM)
    for j = 2016 : 2050
        tmp = NaN(84300,12);
        for k = 1 : 12
            disp(['Model: ' GCM{i} ', Year: ' num2str(j) ', Month: ' num2str(k)]);
            if k < 10
                filename = [datadir GCM{i} '_future_inundation_' num2str(j) '_0' num2str(k) '.mat'];
            else
                filename = [datadir GCM{i} '_future_inundation_' num2str(j) '_'  num2str(k) '.mat'];
            end
            load(filename);
            tmp(:,k) = nanmean(frac_ocn,2);
        end
        inund_ann(:,j-2016+1,i) = nanmean(tmp,2);
    end
end
save('inund_ann.mat','inund_ann');