clear;close all;clc;

GCM = {'CMCC-CM2-VHR4','EC-Earth3P-HR','GFDL-CM4C192-SST',              ...
       'HadGEM3-GC31-HM-SST','HadGEM3-GC31-HM'};
GCM = GCM(3);

datadir = '/compyfs/inputdata/ocn/docn7/GTSM/';
yr1 = 2016;
yr2 = 2050;
for i = 1 : length(GCM)
    SSHyr   = NaN(84300,yr2-yr1+1);
    Inundyr = NaN(84300,yr2-yr1+1);
    for iy = 2016 : 2050
        SSHmon   = NaN(84300,12);
        Inundmon = NaN(84300,12);
        for im = 1 : 12
            disp([GCM{i} ', year: ' num2str(iy) ', month: ' num2str(im)]);
            if im < 10
                fname = [datadir 'coastal_inundation.' num2str(iy) '-0' num2str(im) '.nc'];
            else
                fname = [datadir 'coastal_inundation.' num2str(iy) '-'  num2str(im) '.nc'];
            end
            SSHmon(:,im) = nanmean(ncread(fname,'SSH'),3);
            Inundmon(:,im) = nanmean(ncread(fname,'Inund'),3);
        end
        SSHyr(:,iy - yr1 + 1) = nanmean(SSHmon,2);
        Inundyr(:,iy - yr1 + 1) = nanmean(Inundmon,2);
    end
    save(['../data/outputs/' GCM{i} '_sshyr_FUT.mat'],'SSHyr','Inundyr');
end

yr1 = 1951;
yr2 = 2014;
for i = 1 : length(GCM)
    SSHyr   = NaN(84300,yr2-yr1+1);
    Inundyr = NaN(84300,yr2-yr1+1);
    for iy = yr1 : yr2
        SSHmon   = NaN(84300,12);
        Inundmon = NaN(84300,12);
        for im = 1 : 12
            disp([GCM{i} ', year: ' num2str(iy) ', month: ' num2str(im)]);
            if im < 10
                fname = [datadir 'coastal_inundation.' num2str(iy) '-0' num2str(im) '.nc'];
            else
                fname = [datadir 'coastal_inundation.' num2str(iy) '-'  num2str(im) '.nc'];
            end
            SSHmon(:,im) = nanmean(ncread(fname,'SSH'),3);
            Inundmon(:,im) = nanmean(ncread(fname,'Inund'),3);
        end
        SSHyr(:,iy - yr1 + 1) = nanmean(SSHmon,2);
        Inundyr(:,iy - yr1 + 1) = nanmean(Inundmon,2);
    end
    save(['../data/outputs/' GCM{i} '_sshyr_CTL.mat'],'SSHyr','Inundyr');
end