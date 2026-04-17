clear; close all; clc;

%% (1) READ IMAGE

I = imread('CoffeeBeans.tif');

if size(I,3) > 1
    Ig = rgb2gray(I);
else
    Ig = I;
end
Ig = im2uint8(Ig);

figure; imshow(Ig,[]);
title('Original Image');

%% (A) ORIGINAL IMAGE → TRUE LARGEST OBJECT

T  = graythresh(Ig);
BW = imbinarize(Ig, T);

if mean(Ig(BW)) > mean(Ig(~BW))
    BW = ~BW;
end

BW = bwareaopen(BW, 80);
BW = imopen(BW, strel('disk',2));
BW = imfill(BW,'holes');

CC = bwconncomp(BW, 8);
stats = regionprops(CC, 'Area', 'PixelIdxList');

areas = [stats.Area];
[~, idxLargest] = max(areas);

largestMask = false(size(BW));
largestMask(stats(idxLargest).PixelIdxList) = true;

figure; imshow(largestMask);
title('TRUE Largest Object (Original)');

%% (B) ORIGINAL BOUNDARY 

perimOrig = bwperim(largestMask);
[y0, x0] = find(perimOrig);

figure;
imshow(Ig,[]); hold on;
plot(x0, y0, 'r.', 'MarkerSize', 8);
title('Largest Object Boundary (Original)');

%% (C) ORIGINAL CURVATURE

sigma = 2;
kappa = boundary_curvature(x0, y0, sigma);

figure;
plot(kappa,'k','LineWidth',1.5);
xlabel('Boundary Index');
ylabel('Curvature');
title('Curvature (Original)');
grid on;

%% (D) ROTATE IMAGE + ROTATE ORIGINAL OBJECT MASK

angleDeg = 30;

IgRot   = imrotate(Ig, angleDeg, 'bilinear', 'loose');
maskRot = imrotate(largestMask, angleDeg, 'nearest', 'loose');

figure; imshow(IgRot,[]);
title('Rotated Image 30°');

figure; imshow(maskRot);
title('Rotated ORIGINAL Object Mask');

T2  = graythresh(IgRot);
BW2 = imbinarize(IgRot, T2);

if mean(IgRot(BW2)) > mean(IgRot(~BW2))
    BW2 = ~BW2;
end

BW2 = bwareaopen(BW2, 80);
BW2 = imopen(BW2, strel('disk',2));
BW2 = imfill(BW2,'holes');

largestMask2 = BW2 & maskRot;

largestMask2 = bwareaopen(largestMask2, 300);   % kill any stragglers
largestMask2 = imfill(largestMask2,'holes');


perimRot = bwperim(largestMask2);
[y2, x2] = find(perimRot);

figure;
imshow(IgRot,[]); hold on;
plot(x2, y2, 'r.', 'MarkerSize', 8);
title('SAME Object Boundary');

kappaRot = boundary_curvature(x2, y2, sigma);

figure;
plot(kappa,'b','LineWidth',1.5); hold on;
plot(kappaRot,'r','LineWidth',1.5);
legend('Original','Rotated');
xlabel('Boundary Index');
ylabel('Curvature');
title('Curvature Comparison');
grid on;

meanAbs1 = mean(abs(kappa));
meanAbs2 = mean(abs(kappaRot));

fprintf('\nMean |curvature| original = %.6f\n', meanAbs1);
fprintf('Mean |curvature| rotated  = %.6f\n', meanAbs2);
fprintf('Difference = %.6f\n', abs(meanAbs1-meanAbs2));

function kappa = boundary_curvature(x, y, sigma)

    x = x(:); 
    y = y(:);

    pad = 10;
    xPad = [x(end-pad+1:end); x; x(1:pad)];
    yPad = [y(end-pad+1:end); y; y(1:pad)];

    win = ceil(6*sigma);
    if mod(win,2)==0, win = win + 1; end

    g = fspecial('gaussian',[win 1], sigma);

    xS = conv(xPad, g, 'same');
    yS = conv(yPad, g, 'same');

    xS = xS(pad+1:end-pad);
    yS = yS(pad+1:end-pad);

    dx  = gradient(xS);
    dy  = gradient(yS);
    ddx = gradient(dx);
    ddy = gradient(dy);

    kappa = (dx.*ddy - dy.*ddx) ./ ((dx.^2 + dy.^2).^(3/2) + 1e-12);
end
