%% 1d) Compare whole-image vs crop histograms by overlaying
figure;
plot(bins, pdfW, 'LineWidth', 1.5); hold on;
plot(bins, pdfCrop, 'LineWidth', 1.5);
xlim([0 255]);
xlabel('Gray level'); ylabel('Normalized count');
title('Winter: whole vs crop (overlaid)');
legend('Whole image','100x100 crop');
grid on;
