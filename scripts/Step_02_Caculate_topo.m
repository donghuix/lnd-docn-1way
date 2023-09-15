clear;close all;clc;

dx = 1/8;
dy = 1/8;

fileID = fopen('/compyfs/icom/xudo627/MERIT/MERIT_tiles.txt');
C = textscan(fileID,'%s');
tiles = cell(length(C{1}),1);
fclose(fileID);

lon = -180 + dx/2 : +dx : 180 - dx/2;
lat = 90 - dy/2   : -dy : -90 + dy/2;
[lon,lat] = meshgrid(lon,lat);
topo4th = NaN(size(lon));

for j = 1 : length(C{1})
    tiles{j} = C{1}{j};
    tile = tiles{j};
    disp(['j = ' num2str(j) '/' num2str(length(C{1})) ': ' tile]);
    
    if strcmp(tile(1),'n')
        ymin = str2double(tile(2:3));
    elseif strcmp(tile(1),'s')
        ymin = -str2double(tile(2:3));
    end

    ymax = ymin + 5;

    if strcmp(tile(4),'w')
        xmin = -str2double(tile(5:7));
    elseif strcmp(tile(4),'e')
        xmin = +str2double(tile(5:7));
    end

    xmax = xmin + 5;
    
    if ~exist(['/compyfs/xudo627/Land_Ocean_Coupling/MERIT_topo/' tile(1:8) 'topo.mat'],'file')
    dem = double(imread(['/compyfs/icom/xudo627/MERIT/' tile]));

    x = xmin + dx/2 : +dx : xmax - dx/2;
    y = ymax - dy/2 : -dy : ymin + dy/2;
    [x,y] = meshgrid(x,y);
    
    nstep = dx /(5/6000);
    nrows = 6000/nstep;
    ncols = 6000/nstep;
    
    topo = NaN(nrows,ncols);

    for ii = 1 : nrows
        for jj = 1 : ncols
            tmp = dem((ii-1)*nstep + 1 : ii*nstep,(jj-1)*nstep + 1 : jj*nstep);
            tmp(tmp == -9999) = NaN;
            topo(ii,jj) = nanmean(tmp(:));
        end
    end
    
    save(['/compyfs/xudo627/lnd-docn-1way/MERIT_topo/' tile(1:8) 'topo.mat'],...
          'x','y','topo','nstep','nrows','ncols','xmin','ymin','xmax','xmin');
    else
        load(['/compyfs/xudo627/lnd-docn-1way/MERIT_topo/' tile(1:8) 'topo.mat']);
    end
    
    if dx == 1/4
    [irow,icol] = find(lon == xmin + dx/2 & lat == ymax - dy/2);
    tmp = topo4th(irow:irow+nrows-1,icol:icol+ncols-1);
    if all(isnan(tmp(:)))
        topo4th(irow:irow+nrows-1,icol:icol+ncols-1) = topo;
    else
        error('check dimension!');
    end
    end
    
end
if dx == 1/4
save('topo4th.mat','lon','lat','topo4th');
end
