%% 1c) Crop any 100x100 region with snow, show it and its histogram
%Snow 100x100 Histogram
r0 = 500;          
c0 = 150;         

crop = Iwinter_gray(r0:r0+99, c0:c0+99);

figure; imshow(crop);
title('100x100 crop (snow region)');

[countsCrop, bins] = imhist(crop);
pdfCrop = countsCrop / sum(countsCrop);

figure;
bar(bins, pdfCrop, 'BarWidth', 1);
xlim([0 255]);
xlabel('Gray level'); ylabel('Normalized count');
title('Crop histogram (area = 1)');
