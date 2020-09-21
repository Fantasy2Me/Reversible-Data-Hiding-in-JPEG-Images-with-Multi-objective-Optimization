function [best,FSE]=synthesize(filename,jobj,payload,ORIGINAL,QF)  %ѡ��ͼƬ
addpath jpegread\;
dct=jobj.coef_arrays{1};                           %��dctϵ�� 
Q_table=jobj.quant_tables{1};              %����������и�ֵ
J = imread(ORIGINAL);%��ȡԭʼjpegͼ��
FSE = zeros(1,length(payload)+1);
best = zeros(4,length(payload));
%%%%%%%%%%%%%%%%%%��ͬǶ�������µ�ֵ%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:1
%�ڵ�ǰQF�µ�JPEGͼǶ�벻ͬ����Ϣ��
carry = payload(k);
embed_bit=round(rand(1,carry));  %��ǰmesslen���������Ƕ�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%����ѡ��Ƕ��ϵ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PSNR=zeros(1,64);
INCRE=zeros(1,64);
Q_cost=costFun(Q_table);            %���������ÿ�����ӷ��ص������п��������ز�����Ӱ��  
bin63=get63bin(dct);          %���г��ÿ��DCT����ijλ�õ�ϵ��Ϊһ�У���ͬλ��Ϊһ���γɾ���
[outbin63,capacity63,unitdistortion63]=getuintcost63bin(bin63,Q_cost);
[unitdistortion63,sort_index]=sort(unitdistortion63);        %��ʧ�������������õĿ�ϵ����sort_index
for selnum=12:3:3*floor(length(sort_index)/3)                %%��������selnum������psnrѰ����ѵĿ�Ƕ������K
    sel_index=sort_index(1:selnum);
    M=matrix_index(sel_index);                 %������Ǿ���M
    DCT=mark(M,dct);                          %û���⣬����ѡ��ϵ�����DCT��%%%
sum_R = sum_payload(DCT);
if sum_R < carry
    continue;
end
    %%%%%%%%%%%%%%ģ���޸�ͼƬ����Ƕ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
simulate_dct=simulate(DCT);         %ģ���޸ĺ��ͼƬ������simulate_dct
counter_1=countDCT(DCT,1);
counter_0=countDCT(DCT,0);
[counter_0,sort_0]=sort(counter_0);        
table=jobj.quant_tables{1};
[order,vd_distor]=select_block2(simulate_dct,DCT,table,counter_1);   %����ģ���޸ĵķ���̰���㷨��ʧ���С������һ��Ƕ��ͼƬ������,��������ʧ������
%%%%%%%%%%%%%%%%%%%%%%%%����Ƕ�����У�����ϢǶ��ͼƬ%%%%%%%%%%%%%%%%%%%%%%
for r=1:length(order)                                    %Ѱ��Ƕ���ٽ�ֵ
     if (sum(counter_1(order(1:r)))>=carry)            %��ÿ������1����Ŀ
         order=order(1:r);
         sort_0=sort_0(1:r);        
         break;
     end
end
[stego1_dct,tag]=generate_stego(order,DCT,embed_bit,carry);       %����Ƕ���DCTϵ��
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
 fid=fopen('stego.jpg','rb');
 bit1=fread(fid,'ubit1');
 fclose(fid);
 fid=fopen(ORIGINAL,'rb');
 bit2=fread(fid,'ubit1');
 fclose(fid);
 incre_bit=length(bit1)-length(bit2);
 
 %%
 PSNR(selnum)=psnr_goad;
 INCRE(selnum)=incre_bit;
end %�ҵ�����K

[best_psnr,index]=max(PSNR);                            %�ҵ���õ�psnr
%% �����������ҵ�����K
sel_index=sort_index(1:index);
M=matrix_index(sel_index);                 %������Ǿ���M
DCT=mark(M,dct);                          %��ʱƵ��λ��ȷ��֮���DCT��Ϊ�����ź�%%%

    %%%%%%%%%%%%%%ģ���޸�ͼƬ����Ƕ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
simulate_dct=simulate(DCT);         %ģ���޸ĺ��ͼƬ������simulate_dct    
[M,N] = size(DCT);
ori_Blockdct = mat2cell(DCT,8 * ones(1,M/8),8 * ones(1,N/8));%��ԭ����ͼ�����ָ��N��8*8��Block
simulate_Blockdct = mat2cell(simulate_dct,8 * ones(1,M/8),8 * ones(1,N/8));%��ģ��Ƕ���ͼ�����ָ��N��8*8��Block
dct_block = mat2cell(dct,8 * ones(1,M/8),8 * ones(1,N/8));
[ simulate_Blockdct ] = stego( simulate_Blockdct,dct_block,sel_index ); %�ָ�����ϵ��

[add,psnring]=get_psnring(simulate_Blockdct,dct_block,jobj);   %��ȡǶ�����
R=getpayload(ori_Blockdct);
[M,N] = size(ori_Blockdct);
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
C=carry;

[x1,g1] = intlinprog(E',1:M*N,-R',-C,[],[],zeros(M*N,1),ones(M*N,1));%�������FSE
disp('��Ŀ��');
A = [-R';E'];
alpha = 1;  %Ȩ��ֵ
g = g1 + abs(alpha*g1);
b = [-C;g];
x=intlinprog(D',1:M*N,A,b,[],[],zeros(M*N,1),ones(M*N,1)); %��Ŀ��������߱�����������FSEʱ������PSNR��Ӧ�ľ��߱���
%xΪѡ����Щ������������
x=uint8(reshape(x,M,N));
%%%%%%%%%%%%%%%%%%%%%%%%����Ƕ�����У�����ϢǶ��ͼƬ%%%%%%%%%%%%%%%%%%%%%%
[stego1_dct]=jpeg_emdding(embed_bit,ori_Blockdct,x);       %����Ƕ���DCTϵ��
[M,N] = size(dct);
dct_block = mat2cell(dct,8 * ones(1,M/8),8 * ones(1,N/8));
[ stego_dct ] = stego( stego1_dct,dct_block,sel_index ); %�ָ�����ϵ��
%%%%%%%%%%%%%%%%%%%%%%%%%%�����������stego.dct����Ƕ��ͼƬ%%%%%%%%%%%%%%%%%%%%%%%
jobj.coef_arrays{1} = cell2mat(stego_dct);      
filenamestego = strcat(filename,'_',num2str(carry));
STEGO=['Stego\QF' num2str(QF) '\',filenamestego,'.jpg'];
jpeg_write(jobj,STEGO);
 %% %%%&%%%%%%%%%%%%%%%%%%%%%%%%%����ʧ�����������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 II=imread(STEGO);
 psnr_goad=appraise(II,J);
 ssim_goad = SSIM(II,J);
 fid=fopen(STEGO,'rb');
 bit1=fread(fid,'ubit1');
 fclose(fid);
 fid=fopen(ORIGINAL,'rb');
 bit2=fread(fid,'ubit1');
 fclose(fid);
 ZZ = (length(bit1)-length(bit2));
 incre_bit=ZZ/length(bit2)*100;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 best(:,k)=[carry,psnr_goad,ssim_goad,incre_bit];
 FSE(k) = ZZ;
end                %%%����payloadǶ�����
 FSE(k+1) = length(bit2);%���һ�����ԭʼ�ļ���С