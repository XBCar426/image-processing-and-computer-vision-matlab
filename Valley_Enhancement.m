%% 3) Valley image: histogram equalization (before vs after)
clc; clear; close all;

Ivalley = imread('valley.tif');
if size(Ivalley,3)==3
    Ivalley_gray = rgb2gray(Ivalley);
else
    Ivalley_gray = Ivalley;
end

figure; imshow(Ivalley_gray); title('Valley (original grayscale)');

% histogram BEFORE
figure; imhist(Ivalley_gray);
title('Valley histogram (before equalization)');

Ivalley_eq = histeq(Ivalley_gray);

figure; imshow(Ivalley_eq); title('Valley (after histogram equalization)');

% histogram AFTER
figure; imhist(Ivalley_eq);
title('Valley histogram (after equalization)');
