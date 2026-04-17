% Problem 5 – MNIST digit classification with a neural network (MATLAB)

clear; clc; close all;

% (a) Load MNIST and show a sample of digits
fprintf('Loading MNIST data ...\n');

trainImages = readMNISTImages('train-images.idx3-ubyte');
trainLabels = readMNISTLabels('train-labels.idx1-ubyte');
testImages  = readMNISTImages('t10k-images.idx3-ubyte');
testLabels  = readMNISTLabels('t10k-labels.idx1-ubyte');

[numRows, numCols, numTrain] = size(trainImages);
numTest = size(testImages,3);

fprintf('Train images: %d, Test images: %d\n', numTrain, numTest);

% Flatten images and normalize
Xtrain = reshape(trainImages, numRows*numCols, numTrain);
Xtest  = reshape(testImages,  numRows*numCols, numTest);
Xtrain = double(Xtrain) / 255;
Xtest  = double(Xtest)  / 255;

% One-hot labels
numClasses = 10;
Ytrain = full(ind2vec(trainLabels' + 1, numClasses));
Ytest  = full(ind2vec(testLabels'  + 1, numClasses));

figure('Name','Sample MNIST digits');
idxSample = randperm(numTrain,16);
for i = 1:16
    subplot(4,4,i);
    imshow(reshape(Xtrain(:,idxSample(i)), numRows, numCols), []);
    title(sprintf('%d', trainLabels(idxSample(i))));
end

% (b) Network architecture
inputSize  = numRows * numCols;   % 784
hiddenSize = 128;
outputSize = numClasses;

rng(1);
W1 = randn(hiddenSize, inputSize)  * sqrt(2/(inputSize + hiddenSize));
b1 = zeros(hiddenSize, 1);
W2 = randn(outputSize, hiddenSize) * sqrt(2/(hiddenSize + outputSize));
b2 = zeros(outputSize, 1);

params.W1 = W1; params.b1 = b1;
params.W2 = W2; params.b2 = b2;

valFraction = 0.1;
numVal = round(valFraction * numTrain);

perm = randperm(numTrain);
valIdx   = perm(1:numVal);
trainIdx = perm(numVal+1:end);

Xval   = Xtrain(:, valIdx);
Yval   = Ytrain(:, valIdx);
Xtrain = Xtrain(:, trainIdx);
Ytrain = Ytrain(:, trainIdx);
trainLabelsTrain = trainLabels(trainIdx);

numTrainEff = size(Xtrain,2);

% (c) Training: cost and performance profile
numEpochs    = 10;
batchSize    = 128;
learningRate = 0.01;

trainLoss = zeros(numEpochs,1);
valLoss   = zeros(numEpochs,1);
trainAcc  = zeros(numEpochs,1);
valAcc    = zeros(numEpochs,1);

fprintf('\nTraining neural network ...\n');
for epoch = 1:numEpochs
    p = randperm(numTrainEff);
    Xtrain = Xtrain(:, p);
    Ytrain = Ytrain(:, p);
    trainLabelsTrain = trainLabelsTrain(p);


    for i = 1:batchSize:numTrainEff
        j = min(i + batchSize - 1, numTrainEff);
        Xbatch = Xtrain(:, i:j);
        Ybatch = Ytrain(:, i:j);

        [~, grads] = nn_forward_backward(Xbatch, Ybatch, params);

        params.W1 = params.W1 - learningRate * grads.dW1;
        params.b1 = params.b1 - learningRate * grads.db1;
        params.W2 = params.W2 - learningRate * grads.dW2;
        params.b2 = params.b2 - learningRate * grads.db2;
    end

    [trainLoss(epoch), trainAcc(epoch)] = evaluateNN(Xtrain, Ytrain, params);
    [valLoss(epoch),   valAcc(epoch)]   = evaluateNN(Xval,   Yval,   params);

    fprintf('Epoch %2d/%2d | Train loss: %.4f, acc: %.3f | Val loss: %.4f, acc: %.3f\n', ...
        epoch, numEpochs, trainLoss(epoch), trainAcc(epoch), ...
        valLoss(epoch),   valAcc(epoch));
end

% Plot cost
figure('Name','Cost function vs epoch');
plot(1:numEpochs, trainLoss, '-o', 'LineWidth',1.5); hold on;
plot(1:numEpochs, valLoss,   '-o', 'LineWidth',1.5);
xlabel('Epoch'); ylabel('Cross-entropy loss');
legend({'Training','Validation'}, 'Location','northeast');
title('Cost function during training'); grid on;

% Plot accuracy
figure('Name','Accuracy vs epoch');
plot(1:numEpochs, trainAcc, '-o', 'LineWidth',1.5); hold on;
plot(1:numEpochs, valAcc,   '-o', 'LineWidth',1.5);
xlabel('Epoch'); ylabel('Accuracy');
legend({'Training','Validation'}, 'Location','southeast');
title('Accuracy during training'); grid on;

[testLoss, testAcc] = evaluateNN(Xtest, Ytest, params);
fprintf('\nFinal test loss: %.4f, test accuracy: %.3f\n', testLoss, testAcc);

% (e) k-fold cross-validation (fixed indexing)

K = 5;   % 5-fold CV
fprintf('\nRunning %d-fold cross-validation (this may take a while)...\n', K);

numSamplesForCV = size(Xtrain, 2);       
indices = crossvalind('Kfold', numSamplesForCV, K);

cvAcc = zeros(K,1);

for k = 1:K
    fprintf('Fold %d/%d ...\n', k, K);

    testIdxCV  = (indices == k); 
    trainIdxCV = ~testIdxCV;

    XtrainCV = Xtrain(:, trainIdxCV);
    YtrainCV = Ytrain(:, trainIdxCV);
    XvalCV   = Xtrain(:, testIdxCV);
    YvalCV   = Ytrain(:, testIdxCV);

    W1 = randn(hiddenSize, inputSize)  * sqrt(2/(inputSize + hiddenSize));
    b1 = zeros(hiddenSize, 1);
    W2 = randn(outputSize, hiddenSize) * sqrt(2/(hiddenSize + outputSize));
    b2 = zeros(outputSize, 1);
    paramsCV.W1 = W1; paramsCV.b1 = b1;
    paramsCV.W2 = W2; paramsCV.b2 = b2;

    cvEpochs   = 5; 
    numTrainCV = size(XtrainCV,2);

    for ep = 1:cvEpochs
        p = randperm(numTrainCV);
        XtrainCV = XtrainCV(:, p);
        YtrainCV = YtrainCV(:, p);

        for i = 1:batchSize:numTrainCV
            j = min(i + batchSize - 1, numTrainCV);
            Xb = XtrainCV(:, i:j);
            Yb = YtrainCV(:, i:j);

            [~, gradsCV] = nn_forward_backward(Xb, Yb, paramsCV);
            paramsCV.W1 = paramsCV.W1 - learningRate * gradsCV.dW1;
            paramsCV.b1 = paramsCV.b1 - learningRate * gradsCV.db1;
            paramsCV.W2 = paramsCV.W2 - learningRate * gradsCV.dW2;
            paramsCV.b2 = paramsCV.b2 - learningRate * gradsCV.db2;
        end
    end

    [~, accFold] = evaluateNN(XvalCV, YvalCV, paramsCV);
    cvAcc(k) = accFold;
    fprintf('Fold %d accuracy: %.3f\n', k, accFold);
end

meanCV = mean(cvAcc);
stdCV  = std(cvAcc);

fprintf('\nCross-validation accuracies: ');
fprintf('%.3f ', cvAcc);
fprintf('\nMean CV accuracy = %.3f, Std = %.3f\n', meanCV, stdCV);

function [loss, acc] = evaluateNN(X, Y, params)
    W1 = params.W1; b1 = params.b1;
    W2 = params.W2; b2 = params.b2;

    Z1 = W1*X + b1;
    A1 = max(0, Z1);      
    Z2 = W2*A1 + b2;
    Z2 = bsxfun(@minus, Z2, max(Z2,[],1));
    expZ = exp(Z2);
    Yhat = expZ ./ sum(expZ,1);       

    epsVal = 1e-12;
    lossVec = -sum(Y .* log(Yhat + epsVal), 1);
    loss = mean(lossVec);

    [~, pred]  = max(Yhat, [], 1);
    [~, truth] = max(Y,    [], 1);
    acc = mean(pred == truth);
end
