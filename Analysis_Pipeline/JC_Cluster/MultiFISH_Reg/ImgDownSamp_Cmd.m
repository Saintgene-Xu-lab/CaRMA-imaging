function strImgFn_O = ImgDownSamp_Cmd(strImgFn)

global strIJPath;
global strDir_Matlab; 

[strDir,strFn]=fileparts(strImgFn);
strDir_Sav = [strDir filesep 'DS'];
strImgFn_O = [strDir_Sav filesep strFn '.tif'];

strCmd = [strDir_Matlab filesep 'ImgDownSamp ' strImgFn ' ' strIJPath];
warning('off','all');
system(strCmd);
%warning('on','backtrace');