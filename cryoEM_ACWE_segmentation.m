%% Q3 – Segmentation with TV smoothing and ACWE (Chan–Vese)

clear; clc; close all;

% (a) Load Cryo-EM images and apply TV smoothing
img1 = imread('Cryo_EM_Image1.jpeg');
img2 = imread('Cryo_EM_Image2.png');

if size(img1,3)==3, img1 = rgb2gray(img1); end
if size(img2,3)==3, img2 = rgb2gray(img2); end

img1 = im2double(img1);
img2 = im2double(img2);

% TV parameters
weight      = 0.18;
eps         = 2e-4; 
n_iter_max  = 10;

% Run TV-Chambolle denoising
[den1, tvIters1] = denoise_tv_chambolle_matlab(img1, weight, eps, n_iter_max);
[den2, tvIters2] = denoise_tv_chambolle_matlab(img2, weight, eps, n_iter_max);

figure('Name','Step (a): TV smoothing results', ...
       'Units','normalized','Position',[0.1 0.1 0.6 0.6]);
subplot(2,2,1); imshow(img1,[]); title('Image1 - RAW');
subplot(2,2,2); imshow(den1,[]); title('Image1 - TV smoothed');
subplot(2,2,3); imshow(img2,[]); title('Image2 - RAW');
subplot(2,2,4); imshow(den2,[]); title('Image2 - TV smoothed');

figure('Name','Step (a): TV iterations for both images', ...
       'Units','normalized','Position',[0.05 0.05 0.9 0.8]);
tiledlayout(4,5,'TileSpacing','compact','Padding','compact');

for k = 1:n_iter_max
    nexttile(k);
    imshow(tvIters1(:,:,k),[]);
    title(sprintf('Img1 TV - iter %d',k),'FontSize',8);

    nexttile(k + n_iter_max);
    imshow(tvIters2(:,:,k),[]);
    title(sprintf('Img2 TV - iter %d',k),'FontSize',8);
end

% (b) Apply ACWE to RAW and TV images, show 1–10 iterations
maxIter  = 10;
stepIter = 1;

mask1 = false(size(img1));
mask2 = false(size(img2));

pad1 = round(size(img1)/6);
pad2 = round(size(img2)/6);

mask1(1+pad1(1):end-pad1(1), 1+pad1(2):end-pad1(2)) = true;
mask2(1+pad2(1):end-pad2(1), 1+pad2(2):end-pad2(2)) = true;

seg1_raw = mask1;  seg1_tv = mask1;
seg2_raw = mask2;  seg2_tv = mask2;

seg1_raw_hist = false([size(img1) maxIter]);
seg1_tv_hist  = false([size(img1) maxIter]);
seg2_raw_hist = false([size(img2) maxIter]);
seg2_tv_hist  = false([size(img2) maxIter]);

%% ----------------------- Image 1: RAW vs TV -----------------------------
figure('Name','Step (b): Image1 ACWE RAW vs TV', ...
       'Units','normalized','Position',[0.05 0.05 0.9 0.8]);
tiledlayout(4,5,'TileSpacing','compact','Padding','compact');

for it = 1:maxIter
    seg1_raw = activecontour(img1, seg1_raw, stepIter, 'Chan-Vese');
    seg1_tv  = activecontour(den1, seg1_tv,  stepIter, 'Chan-Vese');

    seg1_raw_hist(:,:,it) = seg1_raw;
    seg1_tv_hist(:,:,it)  = seg1_tv;

    nexttile(it);
    imshow(img1,[]); hold on;
    visboundaries(seg1_raw,'Color','r','LineWidth',0.8);
    title(sprintf('Img1 RAW – iter %d',it),'FontSize',8);
    hold off;

    nexttile(it + maxIter);
    imshow(den1,[]); hold on;
    visboundaries(seg1_tv,'Color','g','LineWidth',0.8);
    title(sprintf('Img1 TV – iter %d',it),'FontSize',8);
    hold off;
end

%% Image 2: RAW vs TV 
figure('Name','Step (b): Image2 ACWE RAW vs TV', ...
       'Units','normalized','Position',[0.05 0.05 0.9 0.8]);
tiledlayout(4,5,'TileSpacing','compact','Padding','compact');

for it = 1:maxIter
    seg2_raw = activecontour(img2, seg2_raw, stepIter, 'Chan-Vese');
    seg2_tv  = activecontour(den2, seg2_tv,  stepIter, 'Chan-Vese');

    % store masks
    seg2_raw_hist(:,:,it) = seg2_raw;
    seg2_tv_hist(:,:,it)  = seg2_tv;

    % show RAW
    nexttile(it);
    imshow(img2,[]); hold on;
    visboundaries(seg2_raw,'Color','r','LineWidth',0.8);
    title(sprintf('Img2 RAW – iter %d',it),'FontSize',8);
    hold off;

    % show TV
    nexttile(it + maxIter);
    imshow(den2,[]); hold on;
    visboundaries(seg2_tv,'Color','g','LineWidth',0.8);
    title(sprintf('Img2 TV – iter %d',it),'FontSize',8);
    hold off;
end

% (c) Compare performance in step (b): RAW vs TV
iters = 1:maxIter;

areaFrac = @(BW) nnz(BW)/numel(BW);

IoU = @(A,B) nnz(A & B) / max(nnz(A | B), 1);

getPerim = @(BW) localPerimeterSum(BW);

A1_raw = zeros(maxIter,1); A1_tv = zeros(maxIter,1);
P1_raw = zeros(maxIter,1); P1_tv = zeros(maxIter,1);
S1_raw = NaN(maxIter,1);   S1_tv = NaN(maxIter,1);

A2_raw = zeros(maxIter,1); A2_tv = zeros(maxIter,1);
P2_raw = zeros(maxIter,1); P2_tv = zeros(maxIter,1);
S2_raw = NaN(maxIter,1);   S2_tv = NaN(maxIter,1);

for k = 1:maxIter
    BWraw = seg1_raw_hist(:,:,k);
    BWtv  = seg1_tv_hist(:,:,k);

    A1_raw(k) = areaFrac(BWraw);
    A1_tv(k)  = areaFrac(BWtv);

    P1_raw(k) = getPerim(BWraw);
    P1_tv(k)  = getPerim(BWtv);

    if k >= 2
        S1_raw(k) = IoU(seg1_raw_hist(:,:,k-1), seg1_raw_hist(:,:,k));
        S1_tv(k)  = IoU(seg1_tv_hist(:,:,k-1),  seg1_tv_hist(:,:,k));
    end
end

for k = 1:maxIter
    BWraw = seg2_raw_hist(:,:,k);
    BWtv  = seg2_tv_hist(:,:,k);

    A2_raw(k) = areaFrac(BWraw);
    A2_tv(k)  = areaFrac(BWtv);

    P2_raw(k) = getPerim(BWraw);
    P2_tv(k)  = getPerim(BWtv);

    if k >= 2
        S2_raw(k) = IoU(seg2_raw_hist(:,:,k-1), seg2_raw_hist(:,:,k));
        S2_tv(k)  = IoU(seg2_tv_hist(:,:,k-1),  seg2_tv_hist(:,:,k));
    end
end

figure('Name','(c) Comparison metrics – Image 1', ...
       'Units','normalized','Position',[0.1 0.1 0.7 0.7]);

subplot(3,1,1);
plot(iters, A1_raw,'-o','LineWidth',1.5); hold on;
plot(iters, A1_tv, '-o','LineWidth',1.5);
ylabel('Area fraction'); grid on;
legend('RAW','TV-smoothed','Location','best');
title('Image 1: Segmentation area vs iteration');

subplot(3,1,2);
plot(iters, P1_raw,'-o','LineWidth',1.5); hold on;
plot(iters, P1_tv, '-o','LineWidth',1.5);
ylabel('Perimeter'); grid on;
legend('RAW','TV-smoothed','Location','best');
title('Image 1: Boundary length (roughness/leak)');

subplot(3,1,3);
plot(iters, S1_raw,'-o','LineWidth',1.5); hold on;
plot(iters, S1_tv, '-o','LineWidth',1.5);
xlabel('Iteration'); ylabel('IoU with prev iter'); grid on;
legend('RAW','TV-smoothed','Location','best');
title('Image 1: Stability (higher = converging faster)');

figure('Name','(c) Comparison metrics – Image 2', ...
       'Units','normalized','Position',[0.1 0.1 0.7 0.7]);

subplot(3,1,1);
plot(iters, A2_raw,'-o','LineWidth',1.5); hold on;
plot(iters, A2_tv, '-o','LineWidth',1.5);
ylabel('Area fraction'); grid on;
legend('RAW','TV-smoothed','Location','best');
title('Image 2: Segmentation area vs iteration');

subplot(3,1,2);
plot(iters, P2_raw,'-o','LineWidth',1.5); hold on;
plot(iters, P2_tv, '-o','LineWidth',1.5);
ylabel('Perimeter'); grid on;
legend('RAW','TV-smoothed','Location','best');
title('Image 2: Boundary length (roughness/leak)');

subplot(3,1,3);
plot(iters, S2_raw,'-o','LineWidth',1.5); hold on;
plot(iters, S2_tv, '-o','LineWidth',1.5);
xlabel('Iteration'); ylabel('IoU with prev iter'); grid on;
legend('RAW','TV-smoothed','Location','best');
title('Image 2: Stability (higher = converging faster)');

fprintf('\n--- (c) Comparison summary at iter %d ---\n', maxIter);
fprintf('Image 1: Area RAW=%.3f, TV=%.3f | Perim RAW=%.1f, TV=%.1f\n', ...
    A1_raw(end), A1_tv(end), P1_raw(end), P1_tv(end));
fprintf('Image 2: Area RAW=%.3f, TV=%.3f | Perim RAW=%.1f, TV=%.1f\n', ...
    A2_raw(end), A2_tv(end), P2_raw(end), P2_tv(end));
fprintf('If TV helps, you typically see smoother contours (lower perimeter) and faster stabilization (higher IoU earlier).\n\n');

function [u, u_all] = denoise_tv_chambolle_matlab(f, weight, eps, n_iter_max)

    [m,n] = size(f);

    px = zeros(m,n);
    py = zeros(m,n);

    tau = 0.125;
    u   = f;
    u_all = zeros(m,n,n_iter_max);

    for k = 1:n_iter_max
        ux = zeros(m,n);
        uy = zeros(m,n);
        ux(:,1:end-1) = u(:,2:end) - u(:,1:end-1);
        uy(1:end-1,:) = u(2:end,:) - u(1:end-1,:);

        pxNew = px + tau * ux;
        pyNew = py + tau * uy;

        mag = sqrt(pxNew.^2 + pyNew.^2);
        mag = max(1, mag);  
        px = pxNew ./ mag;
        py = pyNew ./ mag;

        divP = zeros(m,n);
        divP(:,1)       = px(:,1);
        divP(:,2:end-1) = px(:,2:end-1) - px(:,1:end-2);
        divP(:,end)     = -px(:,end-1);

        divP(1,:)       = divP(1,:) + py(1,:);
        divP(2:end-1,:) = divP(2:end-1,:) + (py(2:end-1,:) - py(1:end-2,:));
        divP(end,:)     = divP(end,:) - py(end-1,:);

        u = f + weight * divP;

        u_all(:,:,k) = u;
    end
end

function perSum = localPerimeterSum(BW)
    stats = regionprops(BW, 'Perimeter');
    if isempty(stats)
        perSum = 0;
    else
        perSum = sum([stats.Perimeter]);
    end
end
