function Cluster_Scripts_Reg_3d_v4(strImgFn_Ref, strImgFn_Mov,nThreads,bGenRefZMax,bClusterOE)

if(nargin<3)
    nThreads=16;
end

if(nargin<4)
    bGenRefZMax = true;
end
if(nargin <5)
    bClusterOE = true; %output and error
end

global strDir_ANTS;
global strDir_Matlab; 
global strMCR_Cache_root;

[strPath_Ref,strFn_Ref,strExt]=fileparts(strImgFn_Ref);
strImgFn_Ref_ZMax = [strPath_Ref filesep strFn_Ref '_ZMax' strExt];
[strPath_Mov,strFn_Mov,strExt]=fileparts(strImgFn_Mov);
strImgFn_Mov_ZMax = [strPath_Mov filesep strFn_Mov '_ZMax' strExt];

strDir_ImgWarp = [strPath_Mov filesep 'ImgWarp'];
if(~exist(strDir_ImgWarp,'dir'))
    mkdir(strDir_ImgWarp);
end


strMathCmdFn = [strDir_ANTS filesep 'bin' filesep 'ImageMath'];
strANTSCmdFn = [strDir_ANTS filesep 'bin' filesep 'antsRegistration'];
strExt_2D_3DFn = [strDir_Matlab filesep 'Ext_2D_AffineTransform_3D'];

strImg_Warp_prefix = [strDir_ImgWarp filesep strFn_Mov];
strImg_Warp_prefix_ZMax = [strDir_ImgWarp filesep strFn_Mov '_ZMax'];
strImgFn_Warp = [strImg_Warp_prefix '_Reg.nii'];
strImgFn_Warp_ZMax = [strImg_Warp_prefix_ZMax '_Reg.nii'];
strMatFn_Init = [strImg_Warp_prefix '_Init_Affine.txt'];
strScriptFn = [strImg_Warp_prefix '_v3.sh'];

if(bClusterOE)
    strVerb = '1';
else
    strVerb = '0';
end

fid = fopen(strScriptFn,'w');

%fprintf(fid,'ORIGINALNUMBEROFTHREADS=${ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS}\n');
%fprintf(fid,'echo "ORIGINALNUMBEROFTHREADS=$ORIGINALNUMBEROFTHREADS"\n');
fprintf(fid,['ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=' num2str(nThreads) '\n']);
fprintf(fid,'export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS\n');
%fprintf(fid,'echo "ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS"\n');

if(bGenRefZMax)
    strMathCmd = [strMathCmdFn ' 3 ' strImgFn_Ref_ZMax ' Project ' strImgFn_Ref ' 2 1'];
    fprintf(fid,[FilesepRep(strMathCmd) '\n']);
end

strMathCmd = [strMathCmdFn ' 3 ' strImgFn_Mov_ZMax ' Project ' strImgFn_Mov ' 2 1'];
fprintf(fid,[FilesepRep(strMathCmd) '\n']);

strANTSCmd = [strANTSCmdFn ' -v ' strVerb ' -d 2 -r [' strImgFn_Ref_ZMax ',' strImgFn_Mov_ZMax ',0] \\\n'...
    '-m GC[' strImgFn_Ref_ZMax ',' strImgFn_Mov_ZMax ',1,6] \\\n'...
    '-t Translation[0.1] -c [10000x10000x10000x10000x10000,1.e-7,20] -s 3x2x1x0x0vox -f 16x8x4x2x1 \\\n' ...
    '-m GC[' strImgFn_Ref_ZMax ',' strImgFn_Mov_ZMax ',1,6] \\\n'...
    '-t Rigid[0.1] -c [10000x10000x10000x10000x10000,1.e-7,20] -s 3x2x1x0x0vox -f 16x8x4x2x1 \\\n' ...
    '-m GC[' strImgFn_Ref_ZMax ',' strImgFn_Mov_ZMax ',1,6] \\\n'...
    '-t Affine[0.1] -c [10000x10000x10000x10000x10000,1.e-7,20] -s 3x2x1x0x0vox -f 16x8x4x2x1 \\\n' ...
    '-n BSpline -o [' strImg_Warp_prefix_ZMax ',' strImgFn_Warp_ZMax ']' ];
    fprintf(fid, [FilesepRep(strANTSCmd) '\n']);
    
    
strMatlabCmd = ['export MCR_CACHE_ROOT=' strMCR_Cache_root];
fprintf(fid, strMatlabCmd);
strMatlabCmd = [strExt_2D_3DFn ' ' strImg_Warp_prefix_ZMax '0GenericAffine.mat ' strMatFn_Init];
fprintf(fid, [FilesepRep(strMatlabCmd) '\n']);
strMatlabCmd =  ['rm -rf ' strMCR_Cache_root];
fprintf(fid, strMatlabCmd);

strANTSCmd = [strANTSCmdFn ' -v ' strVerb ' -d 3 -r [' strMatFn_Init '] \\\n'...
    '-m MI[' strImgFn_Ref  ',' strImgFn_Mov ',1,32] \\\n'...
    '-t Translation[0.1] -c [10000x10000x10000x10000x10000,1.e-7,20] -s 3x2x1x0x0vox -f 16x8x4x2x1 \\\n' ...
    '-m MI[' strImgFn_Ref  ',' strImgFn_Mov ',1,32] \\\n'...
    '-t Rigid[0.1] -c [10000x10000x10000x10000x10000,1.e-7,20] -s 3x2x1x0x0vox -f 16x8x4x2x1 \\\n' ...
    '-m MI[' strImgFn_Ref  ',' strImgFn_Mov ',1,32] \\\n'...
    '-t Affine[0.1] -c [10000x10000x10000x10000x10000,1.e-7,20] -s 3x2x1x0x0vox -f 16x8x4x2x1 \\\n' ...
    '-m CC[' strImgFn_Ref  ',' strImgFn_Mov ',1,8] \\\n'...
    '-t SyN[0.2,3.0,0] -c [120x90x60x30x15] -s 3x2x1x0x0vox -f 16x8x4x2x1 \\\n'...
    '-n BSpline -o [' strImg_Warp_prefix ',' strImgFn_Warp ']' ];
    fprintf(fid, [FilesepRep(strANTSCmd) '\n']);

%fprintf(fid,'ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ORIGINALNUMBEROFTHREADS\nexport ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS\n');

fclose(fid);
strClusterCmd =['chmod 755 ' strScriptFn];
system(strClusterCmd);
if(bClusterOE)
     strFn_O = [strDir_ImgWarp '/' strFn_Mov '.o'];
     strFn_E = [strDir_ImgWarp '/' strFn_Mov '.e'];
else
     strFn_O = '/dev/null';
     strFn_E = '/dev/null';
end
strClusterCmd = ['bsub -n ' num2str(nThreads) ' -R"affinity[core(1)]" -J ' strFn_Mov ' -o ' strFn_O ' -e ' strFn_E ' ' strScriptFn];

if(~bGenRefZMax)
    n = 0;
    while(~exist(strImgFn_Ref_ZMax,'file'))
        pause(1);
        n = n+1;
        if(n==300)
            warning('Return by No Ref ZMax file can be used');
            return;
        end
    end
end
% disp(strClusterCmd);
system(strClusterCmd);
% system([strScriptFn ' > ' strImg_Warp_prefix '.log']) ;