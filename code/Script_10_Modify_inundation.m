clear;close all;clc;

GCM = 'GFDL-CM4C192-SST';

load(['../data/outputs/' GCM '_sshyr_CTL.mat'],'Inundyr');

Inund0 = nanmean(Inundyr,2);
Inund0(Inund0 < 0) = 0;

datadir = '/compyfs/inputdata/ocn/docn7/GTSM/';
yr1 = 2016;
yr2 = 2050;
for iy = yr1 : yr2
    for im = 1 : 12
        disp([GCM ', year: ' num2str(iy) ', month: ' num2str(im)]);
        if im < 10
            fname = [datadir 'coastal_inundation.' num2str(iy) '-0' num2str(im) '.nc'];
        else
            fname = [datadir 'coastal_inundation.' num2str(iy) '-'  num2str(im) '.nc'];
        end
        Inund = ncread(fname,'Inund');
        [nlon,nlat,nmon]  = size(Inund);
        assert(nlat == 1);
        Inund = Inund - repmat(Inund0,1,1,nmon);
        Inund(Inund < 0) = 0;
        ncwrite(fname,'Inund',Inund);
    end
end

yr1 = 1951;
yr2 = 2014;
for iy = yr1 : yr2
    for im = 1 : 12
        disp([GCM ', year: ' num2str(iy) ', month: ' num2str(im)]);
        if im < 10
            fname = [datadir 'coastal_inundation.' num2str(iy) '-0' num2str(im) '.nc'];
        else
            fname = [datadir 'coastal_inundation.' num2str(iy) '-'  num2str(im) '.nc'];
        end
        Inund = ncread(fname,'Inund');
        [nlon,nlat,nmon]  =  size(Inund);
        assert(nlat == 1);
        Inund = Inund - repmat(Inund0,1,1,nmon);
        Inund(Inund < 0) = 0;
        ncwrite(fname,'Inund',Inund);
    end
end
