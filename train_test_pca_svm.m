clear
close all

load data.mat

% number of folds of cross validation
folds = 10;
Xtrain = x(1:floor(0.9*size(x,1)),:);
Ytrain = y(1:floor(0.9*size(y,1)));

[m,d]=size(Xtrain);
kfold_val_err = [];

% call centered_pca
Test_range = 1:308;
T=1e4;
k = 4;
lambda = 1;
for i = Test_range
    
    %compress training data to dimension i
    [center, lamda, V] = centered_pca(Xtrain);
    Xtrain_compressed = center(:,1:i);
    err_sum = 0;
    for j=1:folds
        % fold j for testing and the others for training
        xte = Xtrain_compressed(floor((j-1)*m/10)+1:1:floor(j*m/10),:);
        xtr = [Xtrain_compressed(1:1:floor((j-1)*m/10),:); Xtrain_compressed(floor(j*m/10)+1:1:m,:)];
        yte = Ytrain(floor((j-1)*m/10)+1:1:floor(j*m/10));
        ytr = [Ytrain(1:1:floor((j-1)*m/10)); Ytrain(floor(j*m/10)+1:1:m)];
        % train least square on training folds
        [W] = train_svm_mhinge_sgd(xtr, ytr, k, lambda, T);
        ypred = test_svm_multi(W, xtr);
        train_err = mean(ypred~=ytr);
        ypred = test_svm_multi(W, xte);
        val_err = mean(ypred~=yte);
        err_sum = err_sum + val_err;
    end
    % store cross-validation error for compression to i dimensions
    kfold_val_err = [kfold_val_err, err_sum/folds];
    
end

plot(Test_range, kfold_val_err);

% % pick best compression level to minimize cross-validation error
% min_index = find(kfold_val_err==min(kfold_val_err));
% 
% % train with best compressed training data
% Xtrain_compressed = Xtrain(:,1:min_index);
% [w,b] = train_ls(Xtrain_compressed,Ytrain);
% 
% % test on compressed test data
% Xtest_compressed = Xtest*V*V';
% Xtest_compressed = Xtest_compressed(:,1:min_index);
% ypred = sign(Xtest_compressed*w+b);
% err = sum(ypred~=Ytest)/size(Ytest,1);
% 
% % report best compression level and test error with it
% fprintf("Best performance at k = %f, test error = %f",min_index, err);