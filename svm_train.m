%ytr = b.Classlabel;
%xtr = [time.kurtosis,time.mean,time.median,time.skewness,frequency.mean_freq,frequency.median_freq,frequency.peak_freq];

clc;clear;
load('A01E.mat');
x = [all_features.time.kurtosis,all_features.time.mean,all_features.time.median,all_features.time.skewness,all_features.frequency.mean_freq,all_features.frequency.median_freq,all_features.frequency.peak_freq];
[a,b] = sload('A01E.gdf');
y = b.Classlabel;

xval = x(261:288,:);xtr = x(1:260,:);yval = y(261:288,:);ytr = y(1:260,:);

T=1e4;
k = 4;
for pow = -15:1:10
lambda = 2^pow;

[W] = train_svm_mhinge_sgd(xtr, ytr, k, lambda, T);
ypred = test_svm_multi(W, xtr);
train_err = mean(ypred~=ytr);

ypred = test_svm_multi(W, xval);
val_err = mean(ypred~=yval);
fprintf('When lambda = %f, train error = %f, validation error = %f\n',lambda, train_err, val_err);
end