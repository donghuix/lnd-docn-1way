clear;close all;clc;

user = 'globaldem';
pass = 'preciseelevation';
link = 'http://hydro.iis.u-tokyo.ac.jp/~yamadai/MERIT_DEM/distribute/v1.0.2/5deg/';

fileID = fopen('MERIT_tiles.txt');
C = textscan(fileID,'%s');
tiles = cell(length(C{1}),1);
for j = 1 : length(C{1})
    tiles{j} = C{1}{j};
    tile = tiles{j};
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

    %plot([xmin; xmax; xmax; xmin; xmin], [ymin; ymin; ymax; ymax; ymin],'k-','LineWidth',2); hold on;
    % Download
    url = [link tiles{j}];
    cmd = ['~/anaconda3/bin/wget --user ' user ' --password ' pass ' ' url];
    if exist(tiles{j},'file')
        disp([tiles{j} ' is already downloaded!']);
    else
        disp(['Downloading ' num2str(j) '/' num2str(length(C{1})) ': ' url]); 
        [status,cmdout] = system(cmd);
        disp('--> Done! <-- \n');
    end
    
end
fclose(fileID);


%load coastlines.mat;
%plot(coastlon,coastlat,'r-','LineWidth',2);