% Load the training data and labels
load('training.mat');
load('training_labels.mat');

% check for features path
if ~exist('./features', 'dir')
       mkdir('./features')
end

% Extract features
time_features = extract_time_features(training);
freq_features = extract_frequency_features(training);
tf_features = extract_time_frequency_features(training);

% Combine features into one struct
all_features = struct;
all_features.time = time_features;
all_features.frequency = freq_features;
all_features.time_frequency = tf_features;

% Save the combined features
save('features/training_features.mat', "all_features");

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

function [freq_features] = extract_frequency_features(X)
    freq_features = struct;
    
    m = size(X, 1);
    C = 22;
    s = 1000;
    
    X_prime = reshape(X, m, s, C);
    
    freq_features.peak_freq = zeros(m, 1, C);
    freq_features.mean_freq = zeros(m, 1, C);
    freq_features.median_freq = zeros(m, 1, C);
    freq_features.bandpower = zeros(m, 5, C);
    
    for i = 1:m
        for j = 1:C
            [pxx, f] = pwelch(X_prime(i, :, j), [], [], [], s);
            
            [~, idx] = max(pxx);
            freq_features.peak_freq(i, 1, j) = f(idx);
            freq_features.mean_freq(i, 1, j) = sum(pxx .* f) / sum(pxx);
            freq_features.median_freq(i, 1, j) = f(find(cumsum(pxx) >= sum(pxx) / 2, 1));
            
            freq_bands = [1 4; 4 8; 8 12; 12 30; 30 100]; % Modify these frequency bands as needed
            for k = 1:size(freq_bands, 1)
                freq_features.bandpower(i, k, j) = bandpower(pxx, f, freq_bands(k, :), 'psd');
            end
        end
    end
    
    freq_features.peak_freq = squeeze(freq_features.peak_freq);
    freq_features.mean_freq = squeeze(freq_features.mean_freq);
    freq_features.median_freq = squeeze(freq_features.median_freq);
end



%{
TODO: time-frequency features
%}

function [tf_features] = extract_time_frequency_features(X)
    tf_features = struct;

    m = size(X, 1);
    C = 22;
    s = 1000;

    X_prime = reshape(X, m, s, C);

    window_len = 100; % You can adjust this value based on your requirements
    overlap_len = 50; % You can adjust this value based on your requirements
    nfft = 256; % You can adjust this value based on your requirements

    tf_features.stft = zeros(m, nfft/2 + 1, C);

    for i = 1:m
        for j = 1:C
            [sxx, ~, ~] = spectrogram(X_prime(i, :, j), window_len, overlap_len, nfft, s);
            tf_features.stft(i, :, j) = mean(abs(sxx), 2);
        end
    end

    tf_features.stft = squeeze(tf_features.stft);
end


%{
TODO: spatial features
%}
