clear;close all;clc;

load('Figure5_data.mat'); % Processed from ../code/Plot_01.m
addpath('../code/');

[axs, cbs] = plot_exs2(lon,lat,-foc_zwt_SLR1deg,foc_qver_SLR1deg,[-0.2 -0.2],[0.2 0.2],{'(a) \Delta GWT_{SLR}',' '});
cbs(1).Label.String = '[m]';
cbs(1).Label.FontWeight = 'bold';
cbs(1).FontSize = 15;
tmp = GetWorldSubRegions(catogrory,axs(1)); clear tmp;
pos = get(axs(1),'Position'); 
for i = 1 : length(SubR)
    minsz = 40;  minv = 0.01;
    maxsz = 400; maxv = 0.1;
    if -SubR(i).foc_zwt_SLR1d > maxv
        sz = maxsz;
    elseif -SubR(i).foc_zwt_SLR1d < minv
        sz = minsz;
    else
        sz = (maxsz - minsz)/(maxv - minv).^2*(-SubR(i).foc_zwt_SLR1d).^2;
    end
    scatter(axs(1),mean(SubR(i).X(1:4)),mean(SubR(i).Y(1:4)),sz,'o','LineWidth',2.5, ...
            'MarkerEdgeColor',[0, 255, 127]./255);
end

% Add legend
vs = [0.02; 0.04; 0.06; 0.08; 0.1];
xbot = 60;
ybot = -55;
for i = 1 : length(vs)
    sz = (maxsz - minsz)/(maxv - minv).^2*(vs(i)).^2;
    scatter(axs(1),xbot,ybot+(i-1)*10,sz,'o','LineWidth',2.5, ...
            'MarkerEdgeColor',[0, 255, 127]./255);
    text(axs(1),xbot+10,ybot+(i-1)*10,[num2str(vs(i)) ' [m]'],'FontSize',13,'FontWeight','bold')
end

delete(axs(2));
pos = get(axs(1),'Position');

w0 = (pos(3)-0.15)/4;
d0 = 0.20;

k = 1;
for i = [6 9 14 8]
    in = inpolygon(merit_x,merit_y,SubR(i).X,SubR(i).Y);
    a  = merit_frac(in).*merit_area(in);

    d1 = -nanmedian(zwtyr.fut_fut.zwtyr(in,idx) - zwtyr.fut_ctl.zwtyr(in,idx));
    d2 = -nanmedian(zwtyr.ctl_fut.zwtyr(in,idx) - zwtyr.ctl_ctl.zwtyr(in,idx));
    
    axes('Position',[pos(1)+(k-1)*(w0+0.05) pos(2)-0.25 w0 d0]);
    h(1) = plot(2021:2050,d1,'x','Color',[0,153,143]./255,'LineWidth',1); hold on; grid on;
    [theta1,theta2]=LSE(2021:2035,d1(1 :15));
    plot([2021 2035],theta1 + theta2.*[2021 2035],'k-','LineWidth',1);
    [theta1,theta2]=LSE(2036:2050,d1(16:30));
    plot([2035 2050],theta1 + theta2.*[2035 2050],'k-','LineWidth',1);
    h(2) = plot(1985:2014,d2,'x','Color',[240,163,255]./255,'LineWidth',1); 
    [theta1,theta2]=LSE(1985:1999,d2(1 :15));
    plot([1985 1999],theta1 + theta2.*[1985 1999],'k-','LineWidth',1);
    [theta1,theta2]=LSE(2000:2014,d2(16:30));
    plot([1999 2014],theta1 + theta2.*[1999 2014],'k-','LineWidth',1);

    xlim([1985 2050]); %ylim([min([d1 d2]) max([d1 d2])]);
    ylim([0 0.15]);
    set(gca,'FontSize',15);
    add_title(gca,[labels2{k} SubR(i).Name],16,'out');
    if k == 1
        ylabel('\Delta GWT_{SLR}','FontSize',15,'FontWeight','bold');
    end
    k = k + 1;
end

exportgraphics(gcf,'Figure5.jpg','Resolution',400);
