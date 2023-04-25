%ytr = b.Classlabel;
%xtr = [time.kurtosis,time.mean,time.median,time.skewness,frequency.mean_freq,frequency.median_freq,frequency.peak_freq];

clc;
clear;
x=[];y=[];
for i=1:9
    mat_form = ['A0',num2str(i),'T.mat'];
    gdf_form = ['A0',num2str(i),'T.gdf'];
    load(mat_form);
    xtmp = [all_features.time.kurtosis,all_features.time.mean,all_features.time.median,all_features.time.skewness,all_features.time.var,all_features.time.zc,all_features.frequency.mean_freq,all_features.frequency.median_freq,all_features.frequency.peak_freq,reshape(all_features.frequency.bandpower,288,110)];
    x = [x;xtmp];

    [a,b] = sload(gdf_form);
    y = [y;b.Classlabel];
end
n = size(x,1);
train_index = floor(0.9*n);
xval = x(train_index+1:n,:);xtr = x(1:train_index,:);yval = y(train_index+1:n,:);ytr = y(1:train_index,:);

T=1e5;
k = 4;
for pow = -5:1:7
lambda = 2^pow;

[W] = train_svm_mhinge_sgd(xtr, ytr, k, lambda, T);
ypred = test_svm_multi(W, xtr);
train_err = mean(ypred~=ytr);

ypred = test_svm_multi(W, xval);
val_err = mean(ypred~=yval);
fprintf('When lambda = %f, train error = %f, validation error = %f\n',lambda, train_err, val_err);
end