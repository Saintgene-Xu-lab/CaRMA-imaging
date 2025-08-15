function Cluster_Scripts_ApplyTrans_3d_v2(strImgFn, strImgFn_Ref, clFns_TMatrix, nThreads,bClusterOE)

if(nargin<4)
    nThreads=32;
end
if(nargin <5)
    bClusterOE = true; %output and error
end

global strDir_ANTS;

[strPath,strFn]=fileparts(strImgFn);
strANTSCmdFn = [strDir_ANTS filesep 'bin' filesep 'antsApplyTransforms'];
strImg_Warp_prefix = [strPath filesep strFn];
strImgFn_Warp = [strImg_Warp_prefix '_Reg.nii'];
strScriptFn = [strImg_Warp_prefix '_v2.sh'];

strCmd_TMatrix = clFns_TMatrix{1};

for n=2:length(clFns_TMatrix)
    strCmd_TMatrix = [strCmd_TMatrix ' ' clFns_TMatrix{n}]; %#ok<*AGROW>
end

if(bClusterOE)
    strVerb = '1';
else
    strVerb = '0';
end

fid = fopen(strScriptFn,'w');

fprintf(fid,'ORIGINALNUMBEROFTHREADS=${ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS}\n');
%fprintf(fid,'echo "ORIGINALNUMBEROFTHREADS=$ORIGINALNUMBEROFTHREADS"\n');
fprintf(fid,['ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=' num2str(nThreads) '\n']);
fprintf(fid,'export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS\n');
%fprintf(fid,'echo "ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS"\n');

strANTSCmd = [strANTSCmdFn ' -v ' strVerb ' -d 3 -i ' strImgFn ' -r ' strImgFn_Ref ' \\\n'...
    '-t ' strCmd_TMatrix ' \\\n'...
    '-n NearestNeighbor -o ' strImgFn_Warp];
    fprintf(fid, [FilesepRep(strANTSCmd) '\n']);

%fprintf(fid,'ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ORIGINALNUMBEROFTHREADS\nexport ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS\n');

fclose(fid);
strClusterCmd =['chmod 755 ' strScriptFn];
system(strClusterCmd);
if(bClusterOE)
     strFn_O = [strPath '/' strFn '.o'];
     strFn_E = [strPath '/' strFn '.e'];
else
     strFn_O = '/dev/null';
     strFn_E = '/dev/null';
end
strClusterCmd = ['bsub -n ' num2str(nThreads) ' -R"affinity[core(1)]" -J ' strFn ' -o ' strFn_O ' -e ' strFn_E ' ' strScriptFn];
% disp(strClusterCmd);
system(strClusterCmd);
% system([strScriptFn ' > ' strImg_Warp_prefix '.log']) ;