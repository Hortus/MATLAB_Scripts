%% Planting Date 1 Bandpass parsing from color data.  
%Input: raw waveform data quantified from colors in video over frames (rows
%= frames, cols = plots)
%Output: subdirectory for each plot containing peak envelope area of bandpassed waveform data, average frequency
%contributions based on peak local maxima distances of bandpassed waveforms
%Data output matches the column order of the input file.  

%Loop through directory, get the text files for planting date 1.
files = dir('*.txt');
filenames = {files.name};
nfiles = length(files); 

for j = 1:nfiles
%% File input
%Read in file
currentfile = files(j).name; 
fileID = fopen(currentfile,'r'); 

%Set format specs for floats, delimiter 
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]'; %have different format specs depending on which planting date (23 in P2 (+1 for the red square col))
delimiter = '\t';

%Read in data to a cell using textscan
dataCell = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);

%Convert cell to array
dataArray = [dataCell{1:end-1}];     

%create output directory to hold all individual files containing arrays
currentfile = erase(currentfile,'.txt'); %erase the .txt from the input filename
mkdir (currentfile)
%get path to the new output directory
currentdir = pwd();
outputdir = sprintf('%s\\%s',currentdir,currentfile);

%plotname array
plotnames = {'AC_Metcalf_2row_2A', 'GOPHER_oat_2A', 'StellarND_6row_2A', 'ND021052_oat_2A', 'Rollag_wheat_2A', 'Conion_2row_2A', 'Linkert_wheat_2A', 'GOPHER_oat_2B', 'AC_Metcalf_2row_2B', 'Tradition_6row_2A', 'Conion_2row_2B', 'ND021052_oat_2B', 'MN113946_wheat_2A', 'IL078721_oat_2A', 'Tradition_6row_2B', 'Celebration_6row_2A', 'Linkert_wheat_2B', 'Celebration_6row_2B', 'ND021052_oat_2C', 'AC_Metcalf_2row_2C', 'MN113946_wheat_2B', 'ND_Genesis_2row_2A'};
    
%% Loop through columns in one file, perform fourier transform

%Get number of columns (plots) in dataArray
ncol= (size(dataArray,2)-1); %minus red square col
%get rows in matrix, compute frequency (frequencies analyzed)
nrowfft = size(dataArray,1);
freq = 24*(0:(nrowfft/2))/nrowfft;
nrow = length(freq);

%pre allocate output arrays,put frequencies in first column
outputLow = zeros(nrow, ncol); 
outputLow(:,1) = freq';
outputHigh = zeros(nrow, ncol);
outputHigh(:,1) = freq';
outputMean = zeros(nrow, ncol);
outputMean(:,1) = freq';

for k = 1:ncol
    %subset (skip first column)
    A = dataArray(:,(k+1));
    
    %frame rate
    frate = 24;
    
    %dsp bandpass filtering
    d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', ...
    0.03,0.04,0.4,0.5,100,5,100); %Increase the Ast parameters to reduce the influence of frequencies outside of the filter
    Hd = design(d,'equiripple');
    A2 = filter(Hd,A);

    %get local maxima on bandpassed signal with a 0.5% change in red
    %prominence
    [peaks,locs] = findpeaks(A2,'MinPeakProminence',0.005);
    
    %create array of nearest peak distances (skipping the first peak),
    %divide by nframes to get frequency distribution
    freq = zeros(length(locs),1);
    for n=1:length(locs)
        if n == 1
            %skip
        else 
            freq(n,1) = (locs(n,1)-locs((n-1),1))/frate;
        end
    end 
    
    %sum up the total (absolute) area under the curve that lies between
    %peaks
    %area = sum(abs(A2));
    area = zeros(length(locs),1);
    for m=1:length(locs)
        if m == 1
            area(m) = sum(abs(A2(1:locs(m)))); %sum the area to the first peak in the bandpassed file, using corresponding index in locs file
        else
            area(m) = sum(abs(A2(locs(m-1):locs(m)))); %sum the area to the mth peak in the bandpassed file, using corresponding indices in locs file
        end 
    end 
    
    %create frequency and curve area array
    freqArea = [freq area];
    freqArea = sortrows(freqArea,1);
   
    %write freqArea to txt file
    %attach plotname to filename output (kth column)
    newName = char(sprintf('%s.txt',plotnames{k}));
    %dlmwrite(newName,freqArea, 'Delimiter', '\t'); 
    %write freqArea array with corresponding plot filename to output
    %directory
    dlmwrite(fullfile(outputdir,newName),freqArea, 'Delimiter', '\t');
    
end 
end 
