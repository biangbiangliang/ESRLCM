function mask = genCircle(radius)
    mask_size = 2 * radius + 1;
    [r, c] = meshgrid(1 : mask_size);           
    center = (radius + 1) * ones(mask_size, mask_size);
    mask_temp = round(sqrt((r - center).^2 + (c - center).^2));    
    mask = mask_temp == radius;
end
