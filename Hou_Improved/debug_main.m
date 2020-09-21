clear
clc
addpath jpegread\;
% addpath utils\;
dbstop if error  %���ִ����ʱ��������

addpath(genpath('E:\MATLABR2016bworkspace\data set\g512\'));
filePath = 'E:\MATLABR2016bworkspace\data set\g512\';%ͼ���·��
imgPathList = dir(strcat(filePath,'\*.pgm'));% ��ȡ������������ΪQF��jpgͼ��
imgNum = length(imgPathList);% ��ȡͼ������
for QF=30:20:90                 %ѡ��ͬ��QF���д���
    %����payload�Ĳ���
if QF == 30
    payload = 2000:1000:9000;
elseif QF == 50
    payload = 2000:2000:14000;
elseif QF == 70
    payload = 2000:2000:18000;
elseif QF == 90
    payload = 2000:4000:30000;
end
result = cell(imgNum,1);
payload_length = length(payload);
psnr_sum = zeros(1,payload_length);  %����ͼ��ĳһQF�µ�PSNR��ֵ
filesize_sum = zeros(1,payload_length);
ssim_sum = zeros(1,payload_length);
sum_imgNum = imgNum;    %��¼����ѡ�����payload��ͼ��ĸ���
for i=1:imgNum %ѡ��ÿһ��ͼƬ
filename = imgPathList(i).name;
imwrite(uint8(imread(filename)),strcat('name',num2str(QF),'.jpg'),'jpg','quality',QF);      %�ڵ�ǰQF��ѹ��
filename1=strcat('name',num2str(QF),'.jpg');
%% ����JPEG�ļ�
ORIGINAL = filename1;
jpeg_info = jpeg_read(ORIGINAL);%����JPEGͼ��
jobj = jpeg_info;
dct=jobj.coef_arrays{1};                           %��dctϵ�� 
sum_R = sum_payload(dct);
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
[best,FSE]=synthesize(filename,jobj,payload,ORIGINAL,QF);%ʵ������ѡ���Ƕ��
FSE_each = FSE;
PSNR_each = best(2,:);
SSIM_each = best(3,:);
psnr_sum = psnr_sum + best(2,:);
ssim_sum = ssim_sum + best(3,:);
filesize_sum = filesize_sum + best(4,:);
x.name = filename;
x.psnr = PSNR_each;
x.ssim = SSIM_each;
x.FSE = FSE_each;
result{i} = x;
end
psnr_ave = psnr_sum/sum_imgNum;
filesize_ave = filesize_sum/sum_imgNum;
ssim_ave = ssim_sum/sum_imgNum;
%�������ݷ���ave
save(['ave\payload_', num2str(QF), '.mat'],'payload');
save(['ave\psnr_', num2str(QF), '.mat'],'psnr_ave');
save(['ave\filesize_', num2str(QF), '.mat'],'filesize_ave');
save(['ave\ssim_', num2str(QF), '.mat'],'ssim_ave');

%ÿ����ʵ����Ҳ�ŵ�ave_ucid��
save(['ave\result_each', num2str(QF), '.mat'],'result');
end
poolobj = gcp('nocreate');
delete(poolobj);