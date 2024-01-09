function plot_exs4(lon,lat,a,b,c,d,cmin,cmax)
    
    cmap = blue2red(121);
    figure; set(gcf,'Position',[10 10 800 1200]);
    subplot(2,2,1);
    imAlpha = ones(size(a));
    imAlpha(isnan(a)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],a,'AlphaData',imAlpha); 
    colormap(cmap); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    subplot(2,2,2);
    imAlpha = ones(size(b));
    imAlpha(isnan(b)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],b,'AlphaData',imAlpha); 
    colormap(cmap); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    subplot(2,2,3);
    imAlpha = ones(size(c));
    imAlpha(isnan(c)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],c,'AlphaData',imAlpha); 
    colormap(cmap); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
    subplot(2,2,4);
    imAlpha = ones(size(d));
    imAlpha(isnan(d)) = 0;
    imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],d,'AlphaData',imAlpha); 
    colormap(cmap); colorbar; hold on; caxis([cmin cmax]); 
    set(gca,'YDir','normal');
    ylim([-60 90]);
end