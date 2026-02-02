function weight = Gabor_weight(img)
    [img_row, img_col] = size(img);
    raw_img = img;
    se = fspecial('gaussian', 3);
    img = imfilter(img, se);
    se1 = [0,-1,0;-1,5,-1;0,-1,0];
    img = imfilter(img, se1);
    wavelate = [2, 3, 4, 5];
    orientation = [0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5];
    abandon_num = 0;
    combanition_num = length(wavelate) * (length(orientation) - abandon_num);
    magarray = zeros(img_row, img_col, combanition_num);
    for i = 1: length(wavelate)
        temparray = zeros(img_row, img_col, 4);
        for j = 1: length(orientation)
           [mag, ~] = imgaborfilt(img, wavelate(i), orientation(j));
           temparray(:, :, j) = max(mag, 0);
        end
        a = sort(temparray, 3, 'descend');
        a(:, :, 1 : abandon_num) = [];
        magarray(:, :, (i-1)*(length(orientation) - abandon_num)+1: i*(length(orientation) - abandon_num)) = a;
    end
    magarraytemp(:,:,1) = min(magarray(:,:,1:8), [], 3);
    magarraytemp(:,:,2) = min(magarray(:,:,9:16), [], 3);
    magarraytemp(:,:,3) = min(magarray(:,:,17:24), [], 3);
    magmean = mean(magarraytemp,  3); 
    magmean = magmean/max(max(magmean));

    ximg = padarray(raw_img, [1, 0], 'replicate', 'post');
    yimg = padarray(raw_img, [0, 1], 'replicate', 'post');
    Gradx = diff(ximg, 1, 1);
    Grady = diff(yimg, 1, 2);
    Grad_img = sqrt(Gradx.^2 + Grady.^2);
    Grad_img = ordfilt2(Grad_img, 5, [0,1,0;1,1,1;0,1,0]);
    Grad_img = imerode(Grad_img, [1,1;1,1]);


    weight = Grad_img .* magmean;
    weight = weight/max(max(weight));
end