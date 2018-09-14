%cropFunGenerator.m 
%for generating cropping functions based on their transformed coordinates
%in hemispherical images

function [fmt,s] = cropFunGenerator(FID,newfunname,xPos,yPos)
fun = 'function'; %text for function
outputs = '[BW,maskedImage] =';
name = newfunname; %text for function name (defined in for loop from plotname cell array)
input = '(X)'; %input for future object for cropping function (image)
rgb = 'X = rgb2gray(X); %convert to grayscale'; %text for rgb2gray function
emptymask = 'BW = false(size(X)); %create empty mask'; %text to create empty mask
polycom = '%polygon drawing'; %polygon drawing comment
xtext = 'xPos = ['; %text for xPos array
xcoord = xPos; %x coordinate array
xbracket = '];'; %bracket for array
ytext = 'yPos = ['; %text for yPos array
ycoord = yPos; %y coordinate array
ybracket = '];'; %bracket for y array
m = 'm = size(BW, 1);';
n = 'n = size(BW, 2);';
poly = 'addedRegion = poly2mask(xPos, yPos, m, n);'; %poly crop
BW = 'BW = BW | addedRegion;'; %BW 
maskcom = '%create masked image'; %masking comment
mask1 = 'maskedImage = X;';
mask2 = 'maskedImage(~BW) = 0;';
%write to new file
fmt = '%s %s %s%s\n%s\n%s\n%s\n%s%f %f %f %f%s\n%s%f %f %f %f%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s'; %format statement
s = fprintf(FID,fmt,fun,outputs,name,input,rgb,emptymask,polycom,xtext,xcoord,xbracket,ytext,ycoord,ybracket,m,n,poly,BW,maskcom,mask1,mask2); %write to file w/ fprintf to FID using format statement fmt
end