clear;close all;clc;

continents = {'af_con_3s','as_con_3s','au_con_3s','eu_con_3s','na_con_3s','sa_con_3s'};
figure;
for i = 1 : length(continents)
    fileID = fopen(['/Users/xudo627/Downloads/' continents{i} '.txt']);
    C = textscan(fileID,'%s');
    tiles = cell(length(C{1})/2,1);
    for j = 1 : length(C{1})/2
        tiles{j} = C{1}{(j-1)*2+1};
        tile = tiles{j};
        if strcmp(tile(1),'n')
            ymin = str2double(tile(2:3));
        elseif strcmp(tile(1),'s')
            ymin = -str2double(tile(2:3));
        end
            
        ymax = ymin + 10;
        
        if strcmp(tile(4),'w')
            xmin = -str2double(tile(5:7));
        elseif strcmp(tile(4),'e')
            xmin = str2double(tile(5:7));
        end
            
        xmax = xmin + 10;
        
        plot([xmin; xmax; xmax; xmin; xmin], [ymin; ymin; ymax; ymax; ymin],'k-','LineWidth',2); hold on;
    end
    fclose(fileID);
end

load coastlines.mat;
plot(coastlon,coastlat,'r-','LineWidth',2);