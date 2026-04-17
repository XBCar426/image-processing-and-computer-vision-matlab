clear; close all; clc;

%% 1. Read image and crop to region where road is

I = imread('HWY447.png');  
[Himg, Wimg, ~] = size(I);

rowStart = round(Himg * 0.55);   
Iroi = I(rowStart:end, :, :);    

figure; imshow(Iroi); title('ROI (bottom part with road)');

%% 2. Convert to HSV and make color masks (yellow vs white)

Ihsv = rgb2hsv(Iroi);
H = Ihsv(:,:,1);     
S = Ihsv(:,:,2);     
V = Ihsv(:,:,3);     

yellowMask = (H > 0.10 & H < 0.18) & (S > 0.4) & (V > 0.4);

whiteMask = (S < 0.25) & (V > 0.7);

se = strel('line', 5, 0);
yellowMask = imdilate(imerode(yellowMask, se), se);
whiteMask  = imdilate(imerode(whiteMask, se), se);

figure; 
subplot(1,2,1); imshow(yellowMask); title('Yellow mask (center line)');
subplot(1,2,2); imshow(whiteMask);  title('White mask (lane edges)');

%% 3. Edge detection on each mask

edgesYellow = edge(yellowMask, 'canny');
edgesWhite  = edge(whiteMask,  'canny');

figure;
subplot(1,2,1); imshow(edgesYellow); title('Edges: yellow center line');
subplot(1,2,2); imshow(edgesWhite);  title('Edges: white lines');

%% 4. Hough transform on YELLOW (center line)

[Hc, thetaC, rhoC] = hough(edgesYellow);
Pyc = houghpeaks(Hc, 5, 'Threshold', 0.3*max(Hc(:)));
centerLines = houghlines(edgesYellow, thetaC, rhoC, Pyc, ...
                         'FillGap', 40, 'MinLength', 30);

bestCenterIdx = 0;
bestLen = 0;
for k = 1:length(centerLines)
    p1 = centerLines(k).point1;
    p2 = centerLines(k).point2;
    L = hypot(p2(1)-p1(1), p2(2)-p1(2));
    if L > bestLen
        bestLen = L;
        bestCenterIdx = k;
    end
end

%% 5. Hough transform on WHITE (lane edges)

[Hw, thetaW, rhoW] = hough(edgesWhite);
Pyw = houghpeaks(Hw, 10, 'Threshold', 0.3*max(Hw(:)));
whiteLines = houghlines(edgesWhite, thetaW, rhoW, Pyw, ...
                        'FillGap', 40, 'MinLength', 40);

bestLeftIdx  = 0;
bestRightIdx = 0;
bestLeftLen  = 0;
bestRightLen = 0;

for k = 1:length(whiteLines)
    p1 = whiteLines(k).point1;
    p2 = whiteLines(k).point2;
    dx = p2(1) - p1(1);
    dy = p2(2) - p1(2);

    if dx == 0
        slope = Inf;
    else
        slope = dy / dx;
    end

    L = hypot(dx, dy);

    if slope > 0.3  
        if L > bestLeftLen
            bestLeftLen = L;
            bestLeftIdx = k;
        end
    elseif slope < -0.3  
        if L > bestRightLen
            bestRightLen = L;
            bestRightIdx = k;
        end
    end
end

%% 6. Plot the three lines on the ORIGINAL image

figure; imshow(I); hold on;
title('Lane detection using color + Hough transform');

yOffset = rowStart - 1;   % shift ROI y-coordinates back to full image

% ---- Plot left WHITE lane (green) ----
if bestLeftIdx ~= 0
    p1 = whiteLines(bestLeftIdx).point1;
    p2 = whiteLines(bestLeftIdx).point2;
    plot([p1(1), p2(1)], ...
         [p1(2)+yOffset, p2(2)+yOffset], ...
         'g-', 'LineWidth', 4);
end

if bestCenterIdx ~= 0
    p1 = centerLines(bestCenterIdx).point1;
    p2 = centerLines(bestCenterIdx).point2;
    plot([p1(1), p2(1)], ...
         [p1(2)+yOffset, p2(2)+yOffset], ...
         'y-', 'LineWidth', 4);
end

if bestRightIdx ~= 0
    p1 = whiteLines(bestRightIdx).point1;
    p2 = whiteLines(bestRightIdx).point2;
    plot([p1(1), p2(1)], ...
         [p1(2)+yOffset, p2(2)+yOffset], ...
         'r-', 'LineWidth', 4);
end

legend({'Left white lane', 'Center yellow line', 'Right white lane'}, ...
       'Location','southoutside');

hold off;

%% 7. Simple text output for the robot / debugging

fprintf('Center line found: %d\n', bestCenterIdx ~= 0);
fprintf('Left  white lane found: %d\n', bestLeftIdx  ~= 0);
fprintf('Right white lane found: %d\n', bestRightIdx ~= 0);
