clear;
clc;
addpath JPEG_Toolbox\;
addpath(genpath('E:\MATLABR2016bworkspace\data set\g512\'));
filePath = 'E:\MATLABR2016bworkspace\data set\g512\';%UCIDͼ���·��
imgPathList = dir(strcat(filePath,'\*.pgm'));% ��ȡ����pgmͼ��
imgNum = length(imgPathList);% ��ȡpgmͼ������
for QF = 30:20:90
    %����payload����
if QF == 30
    payload = 2000:1000:9000;
elseif QF == 50
    payload = 2000:2000:14000;
elseif QF == 70
    payload = 2000:2000:18000;
elseif QF == 90
    payload = 2000:4000:30000;
end
payload_length = length(payload);
psnr_sum = zeros(1,payload_length);
filesize_sum = zeros(1,payload_length);
ssim_sum = zeros(1,payload_length);
sum_imgNum = imgNum;
result = cell(imgNum,1);
for kkk = 1:imgNum
    filename = imgPathList(kkk).name;
imwrite(uint8(imread(filename)),strcat('name',num2str(QF),'.jpg'),'jpg','quality',QF);      %�ڵ�ǰQF��ѹ��
filename1=strcat('name',num2str(QF),'.jpg');
ORIGINAL = filename1;
jpeg_info = jpeg_read(ORIGINAL);%����JPEGͼ��
ori_jpeg = imread(ORIGINAL);%��ȡԭʼjpegͼ��
quant_tables = jpeg_info.quant_tables{1,1}; %��ȡ������
oridct = jpeg_info.coef_arrays{1,1};  %��ȡdctϵ��
sum_R = sum_payload(oridct);
if QF == 30 && sum_R < 9000
    sum_imgNum = sum_imgNum - 1;
    continue;
elseif QF == 50 && sum_R < 14000
    sum_imgNum = sum_imgNum - 1;
    continue;
elseif QF == 70 && sum_R < 18000
    sum_imgNum = sum_imgNum - 1;
    continue;
elseif QF == 90 && sum_R < 30000
    sum_imgNum = sum_imgNum - 1;
    continue;
end
[M,N] = size(oridct);
oriBlockdct = mat2cell(oridct,8 * ones(1,M/8),8 * ones(1,N/8)); %��ԭ����ͼ�����ָ��N��8*8��Block
[M,N] = size(oriBlockdct);
[zeronum] = Getzeronum(oriBlockdct);
psnr_Huang = zeros(1,payload_length);
filesize_Huang = zeros(1,payload_length);
ssim_Huang = zeros(1,payload_length);
FSE_each = zeros(1,payload_length+1);
cnt1=1;
for k = 1:payload_length %
nn = payload(k);
rng(100,'twister');
data = round(rand(1,nn)*1);%�������01���أ���ΪǶ�������
%Ƕ�뺯��
[jpeg_info_stego] = jpeg_emdding(data,oriBlockdct,jpeg_info,nn,zeronum); 
filenamestego = strcat(filename,'_',num2str(nn));
STEGO=['Stego\QF' num2str(QF) '\',filenamestego,'.jpg'];
jpeg_write(jpeg_info_stego,STEGO);    %��������jpegͼ�񣬸��ݽ�����Ϣ���ع�JPEGͼ�񣬻������ͼ��

%% ��ȡ��Ϣ
% [re_jpeg_info,extData] = jpeg_extract(jpeg_info_stego,nn,zeronum);
% jpeg_write(re_jpeg_info,'re.jpg');%����ͼ�񣬸��ݽ�����Ϣ���ع�JPEGͼ��
% re_jpeg = imread('re.jpg');%��ȡ����jpegͼ��
% a = isequal(extData,data);
% %��ȡPSNR���ļ�����
% a_psnr_H=psnr(ori_jpeg,re_jpeg);
% if a == 1 && a_psnr_H == -1
%     disp('success');
% end
stego_jpeg = imread(STEGO);%��ȡ����jpegͼ��
psnr_Huang(k)=psnr(ori_jpeg,stego_jpeg);
ssim_Huang(k) = SSIM(ori_jpeg,stego_jpeg);
fid=fopen(STEGO,'rb');
bit1=fread(fid,'ubit1');
fclose(fid);
fid=fopen(ORIGINAL,'rb');
bit2=fread(fid,'ubit1');
fclose(fid);
ZZ = (length(bit1)-length(bit2));
FSE_each(1,k) = ZZ;
filesize_Huang(k) = ZZ/length(bit2)*100;
end
FSE_each(1,k+1) = length(bit2);%���һ�����ԭʼ�ļ���С
PSNR_each = psnr_Huang;
SSIM_each = ssim_Huang;
psnr_sum = psnr_sum + psnr_Huang;
filesize_sum = filesize_sum + filesize_Huang;
ssim_sum = ssim_sum + ssim_Huang;
x.name = filename;
x.psnr = PSNR_each;
x.ssim = SSIM_each;
x.FSE = FSE_each;
result{kkk} = x;
end
ave_psnr = psnr_sum/sum_imgNum;
ave_filesize = filesize_sum/sum_imgNum;
ssim_ave = ssim_sum/sum_imgNum;

%�������ݷ���ave
save(['ave\payload_', num2str(QF), '.mat'],'payload');
save(['ave\psnr_', num2str(QF), '.mat'],'ave_psnr');
save(['ave\filesize_', num2str(QF), '.mat'],'ave_filesize');
save(['ave\ssim_', num2str(QF), '.mat'],'ssim_ave');

%ÿ����ʵ����Ҳ�ŵ�ave_ucid��
save(['ave\result_each', num2str(QF), '.mat'],'result');
end