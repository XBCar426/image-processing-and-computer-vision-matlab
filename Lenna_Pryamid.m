%% 2) Lenna: grayscale + 3-level downsampled pyramid
clc; clear; close all;


Icolor = imread('Lenna.png');  

Igray = rgb2gray(Icolor);
figure; imshow(Igray); title('Lenna (grayscale)');


L1 = imresize(Igray, 0.5);   % level 1 (1/2 size)
L2 = imresize(L1,   0.5);    % level 2 (1/4 size)
L3 = imresize(L2,   0.5);    % level 3 (1/8 size)

% showing the pyramid
figure;
subplot(1,4,1); imshow(Igray); title(sprintf('Level 0: %dx%d',size(Igray,2),size(Igray,1)));
subplot(1,4,2); imshow(L1);    title(sprintf('Level 1: %dx%d',size(L1,2),size(L1,1)));
subplot(1,4,3); imshow(L2);    title(sprintf('Level 2: %dx%d',size(L2,2),size(L2,1)));
subplot(1,4,4); imshow(L3);    title(sprintf('Level 3: %dx%d',size(L3,2),size(L3,1)));
