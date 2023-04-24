function [ypred] = test_svm_multi(W, Xte)
ypred = zeros(size(Xte,1),1);
for i = 1:size(Xte,1)
    wx = W*Xte(i,:)';
    index = find(wx == max(wx));
    ypred(i) = index(1);
end
end