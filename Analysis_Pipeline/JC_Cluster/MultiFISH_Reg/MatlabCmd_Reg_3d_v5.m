Init_Cluster_GlobalVar_v2();

% strImgFn_Ref ='//tier2/sternson/XSJ/RNAScope/03-28-16/325698_Slide25_SliceC/Reg/T325698_Slide25_SliceC_FullArc_Rnd1_DAPI.tif';
% 
% strImgFn_Mov ='//tier2/sternson/XSJ/RNAScope/03-28-16/325698_Slide25_SliceC/Reg/T325698_Slide25_SliceC_FullArc_Rnd3_DAPI.tif';
% Cluster_Scripts_Reg_3d_v3(strImgFn_Ref, strImgFn_Mov, 16,false,true);
% 
% strImgFn_Mov ='//tier2/sternson/XSJ/RNAScope/3-18-16/Split/25/C2-325698_Slide25_SliceB_Full_Arc_Rnd3_B.tif';
% Cluster_Scripts_Reg_3d_v3(strImgFn_Ref, strImgFn_Mov, 16,true);
% 
% 
% strImgFn_Ref ='//tier2/sternson/XSJ/RNAScope/3-18-16/Split/30/C2-325698_Slide30_SliceB_Full_Arc_Rnd1_B.tif';
% 
% strImgFn_Mov ='//tier2/sternson/XSJ/RNAScope/3-18-16/Split/30/C2-325698_Slide30_SliceB_Full_Arc_Rnd2_B.tif';
% Cluster_Scripts_Reg_3d_v3(strImgFn_Ref, strImgFn_Mov, 16,true);
% 
% strImgFn_Mov ='//tier2/sternson/XSJ/RNAScope/3-18-16/Split/30/C2-325698_Slide30_SliceB_Full_Arc_Rnd3_B.tif';
% Cluster_Scripts_Reg_3d_v3(strImgFn_Ref, strImgFn_Mov, 16,true);


clDirs = {  %'//tier2/sternson/XSJ/RNAScope/03-28-16/325698_Slide29_SliceA/Reg';
%             '/groups/sternson/sternsonlab/from_tier2/XSJ/Confocal/ANM318142/M318142_Real/S7_1/Reg_DR/Rnd5';
%             '/groups/sternson/sternsonlab/from_tier2/XSJ/Confocal/ANM318142/M318142_Real/S6_3/Reg_DR/Rnd5';
%             '/groups/sternson/sternsonlab/from_tier2/XSJ/Confocal/ANM318142/M318142_Real/S6_2/Reg_DR/Rnd5';
%             '/groups/sternson/sternsonlab/from_tier2/XSJ/Confocal/ANM318142/M318142_Real/S6_1/Reg_DR/Rnd5';
%             '/groups/sternson/sternsonlab/from_tier2/XSJ/Confocal/ANM318142/M318142_Real/S5_3/Reg_DR/Rnd5';
%             '/groups/sternson/sternsonlab/from_tier2/XSJ/Confocal/ANM318142/M318142_Real/S5_2/Reg_DR/Rnd5';
            '/groups/sternson/sternsonlab/from_tier2/XSJ/Imaging/2P345/20170820/ANM372320/ZStacks/Stack2026';
            %'/groups/sternson/sternsonlab/from_tier2/XSJ/Confocal/ANM318142/M318142_Real/S6_2/Reg_DR/Rnd5b';
            %'//tier2/sternson/XSJ/RNAScope/ANTS_Tests/B/Re'
            %'//tier2/sternson/XSJ/RNAScope/03-28-16/325698_Slide25_SliceB/Reg';
    };
    
clRegExps ={'.tif', '_B.tif','_B.tif','_B.tif','_B.tif','_B.tif','_B.tif'};
nDirCount = length(clDirs);

clTiffFns = cell(1,nDirCount);
for nDir =1:nDirCount
    strRegExp = clRegExps{nDir};
    clTiffs = FindFiles_RegExp(strRegExp, clDirs{nDir}, false)';
    nFileCount = length(clTiffs);
    for nFile = 1:nFileCount
        strImgFn = clTiffs{nFile};
        clTiffs{nFile} = ImgDownSamp_Cmd(strImgFn);
    end
    clTiffFns(nDir) = {clTiffs};
end    

%%
vtRef = [1 1 1 1 1 1 4];

bGenRefZMax = true;
for nDir =1:nDirCount
    clTiffs = clTiffFns{nDir};
    nFileCount = length(clTiffs);
    idxRef = vtRef(nDir);
    strImgFn_Ref = clTiffs{idxRef};
    vtFileIdx = setxor(1:nFileCount,idxRef);
    for nFile = vtFileIdx
        strImgFn_Mov = clTiffs{nFile};
        if(nFile==vtFileIdx(1))
            bGenRefZMax = true;
        else
            bGenRefZMax = false;
        end
        Cluster_Scripts_Reg_3d_v4(strImgFn_Ref, strImgFn_Mov, 16,bGenRefZMax,true);
    end
end