%% (f) Compare histograms of Desert (e) and Winter (b) by overlaying them
clc; clear; close all;

Iw = rgb2gray(imread('Winter.png'));
Id = rgb2gray(imread('Desert.png'));

[countW, bins] = imhist(Iw);         
[countD, ~]    = imhist(Id);

pdfW = countW / sum(countW);        
pdfD = countD / sum(countD);

figure;
plot(bins, pdfW, 'LineWidth', 1.5); hold on;
plot(bins, pdfD, 'LineWidth', 1.5);
xlim([0 255]); grid on;
xlabel('Gray level'); ylabel('Normalized count');
title('Winter vs Desert (normalized histograms)');
legend('Winter','Desert');

L1diff = sum(abs(pdfW - pdfD));
fprintf('L1 histogram distance (Winter vs Desert) = %.3f\n', L1diff);