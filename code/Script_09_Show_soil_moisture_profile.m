clear;close all;clc;

load('../data/domain_global_coastline_merit_90m.mat');
files = dir('./test/*.nc');

% for i = 1 : length(files)
%     filename = fullfile(files(i).folder,files(i).name);
%     tmp      = ncread(filename,'SSH');
%     disp(files(i).name);
%     if i == 1
%         numc = size(tmp,1);
%         SSH  = NaN(numc,length(files));
%         QH2OOCN = NaN(numc,length(files));
%     end
%     SSH(:,i) = tmp;
%     tmp = ncread(filename,'QH2OOCN');
%     QH2OOCN(:,i) = tmp;
% end
% tmp_cv   = nanstd(QH2OOCN,[],2);
% tmp_cv(merit_y > 50 | merit_y < -50) = 0;
% ind = find(tmp_cv == max(tmp_cv));
cities = GetCities();

dist = (merit_x - cities(9).X).^2 + (merit_y - cities(9).Y).^2;

[B,I] = sort(dist,'ascend');
ind = I(1);
h2osoi = NaN(365,15);
ssh    = NaN(365,1);
qh2oocn = NaN(365,1);
qinfl = NaN(365,1);
for i = 1 : length(files)
    filename = fullfile(files(i).folder,files(i).name);
    disp(files(i).name);
    tmp      = ncread(filename,'H2OSOI');
    h2osoi(i,:) = nanmean(tmp(ind,:,:),1);
    tmp      = ncread(filename,'SSH');
    ssh(i)   = nanmean(tmp(ind));
    tmp      = ncread(filename,'QH2OOCN');
    qh2oocn(i) = nanmean(tmp(ind));
    tmp      = ncread(filename,'QINFL');
    qinfl(i) = nanmean(tmp(ind));
end

figure;
subplot(2,1,1); 
yyaxis left;
plot(ssh,'b-','LineWidth',2); xlim([1 365])
yyaxis right;
plot(qinfl,'r-','LineWidth',2); hold on; xlim([1 365])
subplot(2,1,2); 
imagesc(h2osoi'); xlim([1 365])