function ImgDownSamp(strImgFn,strIJPath)

if(~isempty(strIJPath)&&~exist('ij.ImagePlus','class'))
    javaaddpath(strIJPath);
end
[strDir,strFn]=fileparts(strImgFn);
strDir_Sav = [strDir filesep 'DS'];
ImgData = readTiffStack_IJ(strImgFn);
ImgData = imresize(ImgData,0.25);
strFn_Sav = [strDir_Sav filesep strFn '.tif'];
writeTiffStack_IJ(ImgData,strFn_Sav);
