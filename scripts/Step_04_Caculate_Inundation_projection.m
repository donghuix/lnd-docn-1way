clear;close all;clc;

load('domain.mat');
load('ICOM_bathtub_ele.mat');

icom = [ [-81; -70; -70; -81; -81] [36; 36; 45; 45; 36] ];

freq = 'daily';

GCM = {'CMCC-CM2-VHR4','EC-Earth3P-HR','GFDL-CM4C192-SST','HadGEM3-GC31-HM-SST','HadGEM3-GC31-HM'};

SLR = 0 : 0.1 : 10;

for i = 5 : length(GCM)
    inund_daily = NaN(length(xc),365*(2050-2016+1));
    id0 = 1;
    for iy = 2016 : 2050
        for im = 1 : 12
            if im < 10
            filename = ['data/FUT/' GCM{i} '_future_waterlevel_' num2str(iy) '_0' num2str(im) '_v1.nc'];
            else
            filename = ['data/FUT/' GCM{i} '_future_waterlevel_' num2str(iy) '_'  num2str(im) '_v1.nc'];
            end
            if i == 5 && iy == 2016 && im == 1
               station_x = ncread(filename,'station_x_coordinate');
               station_y = ncread(filename,'station_y_coordinate');
               idx = NaN(length(xc),1);
               for k = 1 : length(xc)
                   dist = (station_x - xc(k)).^2 + (station_y - yc(k)).^2;
                   itmp = find(dist == min(dist));
                   idx(k) = itmp(1);
               end
           end
           wl = ncread(filename,'waterlevel');
           wl = wl(idx,:);
           
               
           for ii = 1 : length(xc)
               ele_prof = bathtub_ele(ii,:);
               ele_prof = ele_prof(:);
               id = id0;
               if ~any(isnan(ele_prof)) && ~all(ele_prof == 0)
               for jj = 1 : size(wl,2)/144
                   disp(['i = ' num2str(i) ', ii = ' num2str(ii) ', id = ' num2str(id)]);
                   if strcmp(freq, 'daily')
                       wl_grid = nanmean(wl(ii,(jj-1)*144+1:jj*144));
                       inund_daily(ii,id) = interp1(SLR,ele_prof,wl_grid);
                   end
%                    tmp = NaN(144,1);
%                    for kk = 1 : 144
%                        if wl(ii,(jj-1)*144+kk) <= 0
%                            tmp(kk) = 0;
%                        else
%                            tmp(kk) = interp1(SLR,ele_prof,wl(ii,(jj-1)*144 + kk));
%                        end
%                    end
%                    inund_daily(ii,id,i) = nanmean(tmp);
                   id = id + 1;
               end
               end
               if ii == length(xc)
                   id0 = id;
               end
           end
           
        end
    end
    save(['Inund_daily_' GCM{i} '.mat'],'inund_daily');
end
