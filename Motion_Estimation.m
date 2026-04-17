%% Q2 – Motion estimation between frames 10 and 11

clear; close all; clc;

% (a) Read the two frames and convert to black & white (grayscale)
I10 = imread('Motion10.jpg');   % frame 10
I11 = imread('Motion11.jpg');   % frame 11

% grayscale
if size(I10,3) == 3
    I10_gray = rgb2gray(I10);
else
    I10_gray = I10;
end

if size(I11,3) == 3
    I11_gray = rgb2gray(I11);
else
    I11_gray = I11;
end

figure;
subplot(1,2,1); imshow(I10_gray); title('Frame 10 - Grayscale');
subplot(1,2,2); imshow(I11_gray); title('Frame 11 - Grayscale');

% (b) Compute and show optical flow between the two frames
F10 = im2single(I10_gray);
F11 = im2single(I11_gray);

opticFlow = opticalFlowHS;      % Horn–Schunck

% First frame initializes the object
estimateFlow(opticFlow, F10);

% Second frame gives us flow from frame 10 -> frame 11
flow = estimateFlow(opticFlow, F11);

% Plot the flow vectors on top of frame 11
figure;
imshow(I11_gray); hold on;
title('Optical Flow from Frame 10 to Frame 11');

plot(flow, 'DecimationFactor', [5 5], 'ScaleFactor', 10);
hold off;



% (c) Vount moving objects using the optical flow

Vx = flow.Vx;
Vy = flow.Vy;
mag = sqrt(Vx.^2 + Vy.^2);   % flow magnitude

T = mean(mag(:)) + 1*std(mag(:));

motionMask = mag > T;

motionMask = bwareaopen(motionMask, 20);           
motionMask = imclose(motionMask, strel('disk',3));  

[L, numMoving] = bwlabel(motionMask);

fprintf('Estimated number of moving objects: %d\n', numMoving);

figure;
subplot(1,2,1);
imshow(motionMask);
title('Binary Motion Mask');

subplot(1,2,2);
imshow(label2rgb(L, 'jet', 'k', 'shuffle'));
title(sprintf('Labeled Moving Objects (N = %d)', numMoving));
