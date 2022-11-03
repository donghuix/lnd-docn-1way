clear;close all;

% This script is to test which interpolation method is faster.
% Conclusion, using griddedInterpolant is very fast. 

load('../data/bathtub_global_coastline_merit_90m.mat');
idx = 1 : size(merit_bathtub,1);

[X,Y] = meshgrid(idx,SLR);
X = X';
Y = Y';
rng(randi(100,1));

% Using griddedInterpolant
tic;
F = griddedInterpolant(X,Y,merit_bathtub);
slr = NaN(size(merit_bathtub,1),10);
for i = 1 : 10
    slr(:,i) = rand(size(merit_bathtub,1),1);
    inund0 = F(idx', slr(:,i));
end
toc;

% Using interp1
tic;
for j = 1 : 10
    inund1 = NaN(size(merit_bathtub,1),1);
    for i = 1 : size(merit_bathtub,1)
        inund1(i) = interp1(SLR,merit_bathtub(i,:),slr(i,j));
    end
end
toc;

figure;
plot(inund0,inund1,'bo');
