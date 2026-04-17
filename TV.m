%% Python-style TV Chambolle Denoising for Cryo-EM

clear; clc; close all;

% Load images
img1 = imread('Cryo_EM_Image1.jpeg');
img2 = imread('Cryo_EM_Image2.png');

if size(img1,3)==3, img1 = rgb2gray(img1); end
if size(img2,3)==3, img2 = rgb2gray(img2); end

img1 = im2double(img1);
img2 = im2double(img2);

% parameters
weight      = 0.18;     % denoising strength
eps         = 2e-4;     % stopping tolerance
n_iter_max  = 10;       % iterations
showEvery   = 2;        % show EVERY iteration now

% Run denoising
den1 = denoise_tv_chambolle_matlab(img1, weight, eps, n_iter_max, showEvery, 'Cryo EM Image 1');
den2 = denoise_tv_chambolle_matlab(img2, weight, eps, n_iter_max, showEvery, 'Cryo EM Image 2');

figure('Name','Final Results');
subplot(2,2,1); imshow(img1,[]); title('Original Image 1');
subplot(2,2,2); imshow(den1,[]); title('TV Denoised Image 1');
subplot(2,2,3); imshow(img2,[]); title('Original Image 2');
subplot(2,2,4); imshow(den2,[]); title('TV Denoised Image 2');


function u = denoise_tv_chambolle_matlab(f, weight, eps, n_iter_max, showEvery, tag)

    [m,n] = size(f);

    px = zeros(m,n);
    py = zeros(m,n);

    tau = 0.125;
    u = f;
    prev_u = u;

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
        divP(:,1)         = px(:,1);
        divP(:,2:end-1)   = px(:,2:end-1) - px(:,1:end-2);
        divP(:,end)       = -px(:,end-1);

        divP(1,:)         = divP(1,:) + py(1,:);
        divP(2:end-1,:)   = divP(2:end-1,:) + (py(2:end-1,:) - py(1:end-2,:));
        divP(end,:)       = divP(end,:) - py(end-1,:);

        u = f + weight * divP;

        change = norm(u - prev_u, 'fro') / (norm(prev_u, 'fro') + 1e-12);
        if change < eps
            fprintf('%s stopped at iter %d (change %.2e)\n', tag, k, change);
            break;
        end
        prev_u = u;

        if mod(k,showEvery)==0 || k==1
            figure(200 + k); clf;  
            subplot(1,2,1);
            imshow(f,[]); title([tag ' - Original']);
            subplot(1,2,2);
            imshow(u,[]); title([tag ' - Iter ' num2str(k)]);
            drawnow;
        end
    end
end