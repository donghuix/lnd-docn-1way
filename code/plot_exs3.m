function axs = plot_exs3(lon,lat,a,b,c,cmin,cmax,labels)
    figure; set(gcf,'Position',[10 10 800 1200]);
    axs(1) = subplot(3,1,1);
    imAlpha = ones(size(a));
    imAlpha(isnan(a)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],a,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; clim([cmin(1) cmax(1)]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    add_title(gca,labels{1});
    
    axs(2) = subplot(3,1,2);
    imAlpha = ones(size(b));
    imAlpha(isnan(b)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],b,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; clim([cmin(2) cmax(2)]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    add_title(gca,labels{2});
    
    axs(3) = subplot(3,1,3);
    imAlpha = ones(size(c));
    imAlpha(isnan(c)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],c,'AlphaData',imAlpha); 
    colormap(blue2red(121)); colorbar; hold on; clim([cmin(3) cmax(3)]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    add_title(gca,labels{3});
end