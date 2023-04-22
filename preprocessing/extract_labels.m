% get directories with '.gdf' files
paths = dir('../BCICIV_2a_gdf/*.gdf');

% check for features path
if ~exist('./labels', 'dir')
       mkdir('./labels')
end

% for each set extract the labels
for i=1:size(paths,1)
    disp(paths(i).name);
    name = split(paths(i).name, '.');
    name = name{1};
    name = strcat('labels/', name, '.mat');
    [s, h] = sload(strcat('../BCICIV_2a_gdf/', paths(i).name));
    labels = h.Classlabel;
    
    % Save the combined features
    save(name, "labels");
end