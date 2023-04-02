function axs = plot_exs2(lon,lat,a,b,cmin,cmax,labels)
    addpath('/Users/xudo627/donghui/mylib/m/');

    cmap = flipud(getPyPlot_cMap('coolwarm')); %blue2red(121);
    figure; set(gcf,'Position',[10 10 1000 1200]);
    axs(1) = subplot_tight(2,1,1,[0.06 0.06]);
    imAlpha = ones(size(a));
    imAlpha(isnan(a)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],a,'AlphaData',imAlpha); 
    colormap(cmap); colorbar; hold on; clim([cmin(1) cmax(1)]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    add_title(gca,['(a) ' labels{1}]);
    set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[]);

    axs(2) = subplot_tight(2,1,2,[0.06 0.06]);
    imAlpha = ones(size(b));
    imAlpha(isnan(b)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],b,'AlphaData',imAlpha); 
    colormap(cmap); colorbar; hold on; clim([cmin(2) cmax(2)]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    add_title(gca,['(b) ' labels{2}]);
    set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[]);
end