
% By Alexander Q. Susko. 
%Please cite: Susko, A.Q., Rinehart, T.A., Bradeen, J.M. and Hokanson, S.C., 2018. An Evaluation of Two Seedling Phenotyping Protocols to Assess pH Adaptability in Deciduous Azalea (Rhododendron sect. Pentanthera G. Don). HortScience, 53(3), pp.268-274.

%This script is useful for detecting rhizosphere acidification based on
%colorimetric pH indicators in tissue culture media.  See the citation
%above for a full description of possible applications.

%Attempt to individually load files
imagefiles = dir('*.jpg');
filenames = {imagefiles.name};
nfiles = length(imagefiles);% Number of files found

%Create CSV file for writing results
fid = fopen('hsv.csv','wt'); 

%Loop through each file to calculate the hue, saturation, and value
%averages across all pixels.  Store image ID as the filename
for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   currentimage = imread(currentfilename);
   images= currentimage; 
   hsv=rgb2hsv(images);
   
   %HSV for all pixels in the image

   h = hsv(:,:,1); %separate hue values
   s = hsv(:,:,2); %separate saturation values
   v = hsv(:,:,3); %separate value values

   %Calculate average HSV values across the image

   finalh(ii)=mean(mean(h));
   finals(ii)=mean(mean(s));
   finalv(ii)=mean(mean(v));

   %add one if measured hue is less than 0.5 (for rhizosphere acidification
   %application.  This will avoid negative values when subtracting post-screening from initial values, as initial
   %hue values will be around 0.95, and change to 0.10 or thereabouts after
   %screening

   if finalh(ii) < 0.5
       adjustedFinalh(ii) = (finalh(ii) + 1); %for low hue values
   else 
       adjustedFinalh(ii) = (finalh(ii) + 0); %for high hue values
   end 
       
   %writing individual lines to the file
   fprintf(fid, [filenames{ii},',',num2str(adjustedFinalh(ii)),',',num2str(finals(ii)),',',num2str(finalv(ii)),'\r\n']);
end

%Close the file
fclose(fid);


