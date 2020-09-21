clear
clc
addpath(genpath('JPEG_Toolbox'));
addpath(genpath('E:\MATLABR2016bworkspace\data set\g512\'));
filePath = 'E:\MATLABR2016bworkspace\data set\g512\';%ͼ��·��
imgPathList = dir(strcat(filePath,'\*.pgm'));% ��ȡ����pgmͼ��
imgNum = length(imgPathList);% ��ȡpgmͼ������
dbstop if error
tic
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
result = cell(imgNum,1);
payload_length = length(payload);
psnr_sum = zeros(1,payload_length);  %����ͼ��ĳһQF�µ�PSNR��ֵ
filesize_sum = zeros(1,payload_length); %����ͼ��ĳһQF�µ�FSE��ֵ
ssim_sum = zeros(1,payload_length); %����ͼ��ĳһQF�µ�SSIM��ֵ
sum_imgNum = imgNum;  %��¼����ѡ�����payload��ͼ��ĸ���
for kkk = 1:imgNum
filename = imgPathList(kkk).name;
imwrite(uint8(imread(filename)),strcat('name',num2str(QF),'.jpg'),'jpg','quality',QF);      %�ڵ�ǰQF��ѹ��
filename1=strcat('name',num2str(QF),'.jpg');
%% ����JPEG�ļ�
ORIGINAL = filename1;
jpeg_info = jpeg_read(ORIGINAL);%����JPEGͼ��
ori_jpeg = imread(ORIGINAL);%��ȡԭʼjpegͼ��
quant_tables = jpeg_info.quant_tables{1,1};%��ȡ������
dct_coef = jpeg_info.coef_arrays{1,1};%��ȡdctϵ��
S = getsignal(dct_coef);
R=getpayload_HS(S);
sum_R = sum(R(:));
%% 
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
[add,psnring]=getadd_psnr_HS(S,R,jpeg_info);  %��ȡǶ�����
[M,N] = size(S);
%%
E1=reshape(add,M*N,1);
D1=reshape(psnring,M*N,1);
E = E1'; %ת��Ϊһ�С�
E = mapminmax(E, 0, 1); % ��һ����
E = reshape(E, size(E1)); %
D = D1'; %ת��Ϊһ�С�
D = mapminmax(D, 0, 1); % ��һ����
D = reshape(D, size(D1)); %
R=reshape(R,M*N,1);
filesize_propose = zeros(1,payload_length);
psnr_propose = zeros(1,payload_length);
ssim_propose = zeros(1,payload_length);
FSE_each = zeros(1,payload_length);
for k = 1:payload_length %
    carry = payload(k);
    rand('seed',9);Data = randi([0,1],1,carry); %������ɵ�01������Ϊ������Ϣ
    C=carry;

    [x1,g1] = intlinprog(E',1:M*N,-R',-C,[],[],zeros(M*N,1),ones(M*N,1)); %�������FSE
    disp('��Ŀ��');
    A = [-R';E'];
    alpha = 1;
    g = g1 + abs(alpha*g1);
    b = [-C;g];
    x=intlinprog(D',1:M*N,A,b,[],[],zeros(M*N,1),ones(M*N,1)); %��Ŀ��������߱�����������FSEʱ������PSNR��Ӧ�ľ��߱���
    %xΪѡ����Щ������������
    x=uint8(reshape(x,M,N));
    %%
    %Ƕ��
    [S_stego] = jpeg_emdding_HS(Data,S,x);
    %%
    %�õ�����ͼ��
    stego_dct=cell2mat(S_stego);
    stego_jpeg_info = jpeg_info;
    stego_jpeg_info.coef_arrays{1,1} = stego_dct;   %�޸ĺ��DCTϵ����д��JPEG��Ϣ
    filenamestego = strcat(filename,'_',num2str(carry));
    STEGO=['Stego\QF' num2str(QF) '\',filenamestego,'.jpg'];
    jpeg_write(stego_jpeg_info,STEGO);    %��������jpegͼ�񣬸��ݽ�����Ϣ���ع�JPEGͼ�񣬻������ͼ��
    
    %% �����ļ����Ͷ���PSNR,SSIM
    fid=fopen(STEGO,'rb');
    bit1=fread(fid,'ubit1');
    fclose(fid);
    fid=fopen(ORIGINAL,'rb');
    bit2=fread(fid,'ubit1');
    fclose(fid);
    ZZ = (length(bit1) - length(bit2));
    I_stego = imread(STEGO);
    psnr_propose(k) = psnr(ori_jpeg,I_stego);
    ssim_propose(k) = SSIM(ori_jpeg,I_stego);
    FSE_each(1,k) = ZZ;
    filesize_propose(k) = ZZ/length(bit2)*100;
    
    %% �жϻָ��Ƿ���ȷ
%     %��ȡ
%     [S_re,exD] = jpeg_extract(S_stego,x,carry);
%     jpeg_re = jpeg_info;
%     jpeg_re.coef_arrays{1,1} = cell2mat(S_re);
%     jpeg_write(jpeg_re,'jpeg_re.jpg');%����ָ�jpegͼ��
%     I_re = imread('jpeg_re.jpg');
%     psnr_re = psnr(ori_jpeg,I_re);
%     a = isequal(Data,exD);
%     if a == 1 && psnr_re == -1
%         disp(['��',num2str(k),'����ȡ��ȷ�һָ���ȷ']);
%     end
    
end
FSE_each(1,k+1) = length(bit2);%���һ�����ԭʼ�ļ���С
PSNR_each = psnr_propose;
SSIM_each = ssim_propose;
psnr_sum = psnr_sum + psnr_propose;
filesize_sum = filesize_sum + filesize_propose;
ssim_sum = ssim_sum + ssim_propose;
r.name = filename;
r.psnr = PSNR_each;
r.ssim = SSIM_each;
r.FSE = FSE_each;
result{kkk} = r;
end
psnr_ave = psnr_sum/sum_imgNum;
filesize_ave = filesize_sum/sum_imgNum;
ssim_ave = ssim_sum/sum_imgNum;
%�������ݷ���ave
save(['ave\payload_', num2str(QF), '.mat'],'payload');
save(['ave\psnr_', num2str(QF), '.mat'],'psnr_ave');
save(['ave\filesize_', num2str(QF), '.mat'],'filesize_ave');
save(['ave\ssim_', num2str(QF), '.mat'],'ssim_ave');

%ÿ����ʵ����Ҳ�ŵ�ave_g512��
save(['ave\result_each', num2str(QF), '.mat'],'result');
end
toc