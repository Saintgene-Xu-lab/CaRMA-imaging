function Ext_2D_AffineTransform_3D(strFn_2D,strFn_3D)

load(strFn_2D);
strPath3D = fileparts(strFn_3D);
if(~isempty(strPath3D)&&~exist(strPath3D,'dir'))
    mkdir(strPath3D);
end

a=eye(3,4);
b=reshape(AffineTransform_double_2_2,[2,3]);
a([1 2],[1 2])=b(:,[1 2]);
a([1 2],4)=b(:,3);
T3D = a(:);
fid = fopen(strFn_3D,'w');
fprintf(fid,'#Insight Transform File V1.0\n#Transform 0\nTransform: AffineTransform_double_3_3\nParameters: ');
for n=1:length(T3D)-1
fprintf(fid,[num2str(T3D(n),'%.16f') ' ']);
end
fprintf(fid,[num2str(T3D(end),'%.16f') '\n']);
fprintf(fid,'FixedParameters: 0 0 0\n');
fclose(fid);

