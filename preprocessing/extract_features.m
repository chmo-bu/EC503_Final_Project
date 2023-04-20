load data/A01T.mat;

% get directories with '.gdf' files
%paths = dir('../BCICIV_2a_gdf/*.gdf');
paths = dir('data/*.mat');

% for each set preprocess data
for i=1:size(paths,1)
    disp(paths(i).name);
    name = split(paths(i).name, '.');
    name = name{1};
    name = strcat('time_features/', name, '.mat');
    load(strcat('data/', paths(i).name));
    data = extract_time_features(data);
    save(name, "data");
end

%res = extract_time_features(data);

%{
TODO: time-domain features
%}
function [features] = extract_time_features(X)
    features = struct;

    % [m, C*s]
    m = size(X, 1);
    C = 22;
    s = 1000;

    % reshape samples
    X_prime = reshape(X, m, s, C);

    features.mean = squeeze(mean(X_prime, 2));
    features.median = squeeze(median(X_prime, 2));
    features.var = squeeze(var(X_prime, [], 2));
    features.kurtosis = squeeze(kurtosis(X_prime, [], 2));
    features.skewness = squeeze(skewness(X_prime, [], 2));
    features.zc = zeros(m, 1, C);
    features.ac = zeros(m, s, C);

    for i=1:m
        for j=1:22
            [acf, ~] = autocorr(X_prime(i, :, j), 'NumLags', s-1);
            features.ac(i, :, j) = acf;
            features.zc(i, 1, j) = zerocrossrate(X_prime(i, :, j));
        end
    end

    features.zc = squeeze(features.zc);
    features.ac = reshape(features.ac, m, C*s);

    % output size [m, # seconds]
end

%{
TODO: frequency-domain features
%}

%{
TODO: time-frequency features
%}

%{
TODO: spatial features
%}