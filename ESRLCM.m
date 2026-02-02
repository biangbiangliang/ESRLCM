function out = ESRLCM(img)
%% Information of Related Articles
% Infrared small target detection based on ring local contrast measure with edge suppression
% Liang Hu; Degui Yang; Dangjun Zhao; Wing Wang
    [img_row, img_col] = size(img);
    win_size = [1,2,3,4];
    LDMarray = zeros(img_row, img_col, length(win_size));
    LDMRd = zeros(img_row, img_col, length(win_size) - 1);
    LDM_B_MAX = zeros(img_row, img_col, length(win_size) - 1);
    for i = 1: length(win_size)
       if i == 1
          mask = ones(3,3);
          temp1 = ordfilt2(img, 9, mask);
          temp2 = ordfilt2(img, 8, mask);
          temp3 = ordfilt2(img, 7, mask);
          temp4 = ordfilt2(img, 6, mask);
          temp5 = ordfilt2(img, 5, mask);
          temp = (4*temp1 + 2*temp2 + 2*temp3 + 1*temp4 + 1*temp5)/10;
       else
           mask = genCircle(win_size(i));
           mask_nonzero_num = sum(sum(mask ~= 0));
           mask_max = ordfilt2(img, mask_nonzero_num, mask);
           mask_min = ordfilt2(img, 1, mask);
           mask_mean = imfilter(img, mask/mask_nonzero_num);

           mask_Rd = max(mask_max - mask_mean, mask_mean - mask_min)./mask_max;
           LDMRd(:, :, i - 1) = mask_Rd;
           LDM_B_MAX = mask_max;
       end
       LDMarray(:, :, i) = temp;   
    end
    LDMRd_max = repmat(max(LDMRd, [], 3), 1, 1, length(win_size) - 1);
    LDMRd_index = LDMRd == LDMRd_max;
    BEarray = LDMRd_index .* LDM_B_MAX;
    BE = max(BEarray, [], 3);
    LDM = LDMarray(:, :, 1) .* max(0, ((LDMarray(:, :, 1) ./ (BE)) - 1)) .* exp(-(max(LDMRd, [], 3)/255));
    weight = my_Gabor_weight(img);
    out = LDM.*weight;
    out_max = max(out(:));
    out_mean = mean(out(:));
    Th = 0.15*out_max + 0.85*out_mean;
    out(out<Th) = 0;
end