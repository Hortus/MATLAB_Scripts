% By Alexander Q. Susko. 
%Please cite: Susko, A. Q. 2016.  Phenotypic and Genetic Variation for 
%Rhizosphere Acidification, a Candidate Trait for pH Adaptability, in 
%Deciduous Azalea (Rhododendron sect. Pentanthera), Chapter 3. MS Thesis,
%University of Minnesota Twin-Cities.

%Portions (lines 23-100) of this script are modifications of a publicly availble demo https://www.mathworks.com/matlabcentral/fileexchange/28512-simplecolordetectionbyhue-- (Copyright (c) 2015, Image Analyst 
% Copyright (c) 2010, Image Analyst All rights reserved).

%This script will output seedling area, ratio of green to red pixels from
%images of seedlings based on hue, saturation and value.  Areas where
%customization (ie finding the appropriate hue thresholds) are noted as
%this script is optimized for the detection of azalea seedlings only.  

%Individually load files from current directory
imagefiles = dir('*.jpg');
filenames = {imagefiles.name};
nfiles = length(imagefiles);% Number of files found
fid = fopen('SeedlingDetection.csv','wt');

%waitbar to show progress
h = waitbar(0,'Iterating through images');

%for loop to analyze each image with .jpg extension in current directory.
%This will report seedling area as well as a ratio of green to red pixels
%in the seedling.  Output is a comma separated (csv) file.  

for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   [rgbImage storedColorMap] = imread(currentfilename);
   

% Read in image into an array.
   %[rgbImage storedColorMap] = imread(fullImageFileName); 
   [rows columns numberOfColorBands] = size(rgbImage); 
% If it's monochrome (indexed), convert it to color. 
% Check to see if it's an 8-bit image needed later for scaling).
    if strcmpi(class(rgbImage), 'uint8')
		% Flag for 256 gray levels.
		eightBit = true;
    else
        eightBit = false;
	end
	if numberOfColorBands == 1
		if isempty(storedColorMap)
			% Just a simple gray level image, not indexed with a stored color map.
			% Create a 3D true color image where we copy the monochrome image into all 3 (R, G, & B) color planes.
			rgbImage = cat(3, rgbImage, rgbImage, rgbImage);
		else
			% It's an indexed image.
			rgbImage = ind2rgb(rgbImage, storedColorMap);
			% ind2rgb() will convert it to double and normalize it to the range 0-1.
			% Convert back to uint8 in the range 0-255, if needed.
			if eightBit
				rgbImage = uint8(255 * rgbImage);
			end
		end
    end 
    
% Convert RGB image to HSV
	hsvImage = rgb2hsv(rgbImage);
	% Extract out the H, S, and V images individually
	hImage = hsvImage(:,:,1);
	sImage = hsvImage(:,:,2);
	vImage = hsvImage(:,:,3);
 
%Assign thresholds for hue, saturation, and value for image.  This step
%will require custumization according to seedling foliage and media color.
    hueThresholdLow = 0.15;
    hueThresholdHigh = 0.90;
    saturationThresholdLow = 0;
    saturationThresholdHigh = 1.0;
    valueThresholdLow = 0.40;
    valueThresholdHigh = 1.0;
    
% Now apply each color band's particular thresholds to the color band
	hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
	saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
	valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);
    
% Then we will have the mask of only the specified parts of the image.
	ObjectsMask = uint8(hueMask & saturationMask & valueMask);
    
% filter out small objects.
	smallestAcceptableArea = 2000; % Keep areas only if they're bigger than this. This will require customization depending on your seedling size
    
% Get rid of small objects.  Note: bwareaopen returns a logical.
	ObjectsMask = uint8(bwareaopen(ObjectsMask, smallestAcceptableArea));

% Smooth the border using a morphological closing operation, imclose().
    structuringElement = strel('disk', 4);
	ObjectsMask = imclose(ObjectsMask, structuringElement);
    
% Fill in any holes in the regions, since they are most likely red also.
	ObjectsMask = uint8(imfill(ObjectsMask, 'holes'));
    
% You can only multiply integers if they are of the same type.
	% (yellowObjectsMask is a logical array.)
	% We need to convert the type of ObjectsMask to the same data type as hImage.
	ObjectsMask = cast(ObjectsMask, class(rgbImage)); 
    
% Use the object mask to mask out the specified-only portions of the rgb image.
	maskedImageR = ObjectsMask .* rgbImage(:,:,1);
	maskedImageG = ObjectsMask .* rgbImage(:,:,2);
	maskedImageB = ObjectsMask .* rgbImage(:,:,3);
    
% Concatenate the masked color bands to form the rgb image.
	maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
    
% Measure the mean HSV and area of all the detected blobs. From function
% defined in demo script. Not a function here
    [labeledImage numberOfBlobs] = bwlabel(ObjectsMask, 8);     % Label each blob so we can make measurements of it
	if numberOfBlobs == 0
		% Didn't detect any  seedlings in this image.
        meanHSV = [0 0 0];
		areas = 0;
        
        SeedlingSA = 0;
        greenredratio = 0 ;
        
        %Print 0s for seedling surface area, green red ratio
        fprintf(fid,[filenames{ii},',',num2str(SeedlingSA),',',num2str(greenredratio),'\r\n']); 
        
	
    else %Seedling was detected in image
        
	% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
	blobMeasurementsHue = regionprops(labeledImage, hImage, 'area', 'MeanIntensity');   
	blobMeasurementsSat = regionprops(labeledImage, sImage, 'area', 'MeanIntensity');   
	blobMeasurementsValue = regionprops(labeledImage, vImage, 'area', 'MeanIntensity');   
	
	meanHSV = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	meanHSV(:,1) = [blobMeasurementsHue.MeanIntensity]';
	meanHSV(:,2) = [blobMeasurementsSat.MeanIntensity]';
	meanHSV(:,3) = [blobMeasurementsValue.MeanIntensity]';
	
	% Now assign the areas.
	areas = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	areas(:,1) = [blobMeasurementsHue.Area]';
	areas(:,2) = [blobMeasurementsSat.Area]';
	areas(:,3) = [blobMeasurementsValue.Area]';
    
    %attempt to calculate hues in the area determined by values
    %blobmeasurementsHue
    
    %meanHSV(:,3) = [blobMeasurementsValue.MeanIntensity]'
    %concactenate masked R,G,B images
    maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
	% Show the masked off, original image.
	imshow(maskedRGBImage);
    
    %mean hue of masked image
    meanhues(ii) = mean(meanHSV(:,1))';
    meanhues(ii);
    
    %write masked image to JPEG
    imwrite(maskedRGBImage,'masked.jpeg');
    
    %%%Analyze hue ratios in the masked image.  File is re-written every
    %%%time
    
    %read in masked image
    imageMasked = imread('masked.jpeg');
    %[rgbImage storedColorMap] = imread('masked.jpeg');

    %convert to hsv
    hsvImageMasked = rgb2hsv(imageMasked);

    %extract the hue, sat, and value images
    hImageMasked = hsvImageMasked(:,:,1);

    %histogram of hue image.  Stores counts, bin locations within a numeric
    %array
    [counts,binLocations] = imhist(hImageMasked,200);

    imCounts = [counts];
    
    %calculate total seedling area from [counts], by summing all pixels
    %across bins 15-100.  These bins constitute green tissue.  This will
    %vary depending on species you are imaging.
    
    seedlingSubset = imCounts(15:100);
    seedlingPixelArea = sum(seedlingSubset);
    
    %Conversion factor, based on 12cm = 1638 pixels (plastic flat) from
    %2144x1424 resolution image.  This will require customization depending
    %on your camera
    
    conversionPix2Cm3 = ((12^2)/(1638^2));
    SeedlingSurfaceArea = seedlingPixelArea*conversionPix2Cm3;

    %Note: I used a small section of an ideal green color in a rhododendron
    %leaf to determine the best green range for creating a ratio to the other
    %colors in the leaf.  The ideal color takes up bins 58-65, when n(bins) =
    %200 in imhist, or centered around hue=0.3

    %Green subset, from imhist bins
    greenSubset = imCounts(55:65);

    %Note: I used a small section of a reddening leaf to show the peak for the
    %stressed phenotype.  Not necessarily chlorosis.  In small section,this hue
    %takes up bins 38-53, when n(bins) = 200 in imhist, or centered around
    %hue=0.22

    %Red subset, from imhist bins
    redSubset = imCounts(30:50);
    
    %Ratio of green to red
    greenRedRatio = ((sum(greenSubset))/(sum(redSubset)));
    
    %Write SeedlingSurfaceArea,greenRedRatio to excel file.  Data will
    %appear in this column order
    
    fprintf(fid,[filenames{ii},',',num2str(SeedlingSurfaceArea),',',num2str(greenRedRatio),'\r\n']);
    
    end
   
    waitbar(ii/nfiles)

end

close(h);
fclose(fid);
