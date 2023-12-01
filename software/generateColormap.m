% a function that generates a colormap based on the min and max values of
% the data
% input: lim, a 1x2 array of the min and max values of the data
% output: cmap_vals, a nx3 array of the rgb values of the colormap
%         where n is the number of colors in the colormap
%         green is the middle color, red is the high color, purple is the
%         low color


function cmap_vals = generateColormap(lim, cmap_distribution)
cmap_vals = [];
RED = 630;
PURPLE = 410;
MID = (RED + PURPLE) / 2;
resolution = (RED - PURPLE);
% three cases: min < 0 < max, min < max < 0, 0 < min < max
% case 1: min < 0 <= max
if lim(1) < 0 && lim(2) >= 0
    % generate two halfmaps
    posmap_res = resolution * lim(2) / (lim(2) - lim(1));
    negmap_res = resolution * lim(1) / (lim(1) - lim(2));
    posmap = generateHalfColormap([PURPLE, RED], [MID, RED], posmap_res, cmap_distribution);
    negmap = generateHalfColormap([PURPLE, RED], [PURPLE, MID], negmap_res, cmap_distribution);
    % combine them
    cmap_vals = [negmap; posmap];

% case 2: min < max <= 0
elseif lim(1) < lim(2) && lim(2) <= 0
    % generate one halfmap
    negmap_res = resolution;
    negmap = generateHalfColormap([PURPLE, RED], [PURPLE, RED], negmap_res, cmap_distribution);
    cmap_vals = negmap;

% case 3: 0 <= min < max
elseif 0 <= lim(1) && lim(1) < lim(2)
    % generate one halfmap
    posmap_res = resolution;
    posmap = generateHalfColormap([PURPLE, RED], [MID, RED], posmap_res, cmap_distribution);
    cmap_vals = posmap;
end
end

function halfmap_vals = generateHalfColormap(freq_range, val_range, half_res, cmap_dist)
    distribution = -1 * cmap_dist;
    halfmap_vals = [];
    x = val_range(1);
    while x < val_range(2)
        curved_x = (freq_range(2) - freq_range(1)) / (1 + exp(distribution * (x - (freq_range(2) + freq_range(1))/2))) + freq_range(1);
        halfmap_vals = [halfmap_vals; wavelengthToRGB(curved_x)];
        x = x + (val_range(2) - val_range(1)) / half_res;
    end
end