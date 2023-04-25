function [center, lambda, V] = centered_pca(X) 
[m,d] = size(X);

% normalization
for i = 1:d
    xnor = X(:,i);
    if std(xnor) ~= 0
        xnor = (xnor-mean(xnor))/std(xnor);
    end
    X(:,i) = xnor;
end

% covariance
% var = zeros(d);
% for i = 1:d
%     for j = i:d
%         var(i,j) = X(:,i)'*X(:,j)/(m-1);
%         var(j,i) = var(i,j);
%     end
% end

% covariance
cov = X'*X/(m-1);

% eigenvalue and eigenvector
% lambda = zeros(1,d);
[V, eigenvalue] = eig(cov);
% for i = 1:d
%     lambda(i) = eigenvalue(i,i);
% end
lambda = diag(eigenvalue);
lambda = lambda(length(lambda):-1:1);
V = V(:,size(V,2):-1:1);

% find the max 90% contribution
% total_lambda = 0;
% lambda_limit = sum(lambda)*0.90;
% for i = 1:d
%     total_lambda = total_lambda + lambda(i);
%     if total_lambda > lambda_limit
%         lambda = lambda(1:i);
%         V = V(:,1:i);
%         break;
%     end
% end

% principal
feature_map = X*V;

center = (V*feature_map')';