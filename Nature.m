%% 4) nature.JPG: simple creative enhancement + histograms
clc; close all;

Inat = imread('nature.JPG');

hsvImg = rgb2hsv(Inat);
V = hsvImg(:,:,3);
S = hsvImg(:,:,2);

V2 = adapthisteq(V);          
S2 = min(S * 1.15, 1);        

hsvImg(:,:,3) = V2;
hsvImg(:,:,2) = S2;
Inat_boost = hsv2rgb(hsvImg);

Inat_sharp = imsharpen(Inat_boost,'Radius',1,'Amount',0.7);

figure;
subplot(1,2,1); imshow(Inat);       title('nature.JPG (original)');
subplot(1,2,2); imshow(Inat_sharp); title('Enhanced (CLAHE + color + sharpen)');

G0 = rgb2gray(Inat);
G1 = rgb2gray(Inat_sharp);

[count0, bins] = imhist(G0);
[count1, ~   ] = imhist(G1);
pdf0 = count0 / sum(count0);
pdf1 = count1 / sum(count1);

figure;
plot(bins, pdf0, 'LineWidth', 1.5); hold on;
plot(bins, pdf1, 'LineWidth', 1.5);
grid on; xlim([0 255]);
xlabel('Gray level'); ylabel('Normalized count');
title('nature.JPG: Original vs Enhanced (overlayed)');
legend('Original','Enhanced');