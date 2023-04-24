function [W] = train_svm_mhinge_sgd(Xtr, ytr, k, lambda, T)
[m,d] = size(Xtr); % m train size, d train dimension
W = zeros(k,d);
for t = 1:T
    index = unidrnd(m);
    w = W;
    w(ytr(index),:) = [];
    loss = max([1+max(w*Xtr(index,:)')-W(ytr(index),:)*Xtr(index,:)',0]);
    g = zeros(k,d);
    if loss > 0
        wx = w*Xtr(index,:)';
        findex = find(wx==max(wx));
        if findex(1) >= ytr(index)
            findex(1) = findex(1) + 1;
        end
        g(findex(1),:) = Xtr(index,:);
        g(ytr(index),:) = -Xtr(index,:);
    end
    lr = 1/lambda/t;
    W = W - lr*(lambda*W + g);
end