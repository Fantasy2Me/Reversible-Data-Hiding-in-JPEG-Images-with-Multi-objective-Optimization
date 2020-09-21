function [psnrTable,increaseTable] = process(name,QF)
addpath JPEG_Toolbox\;
addpath img\;

imwrite(imread(name),'ori.jpg','jpeg','quality',QF); %����QFΪXX��ori.jpg
ori_jpeg_info = jpeg_read('ori.jpg');%����JPEGͼ��
oridct = ori_jpeg_info.coef_arrays{1,1}; %��ȡdctϵ��
maxlen = length(find(oridct==1)) + length(find(oridct==-1))-500; %��ȡ���Ƕ�볤��

if QF==20
    sss=1000;
    eee=min(maxlen,10000);
elseif QF==40
    sss=1000;
    eee=min(maxlen,12000);
elseif QF==60
    sss=2000;
    eee=min(maxlen,20000);
else
    sss=2000;
    eee=min(maxlen,24000);
end
    

cnt1=1;
for nn=sss:sss:eee
rng(100,'twister');
data = round(rand(1,nn)*1);%�������01���أ���ΪǶ�������
payload = nn; %Ƕ���������Ʊ���

imwrite(imread(name),'ori.jpg','jpeg','quality',QF);
jpeg_info = jpeg_read('ori.jpg');
quant_tables = jpeg_info.quant_tables{1,1}; %��ȡ������
oridct = jpeg_info.coef_arrays{1,1};  %��ȡdctϵ��
oriBlockdct = mat2cell(oridct,8 * ones(1,512/8),8 * ones(1,512/8)); %��ԭ����ͼ�����ָ��N��8*8��Block

[zeronum] = Getzeronum(oriBlockdct);

%Ƕ�뺯��
[emdData,numData,jpeg_info_stego] = jpeg_emdding(data,oriBlockdct,jpeg_info,payload,zeronum); 

jpeg_write(jpeg_info_stego,'stego.jpg');%��������jpegͼ�񣬸��ݽ�����Ϣ���ع�JPEGͼ��

%��ȡPSNR���ļ�����
ori_jpeg = imread('ori.jpg');%��ȡԭʼjpegͼ��
stego_jpeg = imread('stego.jpg');%��ȡ����jpegͼ��
psnrTable(cnt1)=psnr(ori_jpeg,stego_jpeg);

fid=fopen('stego.jpg','rb');
bit1=fread(fid,'ubit1');
fclose(fid);
fid=fopen('ori.jpg','rb');
bit2=fread(fid,'ubit1');
fclose(fid);
increaseTable(cnt1) = length(bit1)-length(bit2);

cnt1=cnt1+1;
end
if cnt1==1
    psnrTable=[0,0];
    increaseTable=[0,0];
end
end