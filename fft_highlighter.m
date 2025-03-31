%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose: The fft_highlighter algorithm is used to detect joint
% sets space using MATLAB's fft2/ifft2 functions. The user will either
% manually input images in two ways: choosing certain layers of pixel intensities  
% present in the DEM image by selecting the 'Files' option or clicking on
% the 'Choose 3 Colors' option so the user can utilize the colorpicker 
% function in order to choose only 3 pixel intensities present in the image. The
% last option of the GUI menu, 'Auto-Detect', while automatically detect
% the colors that are present in the joint sets. All three options will
% use the chosen pixel intensities layers and the image of the DEM data, apply fft2
% onto each of them, find the difference between each layer and the DEM
% image, and finally add all of the differences together into one binary
% mask that could then be used as an overlay binary mask for the DEM data
% image. The images can be in the following format: .png .jpg .jpeg .tif

% Functions:
% scaling(DEM_image, color_layer) - this function reads the DEM image and 
% has the color layer image rescaled into the DEM image's dimensions. 
% 
% colorpicker - gets RGB values from mouse clicking regions of the image
% that was given in the script. More information can be found here:
% https://www.mathworks.com/matlabcentral/fileexchange/53656-colorpicker


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reading/Create the images

% read the dem_image
dem_image = "bunch_shapes.png"; 
% dem_image = "small_portion_PSD.png";
% dem_image = "grabensPNG3.png"; 
% dem_image = "grabensLargePNG.PNG"; 

% GUI menu 
list = {'Choose 3 Colors', 'Files', 'Auto-detect'};
[indx,tf] = listdlg('ListString',list);

% if the user wants to choose 3 colors
if indx == 1

    % scales the image
    I_dem = scaling(dem_image,dem_image); 
    figure;imshow(I_dem)
    % activates the colorpicker function
    listRGB = colorpicker('fontweight','bold','color','r'); 
    
    % lists out the three chosen colors from the image
    rgb1 = listRGB(1,:); 
    rgb2 = listRGB(2,:); 
    rgb3 = listRGB(3,:); 
    
    % puts the colors in a matrix filled with ones (scales it from 0-256)
    color1 = ones(size(I_dem)) * rgb1(1) * 256;
    color2 = ones(size(I_dem)) * rgb2(1) * 256; 
    color3 = ones(size(I_dem)) * rgb3(1) * 256; 
    
    % scales the matrices according to the dimensions of the chosen image
    I = scaling(dem_image, color1); 
    I2 = scaling(dem_image, color2); 
    I3 = scaling(dem_image, color3); 

    % converts the matrix from double to uint8
    I = cast(I, 'uint8'); 
    I2 = cast(I2, 'uint8'); 
    I3 = cast(I3, 'uint8'); 

% if the user wants to choose the three default colors 
elseif indx == 2

    % reads the images with the three separate colors
    % THE FILES CAN BE CHANGED
    color1 = "layer_white.png";
    color2 = "layer_gray.png"; 
    color3 = "layer_dark_gray.png"; 

    % scales the matrices and the image
    I_dem = scaling(dem_image,dem_image);
    I = scaling(dem_image, color1); 
    I2 = scaling(dem_image, color2); 
    I3 = scaling(dem_image, color3); 

% if the user wants the program to choose the colors automatically
elseif indx == 3 
    % The number of most common colors in an image
    N = 25; 
    I_dem = scaling(dem_image,dem_image);

    % converts the image to double
    rgbValues = cast(I_dem, 'double'); 
    emptyArray = zeros(1,N); 

    % finds the most common colors
    for i = 1:N
        emptyArray(i) = mode(rgbValues, "all"); 
        rgbValues(rgbValues == emptyArray(i)) = NaN; 
    end
     
    % finds the max, min, and mean RGB values of the image
    commonRGB = zeros(1,3);
    commonRGB(1) = max(emptyArray,[],"all");
    commonRGB(2) = interp1(emptyArray,emptyArray,mean(emptyArray),'nearest');
    commonRGB(3) = min(emptyArray,[],"all"); 

    % makes grids for these colors
    color1 = zeros(size(I_dem)) + commonRGB(1);
    color2 = zeros(size(I_dem)) + commonRGB(2); 
    color3 = zeros(size(I_dem)) + commonRGB(3); 
    
    % converts the matrices of the grids 
    I = cast(color1,'uint8'); 
    I2 = cast(color2,'uint8');
    I3 = cast(color3,'uint8'); 

else 
    % the user can NOT choose all three options at the same time 
    error('Please choose only <strong>ONE</strong> option in the list.')

end

% display the images 
figure(1)
subplot(2,2,1)
% checking to see if the DEM is a string
if isstring(dem_image) == true 
    % If .tif file 
    if contains(dem_image, ".tif") == true
        imagesc(I_dem)
    else 
        imshow(I_dem)
    end
else 
    imshow(I_dem)
end
% evenly aligns the data aspect ratio
daspect([1 1 1]);
title('Image of DEM')

subplot(2,2,2)
if isstring(color1) == true 
    if contains(color1, ".tif") == true
        imagesc(I)
    else 
        imshow(I)
    end
else 
    imshow(I)
end
daspect([1 1 1]);
title('Image 1')

subplot(2,2,3) 
if isstring(color2) == true 
    if contains(color2, ".tif") == true
        imagesc(I2)
    else 
        imshow(I2)
    end
else 
    imshow(I2)
end
daspect([1 1 1]);
title('Image 2') 

subplot(2,2,4)
if isstring(color3) == true 
    if contains(color3, ".tif") == true
        imagesc(I3)
    else 
        imshow(I3)
    end
else 
    imshow(I3)
end
daspect([1 1 1]);
title('Image 3')


%% Subtracting the orignal image's ft with its scaled-down image's ft

% takes the fast fourier transformation of the images and color grids
frequencyImage = fft2(I); 
frequencyImage2 = fft2(I_dem); 
frequencyImage3 = fft2(I2); 
frequencyImage4 = fft2(I3); 

figure(2)
subplot(2,2,1)
imshow(frequencyImage)
title('Fourier Transform Image 1')
daspect([1 1 1]);
subplot(2,2,2)
imshow(frequencyImage2)
title('Fourier Transform Image 2')
daspect([1 1 1]);
subplot(2,2,3)
imshow(frequencyImage3) 
title('Fourier Transform Image 3') 
daspect([1 1 1]);
subplot(2,2,4) 
imshow(frequencyImage4)
title('Fourier Transform Image 4') 
daspect([1 1 1]);

% find the difference between the two amplitudes of the images 
diffFrequency1 = frequencyImage - frequencyImage2;
diffFrequency2 = frequencyImage3 - frequencyImage2; 
diffFrequency3 = frequencyImage4 - frequencyImage2; 

figure(3) 
subplot(2,3,1)
imshow(diffFrequency1)
title('Image 1 - Image 2')
daspect([1 1 1]);
subplot(2,3,2)
imshow(diffFrequency2)
title('Image 3 - Image 2')
daspect([1 1 1]);
subplot(2,3,3)
imshow(diffFrequency3)
title("Image 4 - Image 2") 
daspect([1 1 1]);

%% Shows the inverse fft2 of the difference between each image's fft2, as well as the sum of each mask 

% inverse fft2 of each difference frequency
mask1 = ifft2(diffFrequency1);
mask2 = ifft2(diffFrequency2); 
mask3 = ifft2(diffFrequency3); 

subplot(2,3,4)
imshow(mask1)
title('Mask 1') 
subplot(2,3,5) 
imshow(mask2) 
title('Mask 2') 
subplot(2,3,6) 
imshow(mask3)
title('Mask 3') 

% the sum of each mask 
finalMask = mask1 + mask2 + mask3; 

figure(5) 
imshow(finalMask) 
title('Result') 

% lays over a low-opaque binary layer over the DEM image
figure(6)
imshow(labeloverlay(I_dem,imbinarize(finalMask)))
title('Mask Over Original Image')

finalMask = cast(finalMask,'uint8');
figure(7) 
result = I_dem + finalMask;
imshow(result)
colormap('gray')