clear;close all;clc;

dx = 1/8;
dy = 1/8;

fileID = fopen('/compyfs/icom/xudo627/MERIT/MERIT_tiles.txt');
C = textscan(fileID,'%s');
tiles = cell(length(C{1}),1);
fclose(fileID);

for j = 1 : length(C{1})
    tiles{j} = C{1}{j};
    tile = tiles{j};
    disp(tile);
    
    dem = double(imread(['/compyfs/icom/xudo627/MERIT/' tile]));
    
    if strcmp(tile(1),'n')
        ymin = str2double(tile(2:3));
    elseif strcmp(tile(1),'s')
        ymin = -str2double(tile(2:3));
    end

    ymax = ymin + 5;

    if strcmp(tile(4),'w')
        xmin = -str2double(tile(5:7));
    elseif strcmp(tile(4),'e')
        xmin = str2double(tile(5:7));
    end

    xmax = xmin + 5;

    x = xmin + dx/2 : dx : xmax - dx/2;
    y = ymax - dy/2 : -dy : ymin + dy/2;
    [x,y] = meshgrid(x,y);
    
    frac = NaN(40,40);

    for ii = 1 : 40
        for jj = 1 : 40
            tmp = dem((ii-1)*150 + 1 : ii*150,(jj-1)*150 + 1 : jj*150);
            ind = find(tmp == -9999);
            frac(ii,jj) = (150 * 150 - length(ind)) / (150 * 150);
        end
    end
    
    save(['/compyfs/xudo627/Land_Ocean_Coupling/MERIT_frac/' tile(1:8) 'frac.mat'],'x','y','frac');
end
