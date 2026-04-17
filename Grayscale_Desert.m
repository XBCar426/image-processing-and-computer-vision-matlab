%% 1e) Read Desert.png, convert to grayscale, and display
Idesert = imread('Desert.png');
Idesert_gray = rgb2gray(Idesert);

figure; imshow(Idesert_gray);
title('Desert.png (grayscale)');
