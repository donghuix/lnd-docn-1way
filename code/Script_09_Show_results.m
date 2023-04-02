clear;close all;clc;

addpath('/Users/xudo627/donghui/mylib/m/');
addpath('/Users/xudo627/donghui/CODE/dengwirda-inpoly-355c57c/');

read_data = 1;
res       = 1;

exs1 = {'ctl-ctl','ctl-fut','fut-ctl','fut-fut'};
tag1 = {'ctl_ctl','ctl_fut','fut_ctl','fut_fut'};
exs2 = {'ctl-ctl','ctl-025','ctl-050','ctl-075','ctl-100'};
tag2 = {'ctl_ctl','ctl_025','ctl_050','ctl_075','ctl_100'};

load('../data/domain_global_coastline_merit_90m.mat');

[xv,yv] = xc2xv(merit_x,merit_y,1/8,1/8,false);

zwt = struct([]);
amr = struct([]);
rst = struct([]);

load coastlines.mat;
load('../data/greenland.mat');
gl_mask   = inpoly2([merit_x merit_y],[x y]);
ind_small = merit_frac < 0.05;

load('../fan/fan8th.mat');
fan8th(gl_mask | ind_small) = [];

idx = 6 : 35;

if exist(['../data/processed/ratio_' num2str(res) 'deg.mat'],'file') && 0
    load(['../data/processed/ratio_' num2str(res) 'deg.mat']);
else
    for i = 1 : length(exs1)
        disp(['Read ' exs1{i}]);
        rst(1).(tag1{i}) = load(['../data/outputs/' exs1{i} '_results_annual.mat']);
    end
    
    qinfl0 = nanmean(rst.ctl_ctl.qinfl,2);
    qinfl1 = nanmean(rst.ctl_fut.qinfl,2);
    qinfl2 = nanmean(rst.fut_ctl.qinfl,2);
    qinfl3 = nanmean(rst.fut_fut.qinfl,2);
    
    qver0 = +nanmean(rst.ctl_ctl.qh2oocn(:,idx),2);
    qlat0 = -nanmean(rst.ctl_ctl.qlnd2ocn(:,idx),2);
        
    qver1 = +nanmean(rst.ctl_fut.qh2oocn(:,idx),2);
    qlat1 = -nanmean(rst.ctl_fut.qlnd2ocn(:,idx),2);
        
    qver2 = nanmean(rst.fut_ctl.qh2oocn(:,idx),2);
    qlat2 = -nanmean(rst.fut_ctl.qlnd2ocn(:,idx),2);
        
    qver3 = nanmean(rst.fut_fut.qh2oocn(:,idx),2);
    qlat3 = -nanmean(rst.fut_fut.qlnd2ocn(:,idx),2);
    
    foc1 = (qinfl3 - qinfl0).*86400.*365.25;
    foc2 = (qlat3 - qlat0).*86400.*365.25;
    foc3 = (qver3 - qver0).*86400.*365.25;
    
    foc1(gl_mask | ind_small) = [];
    foc2(gl_mask | ind_small) = [];
    foc3(gl_mask | ind_small) = [];
    merit_x(gl_mask | ind_small) = [];
    merit_y(gl_mask | ind_small) = [];
    merit_frac(gl_mask | ind_small) = [];
    merit_topo(gl_mask | ind_small) = [];
    merit_area(gl_mask | ind_small) = [];
    xv(:,gl_mask | ind_small) = [];
    yv(:,gl_mask | ind_small) = [];
    
    load('../data/map1deg.mat');
    foc1_1deg = mapping_1d_to_2d(foc1,mapping,map_1dto2d,size(lon));
    foc2_1deg = mapping_1d_to_2d(foc2,mapping,map_1dto2d,size(lon));
    foc3_1deg = mapping_1d_to_2d(foc3,mapping,map_1dto2d,size(lon));

end
labels = {'Land inifltration','Lateral flow','Ocean infiltration'};
plot_exs3(lon,lat, foc1_1deg, foc2_1deg, foc3_1deg, -100, 100, labels);

[lon5,lat5,fan5deg] = upscale_data(merit_x,merit_y,merit_frac,-fan8th,5);
figure;imagesc([lon5(1,1) lon5(end,end)],[lat5(1,1) lat5(end,end)],fan5deg); hold on; 
plot(lon5(fan5deg < 3),lat5(fan5deg < 3),'rx','LineWidth',1.5);
set(gca,'YDir','normal');

cities = GetCities();

for i = 1 : length(cities)
    plot(cities(i).X , cities(i).Y,'go','LineWidth',2);
end

for i = 1 : length(exs1)
    disp(['Read ' exs1{i}]);
    zwt(1).(tag1{i}) = load(['../data/outputs/' exs1{i} '_zwt_annual.mat']);
end

zwt0 = nanmean(zwt.ctl_ctl.zwtyr(:,idx),2);
zwt1 = nanmean(zwt.ctl_fut.zwtyr(:,idx),2);
zwt2 = nanmean(zwt.fut_ctl.zwtyr(:,idx),2);
zwt3 = nanmean(zwt.fut_fut.zwtyr(:,idx),2);

focz1 = zwt1 - zwt0;
focz2 = zwt2 - zwt0;
focz3 = zwt3 - zwt0;

focz1(gl_mask | ind_small) = [];
focz2(gl_mask | ind_small) = [];
focz3(gl_mask | ind_small) = [];
    
focz1_1deg = mapping_1d_to_2d(focz1,mapping,map_1dto2d,size(lon));
focz2_1deg = mapping_1d_to_2d(focz2,mapping,map_1dto2d,size(lon));
focz3_1deg = mapping_1d_to_2d(focz3,mapping,map_1dto2d,size(lon));

labels = {'CTL FUT','FUT CTL','FUT FUT'};
plot_exs3(lon,lat, focz1_1deg, focz2_1deg, focz3_1deg, -0.5, 0.5,labels);

zwt0(gl_mask | ind_small) = [];

zwt.ctl_ctl.zwtyr(gl_mask | ind_small,:) = [];
zwt.fut_fut.zwtyr(gl_mask | ind_small,:) = [];
zwt.fut_ctl.zwtyr(gl_mask | ind_small,:) = [];
zwt.ctl_fut.zwtyr(gl_mask | ind_small,:) = [];

levels = [2; 5; 10; 20; 40];
area = merit_frac.*merit_area;

figure(200); set(gcf,'Position',[10 10 1400 800]);
figure(201); set(gcf,'Position',[10 10 1400 800]);
figure(203); set(gcf,'Position',[10 10 1400 800]);
figure(202);
for i = 1 : 6
    
    if i == 1
        ind = find(zwt0 <= levels(i));
    elseif i == 6
        ind = find(zwt0 > levels(i-1));
    else
        ind = find(zwt0 > levels(i-1) & zwt0 <= levels(i));
    end

    zwt_fut_fut = -nansum(zwt.fut_fut.zwtyr(ind,idx).*area(ind),1)./nansum(area(ind));
    zwt_fut_ctl = -nansum(zwt.fut_ctl.zwtyr(ind,idx).*area(ind),1)./nansum(area(ind));
    zwt_ctl_ctl = -nansum(zwt.ctl_ctl.zwtyr(ind,idx).*area(ind),1)./nansum(area(ind));
    zwt_ctl_fut = -nansum(zwt.ctl_fut.zwtyr(ind,idx).*area(ind),1)./nansum(area(ind));
    
    wd = 1;
    zwt_fut_fut = movmean(zwt_fut_fut,wd);
    zwt_fut_ctl = movmean(zwt_fut_ctl,wd);
    zwt_ctl_ctl = movmean(zwt_ctl_ctl,wd);
    zwt_ctl_fut = movmean(zwt_ctl_fut,wd);
    
    fut_fut = -zwt.fut_fut.zwtyr(ind,idx);
    fut_ctl = -zwt.fut_ctl.zwtyr(ind,idx);
    ctl_ctl = -zwt.ctl_ctl.zwtyr(ind,idx);
    ctl_fut = -zwt.ctl_fut.zwtyr(ind,idx);
    
    figure(202);
    subplot(2,3,i);
    d1 = nanmean(fut_fut,2) - nanmean(ctl_ctl,2);
    d2 = nanmean(fut_fut,2) - nanmean(ctl_fut,2);
    d3 = nanmean(fut_fut,2) - nanmean(fut_ctl,2);
    d4 = d2 + d3;
    plot(d1,d2,'ro'); hold on;
    plot([min(d1) max(d1)],[min(d1) max(d1)],'g-','LineWidth',1.5); grid on;
    figure(203);
    subplot(2,3,i);
    plot(d1,d3,'bx'); hold on;
    plot([min(d1) max(d1)],[min(d1) max(d1)],'g-','LineWidth',1.5); grid on;
    figure(204);
    subplot(2,3,i);
    if i == 1
        ind = find(d1 >= -2 & d1 <=2 & d4 >=-2 & d4 <=3);
        d1 = d1(ind);
        d4 = d4(ind);
    elseif i == 2
        ind = find(d1 >= -2 & d1 <=3 & d4 >=-6 & d4 <=10);
        d1 = d1(ind);
        d4 = d4(ind);
    elseif i == 3
        ind = find(d1 >= -4 & d1 <=7 & d4 >=-6 & d4 <=15);
        d1 = d1(ind);
        d4 = d4(ind);
    elseif i == 4
        ind = find(d1 >= -5 & d1 <=7 & d4 >=-4 & d4 <=5);
        d1 = d1(ind);
        d4 = d4(ind);
    elseif i == 6
        ind = find(d1 >= -5 & d1 <=7 & d4 >=-10 & d4 <=8);
        d1 = d1(ind);
        d4 = d4(ind);
    end
    
    plot(d1 - d4,'k.'); 
    %plot(d1,d4,'kd'); hold on;
    %plot([min(d1) max(d1)],[min(d1) max(d1)],'g-','LineWidth',1.5); grid on;
    %[~,~,R2] = LSE(d1,d4);
    title(['average difference = ' num2str(nanmean(d1-d4))]);
    
    [z1, trend1, ~, p1] = mk_test(zwt_ctl_ctl');
    [z2, trend2, ~, p2] = mk_test(zwt_ctl_fut');
    [z3, trend3, ~, p3] = mk_test(zwt_fut_ctl');
    [z4, trend4, ~, p4] = mk_test(zwt_fut_fut'); 
    [slope1, intercept1] = sens_slope(zwt_ctl_ctl');
    [slope2, intercept1] = sens_slope(zwt_ctl_fut');
    [slope3, intercept1] = sens_slope(zwt_fut_ctl');
    [slope4, intercept1] = sens_slope(zwt_fut_fut');
    
    figure(201);
    subplot_tight(2,3,i,[0.06 0.04]);
    yyaxis left;
%     h(1) = plot(1985:2014,zwt_ctl_ctl,'k-', 'LineWidth',2); 
%     h(2) = plot(1985:2014,zwt_ctl_fut,'g:', 'LineWidth',2);
    h(1) = plot(2021:2050,zwt_fut_ctl,'b--','LineWidth',2);hold on; grid on;
    h(2) = plot(2021:2050,zwt_fut_fut,'r-','LineWidth',2); 
    ylim([-1.5 -1]); ylabel('ZWT [m]','FontSize',14,'FontWeight','bold');

    yyaxis right;
%     tmp1 = zwt_ctl_fut-zwt_ctl_ctl;
%     plot(1985:2014,tmp1,'k:','LineWidth',2); 
%     [theta1,theta2] = LSE(1:15,tmp1(1:15));
%     plot([1985 1999],theta1 + theta2.*[1 15],'m-','LineWidth',1.5);
%     [theta1,theta2] = LSE(1:16,tmp1(15:30));
%     plot([1999 2014],theta1 + theta2.*[1 16],'c-','LineWidth',1.5);
    tmp1 = zwt_fut_fut-zwt_fut_ctl;
    plot(2021:2050,tmp1,'k:','LineWidth',2);
    [theta1,theta2] = LSE(1:15,tmp1(1:15));
    plot([2021 2035],theta1 + theta2.*[1 15],'m-','LineWidth',1.5);
    [theta1,theta2] = LSE(1:16,tmp1(15:30));
    plot([2035 2050],theta1 + theta2.*[1 16],'c-','LineWidth',1.5);
    ylim([0.02 0.2]);ylabel('[m]','FontSize',14,'FontWeight','bold');

    leg = legend(h,{'Ex1', 'Ex2'});
    leg.FontSize = 14; leg.FontWeight = 'bold';
    %set(gca,'FontSize',13);
    %set(gcf,'Position',[10 10 1000 600]);
    if i == 3
%         leg = legend(h,{'Historical-Historical','Historical-Future','Future-Historical', ...
%                         'Future-Future'},'FontSize',14,'FontWeight','bold');
%         leg = legend('Historical_Historical', 'Future_Historical', 'Future_Future','Future_Future - Future_Historical',...
%                      'FontSize',14,'FontWeight','bold','Interpreter','none');
        leg.Location = 'southwest';
    end
    if i == 1
        tt = ['ZWT < ' num2str(levels(i)) ' [m]'];
    elseif i == 6
        tt = ['ZWT > ' num2str(levels(i-1)) ' [m]'];
    else
        tt = [num2str(levels(i-1)) '<= ZWT < ' num2str(levels(i)) ' [m]'];
    end
    add_title(gca,tt);
    pos = get(gca,'Position');

    slope1 = round(slope1*1000,2); p1 = round(p1,3);
    slope2 = round(slope2*1000,2); p2 = round(p2,3);
    slope3 = round(slope3*1000,2); p3 = round(p3,3);
    slope4 = round(slope4*1000,2); p4 = round(p4,3);
    
    dim1 = [pos(1) pos(2)+pos(4)-0.1 0.1 0.1];
    str1 = ['Sen slope = ' num2str(slope1) ' [mm/year], p-value = ', num2str(p1)];
    t1 = annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','none');
    t1.FontSize = 14; t1.FontWeight = 'bold'; t1.Color = 'k';
    
    dim3 = [pos(1) pos(2)+pos(4)-0.125 0.1 0.1];
    str3 = ['Sen slope = ' num2str(slope3) ' [mm/year], p-value = ', num2str(p3)];
    t3 = annotation('textbox',dim3,'String',str3,'FitBoxToText','on','EdgeColor','none');
    t3.FontSize = 14; t3.FontWeight = 'bold'; t3.Color = 'b';
    
    dim4 = [pos(1) pos(2)+pos(4)-0.150 0.1 0.1];
    str4 = ['Sen slope = ' num2str(slope4) ' [mm/year], p-value = ', num2str(p4)];
    t4 = annotation('textbox',dim4,'String',str4,'FitBoxToText','on','EdgeColor','none');
    t4.FontSize = 14; t4.FontWeight = 'bold'; t4.Color = 'r';
    
    figure(200);
    subplot_tight(2,3,i,[0.06 0.04]);hold on; grid on;
    plot(1985:2014,zwt_ctl_ctl,'k-','LineWidth',2);
    plot(2021:2050,zwt_fut_ctl,'b--','LineWidth',2); 
    add_title(gca,tt);
    pos = get(gca,'Position');
    
    if i == 3
%         leg = legend('Historical-Historical','Historical-Future','Future-Historical', ...
%                      'Future-Future','FontSize',14,'FontWeight','bold');
        leg = legend('Historical_Historical', 'Future_Historical',...
                     'FontSize',14,'FontWeight','bold','Interpreter','none');
        leg.Location = 'southwest';
    end
    
    dim1 = [pos(1) pos(2)+pos(4)-0.1 0.1 0.1];
    str1 = ['Sen slope = ' num2str(slope1) ' [mm/year], p-value = ', num2str(p1)];
    t1 = annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','none');
    t1.FontSize = 14; t1.FontWeight = 'bold'; t1.Color = 'k';

    dim2 = [pos(1) pos(2)+pos(4)-0.125 0.1 0.1];
    str2 = ['Sen slope = ' num2str(slope3) ' [mm/year], p-value = ', num2str(p3)];
    t2 = annotation('textbox',dim2,'String',str2,'FitBoxToText','on','EdgeColor','none');
    t2.FontSize = 14; t2.FontWeight = 'bold'; t2.Color = 'b';
end

dx = 5; dy = 5;

figure(101); set(gcf,'Position',[10 10 1200 1000]);
figure(102); set(gcf,'Position',[10 10 1200 1000]);
figure(103); set(gcf,'Position',[10 10 1200 1000]);
load('../data/outputs/GFDL-CM4C192-SST_sshyr.mat');
SSHyr(gl_mask | ind_small,:) = [];

for i = 1 : length(cities)
    figure(101);
    subplot(4,5,i);
    x  = cities(i).X; y = cities(i).Y;
    xb = [x - dx/2; x + dx/2; x + dx/2; x - dx/2; x - dx/2];
    yb = [y - dy/2; y - dy/2; y + dy/2; y + dy/2; y - dy/2];
    ind = inpoly2([merit_x merit_y],[xb yb]);
    
    tmp0 = zwt.ctl_ctl.zwtyr(ind,idx).*1000; 
    tmp1 = zwt.fut_fut.zwtyr(ind,idx).*1000;% [mm]
    tmp2 = zwt.fut_ctl.zwtyr(ind,idx).*1000;% [mm]
    tmp3 = zwt.ctl_fut.zwtyr(ind,idx).*1000;% [mm] 
%     tmp0 = nanmean(tmp0,2);
%     tmp3 = nanmean(tmp3,2);
    
    zwt_ctl_ctl = -nansum(tmp0.*area(ind),1)./nansum(area(ind));
    zwt_fut_fut = -nansum(tmp1.*area(ind),1)./nansum(area(ind));
    zwt_fut_ctl = -nansum(tmp2.*area(ind),1)./nansum(area(ind));
    zwt_ctl_fut = -nansum(tmp3.*area(ind),1)./nansum(area(ind));
    
    [z1, trend1, ~, p1] = mk_test(zwt_fut_fut');
    [z2, trend2, ~, p2] = mk_test(zwt_fut_ctl');
    [slope1, intercept1] = sens_slope(zwt_fut_fut');
    [slope2, intercept1] = sens_slope(zwt_fut_ctl');
    
    ssh = nanmean(SSHyr(ind,:),1).*1000;
    
    plot(2021:2050,zwt_ctl_fut-nanmean(zwt_ctl_ctl),'r-','LineWidth',1); hold on; grid on;
    plot(2021:2050,zwt_fut_ctl-nanmean(zwt_ctl_ctl),'b-','LineWidth',1);
    plot(2021:2050,zwt_fut_fut-nanmean(zwt_ctl_ctl),'k-','LineWidth',1);
    %plot(2016:2050,ssh,'k-','LineWidth',2);
    %plot(2016:2050,zwt_fut_ctl-nanmean(zwt_ctl_ctl),'b-','LineWidth',1);
    %plot(2016:2050,zwt_fut_fut-nanmean(zwt_ctl_ctl),'k-','LineWidth',1);
    %plot(2016:2050,zwt_fut_fut-zwt_fut_ctl + (zwt_fut_fut-zwt_ctl_fut),'k--','LineWidth',2);
    title(cities(i).Name);
    
    num1 = nanmean(zwt_ctl_fut)-nanmean(zwt_ctl_ctl);
    num2 = nanmean(zwt_fut_ctl)-nanmean(zwt_ctl_ctl);
    num3 = nanmean(zwt_fut_fut)-nanmean(zwt_ctl_ctl);
    num1 = round(num1,1); num2 = round(num2,1); num3 = round(num3,1);
    
    pos = get(gca,'Position');
    dim1 = [pos(1) pos(2)+pos(4)-0.05 0.05 0.05];
    str1 = [num2str(num1) ' [mm]'];
    t1 = annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','none');
    t1.FontSize = 10; t1.FontWeight = 'bold'; t1.Color = 'r';
    
    dim1 = [pos(1) pos(2)+pos(4)-0.065 0.05 0.05];
    str1 = [num2str(num2) ' [mm]'];
    t1 = annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','none');
    t1.FontSize = 10; t1.FontWeight = 'bold'; t1.Color = 'b';
    
    dim1 = [pos(1) pos(2)+pos(4)-0.080 0.05 0.05];
    str1 = [num2str(num3) ' [mm]'];
    t1 = annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','none');
    t1.FontSize = 10; t1.FontWeight = 'bold'; t1.Color = 'k';
    
    figure(103);
    subplot(4,5,i);
    plot(2021:2050,zwt_fut_fut,'r-','LineWidth',1); hold on; grid on;
    plot(2021:2050,zwt_fut_ctl,'b--','LineWidth',1);
    title(cities(i).Name);
    
    figure(100);
    if i == 1
        plot(coastlon,coastlat,'k-','LineWidth',1.5); hold on;
    end
    plot(cities(i).X , cities(i).Y,'gd','LineWidth',2);
    plot(xb,yb,'r-','LineWidth',1);
    text(cities(i).X-2, cities(i).Y+3,cities(i).Name,'Color','b');
    xlim([-100 150]);
    ylim([-20 60]);

    figure(102);
    subplot(4,5,i);
    patch(xv(:,ind),yv(:,ind),nanmean(tmp1,2) - nanmean(tmp2,2),'LineStyle','none'); hold on;
    caxis([-250 250]); colormap(gca,blue2red(121));
    plot(cities(i).X , cities(i).Y,'kd','LineWidth',2); 
    %plot(coastlon,coastlat,'r-','LineWidth',1);
    %plot(merit_x(ind), merit_y(ind),'g.');
    xlim([min(xb) max(xb)]); 
    ylim([min(yb) max(yb)]); 
    title(cities(i).Name);
    %legend('Fut atm + Fut SSH','Fut atm + CTL SSH','FontSize',14,'FontWeight','bold')
    %add_title(gca,'Global coastline ZWT [m]');
%     pos = get(gca,'Position');
% 
%     slope1 = round(slope1*1000,3); p1 = round(p1,3);
%     slope2 = round(slope2*1000,3); p2 = round(p2,3);
%     dim1 = [pos(1) pos(2)+pos(4)-0.1 0.1 0.1];
%     str1 = ['Sen slope = ' num2str(slope1) ' [mm/year], p-value = ', num2str(p1)];
%     t1 = annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','none');
%     t1.FontSize = 14; t1.FontWeight = 'bold'; t1.Color = 'r';
% 
%     dim2 = [pos(1) pos(2)+pos(4)-0.15 0.1 0.1];
%     str2 = ['Sen slope = ' num2str(slope2) ' [mm/year], p-value = ', num2str(p2)];
%     t2 = annotation('textbox',dim2,'String',str2,'FitBoxToText','on','EdgeColor','none');
%     t2.FontSize = 14; t2.FontWeight = 'bold'; t2.Color = 'b';
    
end

for i = 1 : length(exs1)
    disp(['Read ' exs1{i}]);
    amr(1).(tag1{i}) = load(['../data/outputs/' exs1{i} '_AMR.mat']);
end

foc_amtr1 = prctile(amr.ctl_fut.AMTR,99,2) ./ prctile(amr.ctl_ctl.AMTR,99,2);
foc_amtr2 = prctile(amr.fut_ctl.AMTR,99,2) ./ prctile(amr.ctl_ctl.AMTR,99,2);
foc_amtr3 = prctile(amr.fut_fut.AMTR,99,2) ./ prctile(amr.ctl_ctl.AMTR,99,2);

foc_amtr1(gl_mask | ind_small) = [];
foc_amtr2(gl_mask | ind_small) = [];
foc_amtr3(gl_mask | ind_small) = [];

foc_amtr1_1deg = mapping_1d_to_2d(foc_amtr1,mapping,map_1dto2d,size(lon));
foc_amtr2_1deg = mapping_1d_to_2d(foc_amtr2,mapping,map_1dto2d,size(lon));
foc_amtr3_1deg = mapping_1d_to_2d(foc_amtr3,mapping,map_1dto2d,size(lon));

plot_exs3(lon,lat,foc_amtr1_1deg, foc_amtr2_1deg, foc_amtr3_1deg, 0.5, 1.5, labels);

for i = 1 : length(exs1)
    disp(['Read ' exs1{i}]);
    rst(1).(tag1{i}) = load(['../data/outputs/' exs1{i} '_results_annual.mat']);
end
rst.ctl_ctl.qrunoff(gl_mask | ind_small,:) = [];
rst.fut_fut.qrunoff(gl_mask | ind_small,:) = [];
rst.fut_ctl.qrunoff(gl_mask | ind_small,:) = [];
rst.ctl_fut.qrunoff(gl_mask | ind_small,:) = [];

focq1 = nanmean(rst.ctl_fut.qrunoff(:,idx),2) ./ nanmean(rst.ctl_ctl.qrunoff(:,idx),2);
focq2 = nanmean(rst.fut_ctl.qrunoff(:,idx),2) ./ nanmean(rst.ctl_ctl.qrunoff(:,idx),2);
focq3 = nanmean(rst.fut_fut.qrunoff(:,idx),2) ./ nanmean(rst.ctl_ctl.qrunoff(:,idx),2);

focq1_1deg = mapping_1d_to_2d(focq1,mapping,map_1dto2d,size(lon));
focq2_1deg = mapping_1d_to_2d(focq2,mapping,map_1dto2d,size(lon));
focq3_1deg = mapping_1d_to_2d(focq3,mapping,map_1dto2d,size(lon));

plot_exs3(lon,lat,focq1_1deg, focq2_1deg, focq3_1deg, 0.5, 1.5, labels);

figure(302); set(gcf,'Position',[10 10 1200 1000]);
figure(303); set(gcf,'Position',[10 10 1200 1000]);
for i = 1 : length(cities)
    x  = cities(i).X; y = cities(i).Y;
    xb = [x - dx/2; x + dx/2; x + dx/2; x - dx/2; x - dx/2];
    yb = [y - dy/2; y - dy/2; y + dy/2; y + dy/2; y - dy/2];
    ind = inpoly2([merit_x merit_y],[xb yb]);
    
    tmp0 = rst.ctl_ctl.qrunoff(ind,idx).*86400;
    tmp1 = rst.fut_fut.qrunoff(ind,idx).*86400;
    tmp2 = rst.fut_ctl.qrunoff(ind,idx).*86400;
    tmp3 = rst.ctl_fut.qrunoff(ind,idx).*86400;
    
    qt_ctl_ctl = nansum(tmp0.*area(ind),1)./nansum(area(ind));
    qt_fut_fut = nansum(tmp1.*area(ind),1)./nansum(area(ind));
    qt_fut_ctl = nansum(tmp2.*area(ind),1)./nansum(area(ind));
    qt_ctl_fut = nansum(tmp3.*area(ind),1)./nansum(area(ind));
    
    figure(301);
    subplot(4,5,i);
    patch(xv(:,ind),yv(:,ind),nanmean(tmp3,2) ./ nanmean(tmp0,2),'LineStyle','none'); hold on;
    caxis([0.5 1.5]); colormap(gca,blue2red(121));
    plot(cities(i).X , cities(i).Y,'kd','LineWidth',2); 
    xlim([min(xb) max(xb)]); 
    ylim([min(yb) max(yb)]); 
    title(cities(i).Name);
    
    tmp0 = rst.ctl_ctl.qover(ind,idx).*86400;
    tmp1 = rst.fut_fut.qover(ind,idx).*86400;
    tmp2 = rst.fut_ctl.qover(ind,idx).*86400;
    tmp3 = rst.ctl_fut.qover(ind,idx).*86400;
    
    qo_ctl_ctl = nansum(tmp0.*area(ind),1)./nansum(area(ind));
    qo_fut_fut = nansum(tmp1.*area(ind),1)./nansum(area(ind));
    qo_fut_ctl = nansum(tmp2.*area(ind),1)./nansum(area(ind));
    qo_ctl_fut = nansum(tmp3.*area(ind),1)./nansum(area(ind));
    
    figure(302);
    subplot(4,5,i);
    plot(2021:2050,(qt_fut_fut-qt_fut_ctl)./nanmean(qt_ctl_ctl).*100,'r-','LineWidth',1); hold on;
    %plot(2016:2050,(qo_fut_fut-qo_fut_ctl)./nanmean(qo_ctl_ctl).*100,'b-','LineWidth',2);
    plot(2021:2050,(qt_fut_ctl-nanmean(qt_ctl_ctl))./nanmean(qt_ctl_ctl).*100,'b-','LineWidth',1);
    plot(2021:2050,(qt_fut_fut-nanmean(qt_ctl_ctl))./nanmean(qt_ctl_ctl).*100,'k-','LineWidth',1);
    title(cities(i).Name);
    
    num1 = (nanmean(qt_ctl_fut)-nanmean(qt_ctl_ctl))./nanmean(qt_ctl_ctl).*100;
    num2 = (nanmean(qt_fut_ctl)-nanmean(qt_ctl_ctl))./nanmean(qt_ctl_ctl).*100;
    num3 = (nanmean(qt_fut_fut)-nanmean(qt_ctl_ctl))./nanmean(qt_ctl_ctl).*100;
    num1 = round(num1,1); num2 = round(num2,1); num3 = round(num3,1);
    
    pos = get(gca,'Position');
    dim1 = [pos(1) pos(2)+pos(4)-0.05 0.05 0.05];
    str1 = [num2str(num1) ' [%]'];
    t1 = annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','none');
    t1.FontSize = 10; t1.FontWeight = 'bold'; t1.Color = 'r';
    
    dim1 = [pos(1) pos(2)+pos(4)-0.065 0.05 0.05];
    str1 = [num2str(num2) ' [%]'];
    t1 = annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','none');
    t1.FontSize = 10; t1.FontWeight = 'bold'; t1.Color = 'b';
    
    dim1 = [pos(1) pos(2)+pos(4)-0.080 0.05 0.05];
    str1 = [num2str(num3) ' [%]'];
    t1 = annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','none');
    t1.FontSize = 10; t1.FontWeight = 'bold'; t1.Color = 'k';
    
    % Ground water contamination
    tmp0 = rst.ctl_ctl.qh2oocn(ind,idx)./(rst.ctl_ctl.qinfl(ind,idx) + rst.ctl_ctl.qh2oocn(ind,idx));
    tmp1 = rst.fut_fut.qh2oocn(ind,idx)./(rst.fut_fut.qinfl(ind,idx) + rst.fut_fut.qh2oocn(ind,idx)); 
    tmp2 = rst.fut_ctl.qh2oocn(ind,idx)./(rst.fut_ctl.qinfl(ind,idx) + rst.fut_ctl.qh2oocn(ind,idx)); 
    tmp3 = rst.ctl_fut.qh2oocn(ind,idx)./(rst.ctl_fut.qinfl(ind,idx) + rst.ctl_fut.qh2oocn(ind,idx));
    
    swr_ctl_ctl = nansum(tmp0.*area(ind),1)./nansum(area(ind));
    swr_fut_fut = nansum(tmp1.*area(ind),1)./nansum(area(ind));
    swr_fut_ctl = nansum(tmp2.*area(ind),1)./nansum(area(ind));
    swr_ctl_fut = nansum(tmp3.*area(ind),1)./nansum(area(ind));
    figure(303);
    subplot(4,5,i);
    plot(2021:2050,swr_fut_fut-nanmean(swr_fut_ctl),'r-','LineWidth',1); hold on;
    plot(2021:2050,swr_fut_fut-nanmean(swr_ctl_ctl),'b-','LineWidth',1);
    plot(1985:2014,swr_ctl_ctl,'k-','LineWidth',1);
    %plot(2016:2050,(qo_fut_fut-qo_fut_ctl)./nanmean(qo_ctl_ctl).*100,'b-','LineWidth',2);
    %plot(2016:2050,swr_fut_fut,'b-','LineWidth',1);
    %plot(2016:2050,swr_fut_ctl,'k-','LineWidth',1);
    title(cities(i).Name);
end
% tmp0 = rst.ctl_ctl.qh2oocn(ind,1:35)./(rst.ctl_ctl.qinfl(ind,1:35) + rst.ctl_ctl.qh2oocn(ind,1:35));
% tmp1 = rst.fut_fut.qh2oocn(ind,1:35)./(rst.fut_fut.qinfl(ind,1:35) + rst.fut_fut.qh2oocn(ind,1:35)); 
% tmp2 = rst.fut_ctl.qh2oocn(ind,:)./(rst.fut_ctl.qinfl(ind,:) + rst.fut_ctl.qh2oocn(ind,:)); 
% tmp3 = rst.ctl_fut.qh2oocn(ind,:)./(rst.ctl_fut.qinfl(ind,:) + rst.ctl_fut.qh2oocn(ind,:));
    
% tmp0 = nanmean(rst.ctl_ctl.qh2oocn(:,1:35),2)./ ...
%       (nanmean(rst.ctl_ctl.qinfl(:,1:35),2) + nanmean(rst.ctl_ctl.qh2oocn(:,1:35),2));
% tmp1 = nanmean(rst.fut_fut.qh2oocn(:,1:35),2)./ ...
%       (nanmean(rst.fut_fut.qinfl(:,1:35),2) + nanmean(rst.fut_fut.qh2oocn(:,1:35),2)); 
% tmp2 = nanmean(rst.fut_ctl.qh2oocn(:,:),2) ./ ...
%       (nanmean(rst.fut_ctl.qinfl(:,:),2) + nanmean(rst.fut_ctl.qh2oocn(:,:),2)); 
% tmp3 = nanmean(rst.ctl_fut.qh2oocn(:,:),2) ./ ... 
%       (nanmean(rst.ctl_fut.qinfl(:,:),2) + nanmean(rst.ctl_fut.qh2oocn(:,:),2));
%   
% qinflctl   = nanmean(rst.ctl_ctl.qinfl(:,1:35),2);
% qh2oocnctl = nanmean(rst.ctl_ctl.qh2oocn(:,1:35),2);
% qinflctl(qinflctl < 50./365./86400) = NaN;qh2oocnctl(qinflctl < 50./365./86400) = NaN;
% 
% qinflfut   = nanmean(rst.fut_fut.qinfl(:,1:35),2); 
% qh2oocnfut = nanmean(rst.fut_fut.qh2oocn(:,1:35),2);
% qinflfut(qinflfut < 50./365./86400) = NaN; qh2oocnfut(qinflfut < 50./365./86400) = NaN;
% 
% qinflctl(gl_mask | ind_small) = [];
% qh2oocnctl(gl_mask | ind_small) = [];
% qinflfut(gl_mask | ind_small) = [];
% qh2oocnfut(gl_mask | ind_small) = [];
% % tmp0(tmp0<0) = 0; tmp0(tmp0 > 1) = NaN;
% % tmp1(tmp1<0) = 0; tmp1(tmp1 > 1) = NaN;
% % tmp0(gl_mask | ind_small) = [];
% % tmp1(gl_mask | ind_small) = [];
% 
% figure;
% 
% qinflctl_1deg = mapping_1d_to_2d(qinflctl,mapping,map_1dto2d,size(lon)).*86400.*365.25;
% qinflfut_1deg = mapping_1d_to_2d(qinflfut,mapping,map_1dto2d,size(lon)).*86400.*365.25;
% qh2oocnctl_1deg = mapping_1d_to_2d(qh2oocnctl,mapping,map_1dto2d,size(lon)).*86400.*365.25;
% qh2oocnfut_1deg = mapping_1d_to_2d(qh2oocnfut,mapping,map_1dto2d,size(lon)).*86400.*365.25;
% 
% swrctl_1deg = qh2oocnctl_1deg ./ (qh2oocnctl_1deg + qinflctl_1deg);
% swrfut_1deg = qh2oocnfut_1deg ./ (qh2oocnfut_1deg + qinflfut_1deg);
% focswr_1deg = (qh2oocnfut_1deg-qh2oocnctl_1deg) ./ (qh2oocnfut_1deg + qinflfut_1deg);
% 
% % swrctl_1deg = mapping_1d_to_2d(tmp0,mapping,map_1dto2d,size(lon));
% % swrfut_1deg = mapping_1d_to_2d(tmp1,mapping,map_1dto2d,size(lon));
% % focswr_1deg = mapping_1d_to_2d(tmp1-tmp0,mapping,map_1dto2d,size(lon));
% 
% plot_exs3(lon,lat, swrctl_1deg, swrfut_1deg, focswr_1deg, -0.2, 0.2, {'CTL','FUT','FOC'});
% 
% plot_exs3(lon,lat, qinflctl_1deg, qinflfut_1deg, qh2oocnctl_1deg, 0, 100, {'CTL','FUT','FOC'});
% colormap(gca,'jet');