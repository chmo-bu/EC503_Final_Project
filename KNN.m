clc;clear;
load('data.mat');

for i = 1:size(x,2)
    xnor = x(:,i);
    if std(xnor) ~= 0
        xnor = (xnor-mean(xnor))/std(xnor);
    end
    x(:,i) = xnor;
end

n = size(x,1);
train_size = floor(0.9*n);
xtr = x(1:train_size,:);
xval = x(train_size+1:n,:);
ytr = y(1:train_size,:);
yval = y(train_size+1:n,:);

Test_range = 1:20;
err = [];
for k = Test_range
    ypred = [];
    for i = 1:size(xval,1)
        len = [];
        for j = 1:size(xtr,1)
            len = [len;norm(xtr(j)-xval(i))];
        end
        rec = [0,0,0,0];
        for l = 1:k
            ind = find(len==min(len));
            rec(ytr(ind)) = rec(ytr(ind))+1;
            len(ind) = Inf;
        end
        if size(find(rec==max(rec)),2) == 1
            ypred = [ypred;find(rec==max(rec))];
        else
            fd = find(rec==max(rec));
            ypred = [ypred;fd(unidrnd(size(fd,2)))];
        end
    end
    err = [err,mean(ypred~=yval)];
end
plot(Test_range,err);