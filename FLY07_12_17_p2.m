
%% %%color analysis of one segment over all frames in a stationary video 
%7/12/17 p2
%% Read in video
video = VideoReader('FLY07_12_17_p2.mp4');

%% Loop through video frames
nframes = video.NumberOfFrames; 
R = zeros([nframes 23]); 

h = waitbar(0,'Please wait...');

for k = 1:nframes
    %get the kth frame from video
    singleFrame = read(video, k);

    
    
    %get the red QR code square for normalization
    maskred =uint8(red(singleFrame));
    kthmaskred = maskred.*(singleFrame);

    %mask the kth frame with the corresponding function.  Numbering starts
    %in northeast corner, going east in serpentine pattern
    mask1 =uint8(AC_Metcalf_2row_2A(singleFrame));
    kthmask1 = mask1.*singleFrame;
    
    mask2 =uint8(GOPHER_oat_2A(singleFrame));
    kthmask2 = mask2.*singleFrame;
    
    mask3 =uint8(StellarND_6row_2A(singleFrame));
    kthmask3 = mask3.*singleFrame;
    
    mask4 =uint8(ND021052_oat_2A(singleFrame));
    kthmask4 = mask4.*singleFrame;
    
    mask5 =uint8(Rollag_wheat_2A(singleFrame));
    kthmask5 = mask5.*singleFrame;
    
    mask6 =uint8(Conion_2row_2A(singleFrame));
    kthmask6 = mask6.*singleFrame;
    
    mask7 =uint8(Linkert_wheat_2A(singleFrame));
    kthmask7 = mask7.*singleFrame;
    
    mask8 =uint8(GOPHER_oat_2B(singleFrame));
    kthmask8 = mask8.*singleFrame;
    
    mask9 =uint8(AC_Metcalf_2row_2B(singleFrame));
    kthmask9 = mask9.*singleFrame;
    
    mask10 =uint8(Tradition_6row_2A(singleFrame));
    kthmask10 = mask10.*singleFrame;
    
    mask11 =uint8(Conion_2row_2B(singleFrame));
    kthmask11 = mask11.*singleFrame;
    
    mask12 =uint8(ND021052_oat_2B(singleFrame));
    kthmask12 = mask12.*singleFrame;
    
    mask13 =uint8(MN113946_wheat_2A(singleFrame));
    kthmask13 = mask13.*singleFrame;
    
    mask14 =uint8(IL078721_oat_2A(singleFrame));
    kthmask14 = mask14.*singleFrame;
    
    mask15 =uint8(Tradition_6row_2B(singleFrame));
    kthmask15 = mask15.*singleFrame;
    
    mask16 =uint8(Celebration_6row_2A(singleFrame));
    kthmask16 = mask16.*singleFrame;
    
    mask17 =uint8(Linkert_wheat_2B(singleFrame));
    kthmask17 = mask17.*singleFrame;
    
    mask18 =uint8(Celebration_6row_2B(singleFrame));
    kthmask18 = mask18.*singleFrame;
    
    mask19 =uint8(ND021052_oat_2C(singleFrame));
    kthmask19 = mask19.*singleFrame;
    
    mask20 =uint8(AC_Metcalf_2row_2C(singleFrame));
    kthmask20 = mask20.*singleFrame;
    
    mask21 =uint8(MN113946_wheat_2B(singleFrame));
    kthmask21 = mask21.*singleFrame;
    
    mask22 =uint8(ND_Genesis_2row_2A(singleFrame));
    kthmask22 = mask22.*singleFrame;
    
    
    %get the mean of the non-zero indices of the kthmask for each LAB
    %channel
    
    [Lxred, Lyred] = find(kthmaskred(:,:,1) ~=0 );
    Lmeanred = mean(mean(kthmaskred(unique(Lxred),unique(Lyred),1)));
    
    [Lx1, Ly1] = find(kthmask1(:,:,1) ~=0 );
    Lmean1 = mean(mean(kthmask1(unique(Lx1),unique(Ly1),1)));

    [Lx2, Ly2] = find(kthmask2(:,:,1) ~=0 );
    Lmean2 = mean(mean(kthmask2(unique(Lx2),unique(Ly2),1)));

    [Lx3, Ly3] = find(kthmask3(:,:,1) ~=0 );
    Lmean3 = mean(mean(kthmask3(unique(Lx3),unique(Ly3),1)));

    [Lx4, Ly4] = find(kthmask4(:,:,1) ~=0 );
    Lmean4 = mean(mean(kthmask4(unique(Lx4),unique(Ly4),1)));
    
    [Lx5, Ly5] = find(kthmask5(:,:,1) ~=0 );
    Lmean5 = mean(mean(kthmask5(unique(Lx5),unique(Ly5),1)));

    [Lx6, Ly6] = find(kthmask6(:,:,1) ~=0 );
    Lmean6 = mean(mean(kthmask6(unique(Lx6),unique(Ly6),1)));
    
    [Lx7, Ly7] = find(kthmask7(:,:,1) ~=0 );
    Lmean7 = mean(mean(kthmask7(unique(Lx7),unique(Ly7),1)));

    [Lx8, Ly8] = find(kthmask8(:,:,1) ~=0 );
    Lmean8 = mean(mean(kthmask8(unique(Lx8),unique(Ly8),1)));
    
    [Lx9, Ly9] = find(kthmask9(:,:,1) ~=0 );
    Lmean9 = mean(mean(kthmask9(unique(Lx9),unique(Ly9),1)));
    
    [Lx10, Ly10] = find(kthmask10(:,:,1) ~=0 );
    Lmean10 = mean(mean(kthmask10(unique(Lx10),unique(Ly10),1)));
    
    [Lx11, Ly11] = find(kthmask10(:,:,1) ~=0 );
    Lmean11 = mean(mean(kthmask11(unique(Lx11),unique(Ly11),1)));
    
    [Lx12, Ly12] = find(kthmask12(:,:,1) ~=0 );
    Lmean12 = mean(mean(kthmask12(unique(Lx12),unique(Ly12),1)));
    
    [Lx13, Ly13] = find(kthmask13(:,:,1) ~=0 );
    Lmean13 = mean(mean(kthmask13(unique(Lx13),unique(Ly13),1)));
    
    [Lx14, Ly14] = find(kthmask14(:,:,1) ~=0 );
    Lmean14 = mean(mean(kthmask14(unique(Lx14),unique(Ly14),1)));
    
    [Lx15, Ly15] = find(kthmask15(:,:,1) ~=0 );
    Lmean15 = mean(mean(kthmask15(unique(Lx15),unique(Ly15),1)));
    
    [Lx16, Ly16] = find(kthmask16(:,:,1) ~=0 );
    Lmean16 = mean(mean(kthmask16(unique(Lx16),unique(Ly16),1)));
    
    [Lx17, Ly17] = find(kthmask17(:,:,1) ~=0 );
    Lmean17 = mean(mean(kthmask17(unique(Lx17),unique(Ly17),1)));
    
    [Lx18, Ly18] = find(kthmask18(:,:,1) ~=0 );
    Lmean18 = mean(mean(kthmask18(unique(Lx18),unique(Ly18),1)));
    
    [Lx19, Ly19] = find(kthmask19(:,:,1) ~=0 );
    Lmean19 = mean(mean(kthmask19(unique(Lx19),unique(Ly19),1)));

    [Lx20, Ly20] = find(kthmask20(:,:,1) ~=0 );
    Lmean20 = mean(mean(kthmask20(unique(Lx20),unique(Ly20),1)));
    
    [Lx21, Ly21] = find(kthmask21(:,:,1) ~=0 );
    Lmean21 = mean(mean(kthmask21(unique(Lx21),unique(Ly21),1)));
    
    [Lx22, Ly22] = find(kthmask22(:,:,1) ~=0 );
    Lmean22 = mean(mean(kthmask22(unique(Lx22),unique(Ly22),1)));
    

    
    %Write to R array
    R(k,:) = [Lmeanred Lmean1 Lmean2 Lmean3 Lmean4 Lmean5 Lmean6 Lmean7 Lmean8 Lmean9 Lmean10 Lmean11 Lmean12 Lmean13 Lmean14 Lmean15 Lmean16 Lmean17 Lmean18 Lmean19 Lmean20 Lmean21 Lmean22];
    
    %waitbar
    waitbar(k / nframes)

end 


%Normalize the LAB array to the first column (Red QR square)
RN = R ./ R(:,1);

%Write RN array to file
dlmwrite('FLY07_12_17_p2.txt',RN,'delimiter','\t'); 

close(h) 


