function result = scaling(image, layer)
    % Summary: rescales the images in terms of dimensions and color scale 
    % (color scale of the image changes to gray scale) 
    
    % read the image
    if isstring(layer) == true
        layer_color = imread(layer); 

        % gray scale the image
        if contains(layer, ".tif") == false 
            layer_color = rgb2gray(layer_color); 
        end
    else 
        layer_color = layer; 
    end
    if isstring(image) == true
        image_color = imread(image); 

        % gray scale the image
        if contains(image, ".tif") == false 
            image_color = rgb2gray(image_color); 
        end
    else 
        image_color = image; 
    end

    % rescale the image
    if size(layer_color) ~= size(image_color) 
        result = imresize(layer_color, size(image_color));
    else
        result = layer_color; 
    end

end