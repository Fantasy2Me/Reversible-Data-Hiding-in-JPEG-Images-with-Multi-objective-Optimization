function [best,FSE]=synthesize(filename,jobj,payload,ORIGINAL,QF)  %ѡ��ͼƬ
addpath jpegread\;%
addpath utils\;
dct=jobj.coef_arrays{1};                           %��dctϵ�� 
Q_table=jobj.quant_tables{1};              %����������и�ֵ
J = imread(ORIGINAL);%��ȡԭʼjpegͼ��
FSE = zeros(1,length(payload)+1);
best = zeros(4,length(payload));
%%%%%%%%%%%%%%%%%%��ͬǶ�������µ�ֵ%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(payload)
    %�ڵ�ǰQF�µ�JPEGͼǶ�벻ͬ����Ϣ��
messLen = payload(k);
embed_bit=round(rand(1,messLen));  %��ǰmesslen���������Ƕ�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%����ѡ��Ƕ��ϵ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PSNR=zeros(1,64);
INCRE=zeros(1,64);
Q_cost=costFun(Q_table);            %���������ÿ�����ӷ��ص������п��������ز�����Ӱ��  
bin63=get63bin(dct);          %���г��ÿ��DCT����ijλ�õ�ϵ��Ϊһ�У���ͬλ��Ϊһ���γɾ���
[outbin63,capacity63,unitdistortion63]=getuintcost63bin(bin63,Q_cost);
[unitdistortion63,sort_index]=sort(unitdistortion63);        %��ʧ�������������õĿ�ϵ����sort_index
max_psnr = 0;
for selnum=12:3:3*floor(length(sort_index)/3)                %%��������selnum������psnrѰ����ѵĿ�Ƕ������K
    sel_index=sort_index(1:selnum);
    M=matrix_index(sel_index);                 %������Ǿ���M
    DCT=mark(M,dct);                          %û���⣬����ѡ��ϵ�����DCT��%%%
%%%%%%%%%%%%%%ģ���޸�ͼƬ����Ƕ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
simulate_dct=simulate(DCT);         %ģ���޸ĺ��ͼƬ������simulate_dct
counter_1=countDCT(DCT,1);
counter_0=countDCT(DCT,0);
[counter_0,sort_0]=sort(counter_0);        
table=jobj.quant_tables{1};
[order,vd_distor]=select_block2(simulate_dct,DCT,table,counter_1);   %����ģ���޸ĵķ���̰���㷨��ʧ���С������һ��Ƕ��ͼƬ������,��������ʧ������
%%%%%%%%%%%%%%%%%%%%%%%%����Ƕ�����У�����ϢǶ��ͼƬ%%%%%%%%%%%%%%%%%%%%%%
for r=1:length(order)                                    %Ѱ��Ƕ���ٽ�ֵ
     if (sum(counter_1(order(1:r)))>=messLen)            %��ÿ������1����Ŀ
         order=order(1:r);
         sort_0=sort_0(1:r);        
         break;
     end
end
[stego1_dct,tag]=generate_stego(order,DCT,embed_bit,messLen);       %����Ƕ���DCTϵ��
if tag==1
    continue;
end
stego_dct=recoverstego(dct,stego1_dct,sel_index);         %�ָ�����ϵ��
%%%%%%%%%%%%%%%%%%%%%%%%%%�����������stego.dct����Ƕ��ͼƬ%%%%%%%%%%%%%%%%%%%%%%%
jobj.coef_arrays{1} = stego_dct;
jpeg_write(jobj,'stego.jpg');
 %% %%%&%%%%%%%%%%%%%%%%%%%%%%%%%����ʧ�����������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 II=imread('stego.jpg');
 psnr_goad=appraise(II,J);
 ssim_goad = SSIM(II,J);
 fid=fopen('stego.jpg','rb');
 bit1=fread(fid,'ubit1');
 fclose(fid);
 fid=fopen(ORIGINAL,'rb');
 bit2=fread(fid,'ubit1');
 fclose(fid);
 incre_bit=(length(bit1)-length(bit2));
 if max_psnr < psnr_goad
     max_psnr = psnr_goad;
     ssim_hou = ssim_goad;
     jobjj = jobj;
 end
    %%
    PSNR(selnum)=psnr_goad;
    INCRE(selnum)=incre_bit;
end
[best_psnr,index]=max(PSNR);                            %�ҵ���õ�psnr
best_incre=INCRE(index)/length(bit2)*100;                               %�ҵ���õ�incre_bit
filenamestego = strcat(filename,'_',num2str(messLen));
STEGO=['Stego_g512\QF' num2str(QF) '\',filenamestego,'.jpg'];
jpeg_write(jobjj,STEGO);
best(:,k)=[messLen,best_psnr,ssim_hou,best_incre];
FSE(k) = INCRE(index);
end
 FSE(k+1) = length(bit2);%���һ�����ԭʼ�ļ���С
end