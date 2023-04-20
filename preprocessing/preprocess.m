clear;
clc;

paths = dir('../BCICIV_2a_gdf/*.gdf');

for i=1:size(paths,1)
    disp(paths(i).name);
    data = resample(strcat('../BCICIV_2a_gdf/', paths(i).name));
    data = ReplaceNans(data);
    data = CenterData(data);
    data = BandPass(data);
    data = FormatData(data);
    name = split(paths(i).name, '.');
    name = name{1};
    name = strcat('data/', name, '.mat');
    save(name, "data");
end

function [output] = BandPass(data)
    fs = 250;
    output = bandpass(data, [8 30], fs);
end

function [output] = LaplacianFilter(data)
    c3_vecinos = [data(:, 2) data(:, 7) ...
        data(:, 9) data(:, 14)];
    c4_vecinos = [data(:, 6) data(:, 11) ...
        data(:, 13) data(:, 18)];
    
    c3_laplace = data(:, 8) - mean(c3_vecinos, 2);
    c4_laplace = data(:, 12) - mean(c4_vecinos, 2);
    
    output = [c3_laplace c4_laplace];
end

function [output] = CenterData(data)
    avg = mean(data, 2);
    output = data - avg;
end

function [output] = ReplaceNans(data)
    output = zeros(size(data));
    contador = 1;
    n_muestras_nan = 0;
    for i=1:288
        muestra = data(contador:contador+999,:);
        % si hay un NaN
        if sum(sum(isnan(muestra))) > 0
            % filtro mediana
            y = medfilt1(muestra,255,'omitnan');
   
            % reemplazar NaN por los valores del filtro mediana
            muestra(isnan(muestra)) = y(isnan(muestra));
            output(contador:contador+999, :) = muestra;
            n_muestras_nan = n_muestras_nan + 1;
        else
            output(contador:contador+999, :) = data(contador:contador+999, :);
        end
        contador = contador + 1000;
    end    
end

function [output] = resample(pathname)
    % load data
    [s, h] = sload(pathname); 
    
    numsec = 4;

    % allocate output array
    output = zeros(288*250*numsec, 22);
    
    for columna=1:22 % 22 eeg channels
	    contador = 1;
        for i=1:288 % 288 samples
            %s(2seg : 6seg, numColumna)
            output(contador:contador+999, columna) = s(h.TRIG(i)+500 : h.TRIG(i)+1499, columna);
            contador = contador + 1000;
        end
    end
end

function [output] = FormatData(data)
    output = zeros(288,22000);
    contador2 = 1;
    
    for i=1:288
        contador1=1;
        for j=1:22
            output(i, contador1:contador1+999)...
                = data(contador2:contador2+999, j);
            contador1 = contador1 + 1000;
        end
        contador2 = contador2 + 1000;
    end
end

function [output] = FormatLaplace(data)
    output = zeros(288,2000);
    contador2 = 1;
    
    for i=1:288
        contador1=1;
        for j=1:2
            output(i, contador1:contador1+999)...
                = data(contador2:contador2+999, j);
            contador1 = contador1 + 1000;
        end
        contador2 = contador2 + 1000;
    end
end