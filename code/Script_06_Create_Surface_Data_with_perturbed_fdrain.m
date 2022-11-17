clear;close all;clc;

addpath('/qfs/people/xudo627/mylib/m/');

% 1: 2.5, 2:    3:   4:   5:   6:   7:    8:
fdrains = [0.1; 0.2; 0.5; 1.0; 5.0; 10.0; 20];
tags    = {'0.1', '0.2', '0.5', '1.0', '5.0', '10.0', '20'};

fin = '../inputdata/surfdata_global_coastline_merit_90m_fd2.5_c221109.nc';

fd = ncread(fin,'fdrain');

for i = 1 : length(fdrains)
    
    fout = ['../inputdata/surfdata_global_coastline_merit_90m_fd' tags{i} '_c221109.nc'];
    disp(fout);
    copyfile(fin, fout);
    ncwrite(fout,'fdrain',ones(length(fd),1).*fdrains(i));
    
end
