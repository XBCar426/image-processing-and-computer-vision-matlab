function [loss, grads] = nn_forward_backward(X, Y, params)

    W1 = params.W1; b1 = params.b1;
    W2 = params.W2; b2 = params.b2;
    N = size(X,2);

    % ---- Forward ----
    Z1 = W1*X + b1;           % hidden pre-activation
    A1 = max(0, Z1);          % ReLU
    Z2 = W2*A1 + b2;          % output pre-activation

    % Softmax
    Z2 = bsxfun(@minus, Z2, max(Z2,[],1)); 
    expZ = exp(Z2);
    Yhat = expZ ./ sum(expZ,1);

    % Cross-entropy loss
    epsVal = 1e-12;
    lossVec = -sum(Y .* log(Yhat + epsVal), 1);
    loss = mean(lossVec);

    % ---- Backward ----
    dZ2 = (Yhat - Y) / N;   

    grads.dW2 = dZ2 * A1';
    grads.db2 = sum(dZ2, 2);

    dA1 = W2' * dZ2;    
    dZ1 = dA1 .* (Z1 > 0); 

    grads.dW1 = dZ1 * X';
    grads.db1 = sum(dZ1, 2);
end
