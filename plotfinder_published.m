%% Plotfinder Matlab script
%Quantifying crop Movement outdoors through Hemispherical Video Analysis of Agricultural Plots
%Script by Alexander Susko

%script to read in image, field plot dimensions, field plot design, and
%output images of the plots from a hemispherical image or video. Contains
%advanced roll and pitch correction

%% Section 1: Image thresholding to ID red square

%read in first frame tiff image
image = imread('frame1.tif');
%set panel number
panelnum = 5;


%mask to get the red QR squares in the image using the LAB mask
%redsquare = wave1_redmask(image);
redsquare = redmask(image);

%find square structuring elements in the mask.  4 pixel square structuring
%element
sesquare = strel('square', 4);
redstrel = imopen(redsquare, sesquare);

%Pull out red structuring element in the middle of image. Check these
%carefully, might do it by area instead.
redstrel(:,(1:1200))=0;
redstrel(:,(1600:2880))=0;

%% Section 2: Get the indices from red square to calculate rotation angle
%Determine rotation based on x axis (NS) from the inverse tan of the length
%of column indices over the length of row indices

%get the center col index (x axis), center row axis (y axis) so that the
%origin (center of image) can be defined
%size = size(image);
x = size(image,2)/2;
y = size(image,2)/2;
origin = [x y];

%find row (x) and column (y) indices where 0 exists.  
[redRowIndices, redColIndices] = find(redstrel ~= 0);
redColIndices = unique(redColIndices);
redRowIndices = unique(redRowIndices);

%get the min col index (left most point of red square in image), extract all row indices in
%the col that are nonzero, and find the max row index. This is the leftmost
%corner of the square
leftCornerCol = min(redColIndices); 
leftCornerRow = min(find(redstrel(:,leftCornerCol) ~= 0 )); %get min row index within leftmost column

%% Section 3: Identify direction of rotation from red QR square

%create a new image that just contains this one column, all rows and
%channels.  White square has lightness value greater than 95
I = image(:,leftCornerCol,1);

%conditional statements for position of the white block relative to the red
%leftmost corner

%QR code "facing" indicates direction pointed to by the edge of the red
%square

%Camera axis rotating southward from west.  QR could be above or below left
%most corner.  Only look at 10 pixels as area covered will be smaller.
if mean(I((leftCornerRow-40):(leftCornerRow))) > 245 && mean(I(leftCornerRow:(leftCornerRow+40))) > 245
    %thetaOffset
    minRow = min(redRowIndices);
    maxColminRow = max(find(redstrel(minRow,:) ~= 0 )); 
    length = leftCornerRow - minRow; 
    overhang = maxColminRow - leftCornerCol;
    thetaOffset = atand(overhang/length);
    
    %center offset
    halfHyp = round(sqrt(overhang^2 + length^2)/2,0);
    centerCol = round((halfHyp*sind(90-thetaOffset))/2*sind(90),0);
    centerRow = round((halfHyp*sind((180-(90-thetaOffset)-90))/2*sind(90)),0);
    qrCenterRow = maxRow-centerRow;
    qrCenterCol = maxColminRow-centerCol;
    offsetYRow = qrCenterRow-y;
    offsetXCol = qrCenterCol -x;

    %camera axis relative to QR and theta offset
    rotation = 'SE';

%Camera axis rotating westward from north. QR will be below the left most corner,
%look 50 row indices greater than this point's row index
elseif mean(I(leftCornerRow:(leftCornerRow+40))) > 245
    %thetaOffset
    maxRow = max(redRowIndices);
    maxColmaxRow = max(find(redstrel(maxRow,:) ~= 0 )); 
    overhang = maxRow - leftCornerRow; %reversed order. now positive
    length = maxColmaxRow - leftCornerCol;
    thetaOffset = atand(overhang/length);
    
    %center offset
    halfHyp = round(sqrt(overhang^2 + length^2)/2,0); 
    centerRow = round((halfHyp*sind(90-thetaOffset))/2*sind(90),0);
    centerCol = round((halfHyp*sind((180-(90-thetaOffset)-90))/2*sind(90)),0);
    qrCenterRow = maxRow+centerRow;
    qrCenterCol = maxColmaxRow-centerCol;
    offsetYRow = qrCenterRow-y;
    offsetXCol = qrCenterCol -x;
    
    %Camera axis relative to QR and theta offset NE
    rotation = 'NE';
    


%Camera axis rotating eastward from south.  QR will be above left most
%corner.  look at 40 row indices lower than this point's row index.
%Overhang, length values calculated from the RIGHT most point of the red
%square.
elseif mean(I((leftCornerRow-20):leftCornerRow)) > 245
    %thetaOffset
    minRow = min(redRowIndices);
    maxColminRow = max(find(redstrel(minRow,:) ~= 0 ));
    maxRowmaxCol = max(find(redstrel(:,max(redColIndices)) ~= 0 )); %Right point, row index
    overhang = maxRowmaxCol - minRow; 
    length = (max(redColIndices)) - maxColminRow;
    thetaOffset = atand(overhang/length);
    
    %center offset
    halfHyp = round(sqrt(overhang^2 + length^2)/2,0);
    centerRow = round((halfHyp*sind(90-thetaOffset))/2*sind(90),0);
    centerCol = round((halfHyp*sind((180-(90-thetaOffset)-90))/2*sind(90)),0);
    qrCenterRow = minRow-centerRow;
    qrCenterCol = maxColminRow+centerCol;
    offsetYRow = qrCenterRow-y;
    offsetXCol = qrCenterCol -x;
    
    %camera axis relative to QR and theta offset
    rotation = 'SW';

%Camera axis rotating northward from east.  QR will be neither above nor
%below left most corner.  Make sure 40 row indices above and below leftmost
%point are less than 150. Calculate from Right most point of red square
%again
elseif mean(I((leftCornerRow-40):(leftCornerRow+40))) < 200
    %thetaOffset
    maxRow = max(redRowIndices);
    maxColmaxRow = max(find(redstrel(maxRow,:) ~= 0 )); 
    maxRowmaxCol = max(find(redstrel(:,max(redColIndices)) ~= 0 )); %Right point, row index
    length = maxRowmaxCol - maxRow; 
    overhang = (max(redColIndices)) - maxColmaxRow;
    thetaOffset = -90-atand(overhang/length);
    
    %center offset
    halfHyp = round(sqrt(overhang^2 + length^2)/2,0);
    centerCol = round((halfHyp*sind(90-thetaOffset))/2*sind(90),0);
    centerRow = round((halfHyp*sind((180-(90-thetaOffset)-90))/2*sind(90)),0);
    qrCenterRow = maxRowmaxCol+centerRow;
    qrCenterCol = (max(redColIndices)) + centerCol;
    offsetYRow = qrCenterRow-y;
    offsetXCol = qrCenterCol -x;
    
    %camera axis relative to QR and theta offset
    rotation = 'NW';
else
    %skip frame
end 
%% Section 4: Incorporate field design, get the panel number
%Once orientation, QR centers, offset angle is known

%Field design (in feet) for Panels in serpentine order, starting in NW
%corner. 
%Read in field coordinates
designPanel1 = csvread('fieldCoordinates1.csv');
designPanel3 = csvread('fieldCoordinates3.csv');
designPanel5 = csvread('fieldCoordinates5.csv');
designPanel7 = csvread('fieldCoordinates7.csv');

%Read in plotnames
fid1 = fopen('fieldPlotnames1.txt'); 
plotnamePanel1 = textscan(fid1,'%s');
fclose(fid1);
plotnamePanel1 = plotnamePanel1{:};

fid3 = fopen('fieldPlotnames3.txt'); 
plotnamePanel3 = textscan(fid3,'%s');
fclose(fid3);
plotnamePanel3 = plotnamePanel3{:};

fid5 = fopen('fieldPlotnames5.txt'); 
plotnamePanel5 = textscan(fid5,'%s');
fclose(fid5);
plotnamePanel5 = plotnamePanel5{:};

fid7 = fopen('fieldPlotnames7.txt'); 
plotnamePanel7 = textscan(fid7,'%s');
fclose(fid7);
plotnamePanel7 = plotnamePanel7{:};

%Conditional statement for panelnum and correct design array, plotname list.
% if else. make output variables design and plotname
if panelnum == 7
    design = designPanel7;
    plotname = plotnamePanel7;
elseif panelnum == 5
    design = designPanel5;
    plotname = plotnamePanel5;
elseif panelnum == 3
    design = designPanel3;
    plotname = plotnamePanel3;
elseif panelnum == 1
    design = designPanel1;
    plotname = plotnamePanel1;
else
    %skip
end 

%% Section 5: Rotation of points in design matrix based on thetaOffset, calculating new Latitude and Longitude angles for each point

%Transformation due to thetaOffset occurs first on raw x y coordinates in
%design array.  Add conditional statement here to evaluate all rotation
%conditions

if rotation == 'SW' %| rotation == 'SE'
    rotationmat = [cosd(thetaOffset+180) sind(thetaOffset+180);-sind(thetaOffset+180) cosd(thetaOffset+180)];
elseif rotation == 'SE'
    rotationmat = [cosd(thetaOffset+90) sind(thetaOffset+90);-sind(thetaOffset+90) cosd(thetaOffset+90)];
else
    rotationmat = [cosd(thetaOffset) sind(thetaOffset);-sind(thetaOffset) cosd(thetaOffset)];
end 


%Get rotated x,y coordinates for each of the four plot points.  multiply this matrix by the ith row of x y coordinates in the design
%matrix.  In design matrix, col 2:3 are SW, col 4:5 are SE, col 6:7 are NW,
%col 8:9 and NE. ADD IN X, Y OFFSET TO THE DESIGN MATRIX VALUES HERE PRIOR
%TO ROTATION

SWrot = zeros(size(design,1),2); 
for i = 1:size(design,1)
    SWrot(i,:) = (rotationmat*[design(i,2) design(i,3)]')'; %transpose of design x y coordinates, then transpose again
end 
SErot = zeros(size(design,1),2); 
for i = 1:size(design,1)
    SErot(i,:) = (rotationmat*[design(i,4) design(i,5)]')'; %transpose of design x y coordinates, then transpose again
end 
NWrot = zeros(size(design,1),2); 
for i = 1:size(design,1)
    NWrot(i,:) = (rotationmat*[design(i,6) design(i,7)]')'; %transpose of design x y coordinates, then transpose again
end 
NErot = zeros(size(design,1),2); 
for i = 1:size(design,1)
    NErot(i,:) = (rotationmat*[design(i,8) design(i,9)]')'; %transpose of design x y coordinates, then transpose again
end 
 
%get lat of rotated coordinates
SWlat2 = zeros(size(design,1),1);
for i = 1:size(design,1)
    rad = sqrt(SWrot(i,1)^2 + SWrot(i,2)^2 + (9-design(i,1))^2);
    SWlat2(i,1) = asind((9-design(i,1))/rad);
end 
SElat2 = zeros(size(design,1),1);
for i = 1:size(design,1)
    rad = sqrt(SErot(i,1)^2 + SErot(i,2)^2 + (9-design(i,1))^2);
    SElat2(i,1) = asind((9-design(i,1))/rad);
end 
NWlat2 = zeros(size(design,1),1);
for i = 1:size(design,1)
    rad = sqrt(NWrot(i,1)^2 + NWrot(i,2)^2 + (9-design(i,1))^2);
    NWlat2(i,1) = asind((9-design(i,1))/rad);
end 
NElat2 = zeros(size(design,1),1);
for i = 1:size(design,1)
    rad = sqrt(NErot(i,1)^2 + NErot(i,2)^2 + (9-design(i,1))^2);
    NElat2(i,1) = asind((9-design(i,1))/rad);
end 


%longitude angles of rotated coordinates using atan2d.
SWlon2 = atan2d(SWrot(:,2),SWrot(:,1));

SElon2 = atan2d(SErot(:,2),SErot(:,1));

NWlon2 = atan2d(NWrot(:,2),NWrot(:,1));

NElon2 = atan2d(NErot(:,2),NErot(:,1));


%% Section 6: Get index values in the image for latitude values at each point, then get index in terms of rows and columns based on longitude
% Get the index value based on the resolution function to each latitude
% value for points.  This becomes hypoteneuse, from which x and y values
% are calculated using the longitude at the same point.

%Get Index length of distance to point latitude from the QR center.  
SWind2 = zeros(size(design,1),1);
for i = 1:size(design,1)
    SWind2(i,1) = (0.1E-05*((SWlat2(i,1))^2) + -0.005*((SWlat2(i,1))) + 0.3609); 
end 
SEind2 = zeros(size(design,1),1);
for i = 1:size(design,1)
    SEind2(i,1) = (0.1E-05*((SElat2(i,1))^2) + -0.005*((SElat2(i,1))) + 0.3609);
end 
NWind2 = zeros(size(design,1),1);
for i = 1:size(design,1)
    NWind2(i,1) = (0.1E-05*((NWlat2(i,1))^2) + -0.005*((NWlat2(i,1))) + 0.3609);
end 
NEind2 = zeros(size(design,1),1);
for i = 1:size(design,1)
    NEind2(i,1) = (0.1E-05*((NElat2(i,1))^2) + -0.005*((NElat2(i,1))) + 0.3609);
end 

%get the row and column indices to each point based off the ind2 array
%values for all plot points, treating them as hypoteneuse.  
SWrc = zeros(size(design,1),2);
for i = 1:size(design,1)
    r = (SWind2(i)*sind(SWlon2(i)))/sind(90); %row
    c = sqrt((SWind2(i))^2-r^2); %col
    SWrc(i,1) = r;
    SWrc(i,2) = c;
end 

SErc = zeros(size(design,1),2);
for i = 1:size(design,1)
    r = (SEind2(i)*sind(SElon2(i)))/sind(90); %row
    c = sqrt((SEind2(i))^2-r^2); %col
    SErc(i,1) = r;
    SErc(i,2) = c;
end 

NWrc = zeros(size(design,1),2);
for i = 1:size(design,1)
    r = (NWind2(i)*sind(NWlon2(i)))/sind(90); %row
    c = sqrt((NWind2(i))^2-r^2); %col
    NWrc(i,1) = r;
    NWrc(i,2) = c;
end 

NErc = zeros(size(design,1),2);
for i = 1:size(design,1)
    r = (NEind2(i)*sind(NElon2(i)))/sind(90); %row
    c = sqrt((NEind2(i))^2-r^2); %col
    NErc(i,1) = r;
    NErc(i,2) = c;
end 

%% Section 7: Create correction matrix for points.
%This will be multiplied to the indices so that the values can be added or
%subtracted from the center values in the rotated image.

%Assign the right sign to the row and col values in SWrc based on value
%of SWlon2 angle in SWlon2 array. 

%Declare general correction matrix for SW,SE,NW,NErc arrays
SWCorrection = zeros(size(SWlon2,1),2); 
SECorrection = zeros(size(SWlon2,1),2); 
NWCorrection = zeros(size(SWlon2,1),2); 
NECorrection = zeros(size(SWlon2,1),2); 

%if Facing NE

%SWlon2
for i =1:size(SWlon2,1)
    if (SWlon2(i) >0) && (SWlon2(i) < 90) %upper right quad
        SWCorrection(i,1) = -1; %row
        SWCorrection(i,2) = 1; %col
    elseif (SWlon2(i) >= 90) && (SWlon2(i) < 180) %upper left quad
        SWCorrection(i,1) = -1; %row
        SWCorrection(i,2) = -1; %col
    elseif (SWlon2(i) < -90) && (SWlon2(i) >= -180) %lower left quad
        SWCorrection(i,1) = -1; %row
        SWCorrection(i,2) = -1; %col
    elseif (SWlon2(i) <= 0) && (SWlon2(i) >=-90) %lower right quad  
        SWCorrection(i,1) = -1; %row
        SWCorrection(i,2) = 1; %col
    else
        %skip
    end
end 

%SElon2
for i =1:size(SElon2,1)
    if (SElon2(i) >0) && (SElon2(i) < 90) %upper right quad
        SECorrection(i,1) = -1; %row
        SECorrection(i,2) = 1; %col
    elseif (SElon2(i) >= 90) && (SElon2(i) < 180) %upper left quad
        SECorrection(i,1) = -1; %row
        SECorrection(i,2) = -1; %col
    elseif (SElon2(i) < -90) && (SElon2(i) >= -180) %lower left quad
        SECorrection(i,1) = -1; %row
        SECorrection(i,2) = -1; %col
    elseif (SElon2(i) <= 0) && (SElon2(i) >=-90) %lower right quad  
        SECorrection(i,1) = -1; %row
        SECorrection(i,2) = 1; %col
    else
        %skip
    end
end 

%NWlon2
for i =1:size(NWlon2,1)
    if (NWlon2(i) >0) && (NWlon2(i) < 90) %upper right quad
        NWCorrection(i,1) = -1; %row
        NWCorrection(i,2) = 1; %col
    elseif (NWlon2(i) >= 90) && (NWlon2(i) < 180) %upper left quad
        NWCorrection(i,1) = -1; %row
        NWCorrection(i,2) = -1; %col
    elseif (NWlon2(i) < -90) && (NWlon2(i) >= -180) %lower left quad
        NWCorrection(i,1) = -1; %row
        NWCorrection(i,2) = -1; %col
    elseif (NWlon2(i) <= 0) && (NWlon2(i) >=-90) %lower right quad  
        NWCorrection(i,1) = -1; %row
        NWCorrection(i,2) = 1; %col
    else
        %skip
    end
end 

%NElon2
for i =1:size(NElon2,1)
    if (NElon2(i) >0) && (NElon2(i) < 90) %upper right quad
        NECorrection(i,1) = -1; %row
        NECorrection(i,2) = 1; %col
    elseif (NElon2(i) >= 90) && (NElon2(i) < 180) %upper left quad
        NECorrection(i,1) = -1; %row
        NECorrection(i,2) = -1; %col
    elseif (NElon2(i) < -90) && (NElon2(i) >= -180) %lower left quad
        NECorrection(i,1) = -1; %row
        NECorrection(i,2) = -1; %col
    elseif (NElon2(i) <= 0) && (NElon2(i) >=-90) %lower right quad  
        NECorrection(i,1) = -1; %row
        NECorrection(i,2) = 1; %col
    else
        %skip
    end
end 


%% Section 8: Applying the correction matrix to the index values

%multiply the SWrc by correction matrix.  These values can be added and
%subtracted directly from QR center. 

%SW
SWrc2 = SWrc.*SWCorrection;
%multiply this matrix by 2880 (image size)
SWrc2 = SWrc2.*(size(image,1));
SWrc3 = SWrc2;
%add 1440 to all rows, cols to put in real image indices.  Row (col 1)
%indicates y indices.  Col (col2) indicates x indices. 
SWrc4 = SWrc3+(size(image,1)/2);

%SE
SErc2 = SErc.*SECorrection;
%multiply this matrix by 2880 (image size)
SErc2 = SErc2.*(size(image,1));
SErc3 = SErc2;
%add 1440 to all rows, cols to put in real image indices.  Row (col 1)
%indicates y indices.  Col (col2) indicates x indices. 
SErc4 = SErc3+(size(image,1)/2);

%NW
NWrc2 = NWrc.*NWCorrection;
%multiply this matrix by 2880 (image size)
NWrc2 = NWrc2.*(size(image,1));
NWrc3 = NWrc2;
%add 1440 to all rows, cols to put in real image indices.  Row (col 1)
%indicates y indices.  Col (col2) indicates x indices. 
NWrc4 = NWrc3+(size(image,1)/2);

%NE
NErc2 = NErc.*NECorrection;
%multiply this matrix by 2880 (image size)
NErc2 = NErc2.*(size(image,1));
NErc3 = NErc2;
%add 1440 to all rows, cols to put in real image indices.  Row (col 1)
%indicates y indices.  Col (col2) indicates x indices. 
NErc4 = NErc3+(size(image,1)/2);

%% Section 9: Cropping plots based on these rotated coordinates, export images and cropping functions
%make new arrays out of SWrc4 to mimic four seperate arrays of index
%coordinates



for k = 1:size(SWlon2,1)
    
    % Convert from RGB to grayscale.
    X = rgb2gray(image);

    % Create empty mask.
    BW = false(size(X));

    % Polygon drawing
    xPos = [SWrc4(k,2) SErc4(k,2) NErc4(k,2) NWrc4(k,2)];
    yPos = [SWrc4(k,1) SErc4(k,1) NErc4(k,1) NWrc4(k,1)]; 
    m = size(BW, 1);
    n = size(BW, 2);
    addedRegion = poly2mask(xPos, yPos, m, n);
    BW = BW | addedRegion;

    % Create masked image.
    maskedImage = X;
    maskedImage(~BW) = 0;
    
    % Create unique name for image based on plotname array
    newname = sprintf('masked_%s.tif',plotname{k}); 
    imwrite(maskedImage,newname,'tif')

    %function to output cropping function files for each plot
    newfun = sprintf('crop_%s.m',plotname{k});
    FID = fopen(newfun,'w');
    newfunname = sprintf('crop_%s',plotname{k});
    %make files
    cropFunGenerator(FID,newfunname,xPos,yPos);
    %close current file
    fclose(FID);
end 


