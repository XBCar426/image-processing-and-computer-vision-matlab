%% 1b) Plot grayscale histogram and normalize area to 1
% get counts for 256 levels
[countsW, bins] = imhist(Iwinter_gray);   % bins are 0..255

% normalize so the area is 1
pdfW = countsW / sum(countsW);

% plot
figure;
bar(bins, pdfW, 'BarWidth', 1);   % simple bar plot
xlim([0 255]);
xlabel('Gray level'); ylabel('Normalized count');
title('Winter grayscale histogram (area = 1)');
