clear;
Init_Cluster_GlobalVar_v2();

global strDir_Matlab;
for nSlice = 137:147
    strImgDir_Ref = LP(['Z:\Confocal\ANM378231_Real\Trans_DR\S' num2str(nSlice) '\Rd1']);
    strDir_Img = LP(['Z:\Confocal\ANM378231_Real\Trans_DR\S' num2str(nSlice)]);
    clImgFn_Ref = FindFiles_RegExp('B.tif', strImgDir_Ref, false)';
    strImgFn_Ref = clImgFn_Ref{1};
    clFns_Img = FindFiles_RegExp('/S\d{3}_v10.tif', strDir_Img, true)';
    %%
    for nFile = 1:length(clFns_Img)
        strImgFn = clFns_Img{nFile};
        strPath_Img = fileparts(strImgFn);
        clFns_Warp = FindFiles_RegExp('Warp.nii.gz',strPath_Img,false);
        clFns_Affine = FindFiles_RegExp('GenericAffine.mat',strPath_Img,false);
        if(~(isempty(clFns_Warp)||isempty(clFns_Affine)))
            clFns_TMatrix{1} = [strDir_Matlab filesep '25.txt'];
            clFns_TMatrix{2} = clFns_Warp{1};
            clFns_TMatrix{3} = clFns_Affine{1};
            clFns_TMatrix{4} = [strDir_Matlab filesep '400.txt'];
            
            Cluster_Scripts_ApplyTrans_3d_v2(strImgFn, strImgFn_Ref, clFns_TMatrix, 16,true);
        end
    end
end