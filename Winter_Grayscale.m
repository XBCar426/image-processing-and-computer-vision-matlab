%% 1a) Read Winter.png, show color and grayscale
clc; clear; close all;

% read color
Iwinter = imread('Winter.png'); 

% show color
figure; imshow(Iwinter);
title('Winter.png (color)');

% make grayscale
Iwinter_gray = rgb2gray(Iwinter);

% show grayscale
figure; imshow(Iwinter_gray);
title('Winter.png (grayscale)');
