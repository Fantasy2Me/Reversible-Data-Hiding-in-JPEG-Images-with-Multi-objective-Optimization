function [add,Dis] = getadd_psnr_HS(S,R,jpeg_info)
Q = jpeg_info.quant_tables{1,1};%��ȡ������

[m,n] = size(S);
add = zeros(m,n);
Dis = zeros(m,n);
SS = S;
for i = 1:m
    for j = 1:n
        numData = 1;
        a = S{i,j}(1,1);
        Data = round(rand(1,R(i,j))*1);
        S{i,j}(1,1) = 0;
        for ii = 1:8
            for jj = 1:8
                 if S{i,j}(ii,jj) > 1
                      S{i,j}(ii,jj) = S{i,j}(ii,jj) + 1; %ƽ��
                 elseif S{i,j}(ii,jj) < -1 
                      S{i,j}(ii,jj) = S{i,j}(ii,jj) - 1; %ƽ��
                 elseif S{i,j}(ii,jj) == 1
                     S{i,j}(ii,jj) = S{i,j}(ii,jj) + Data(numData);
                     numData = numData + 1;
                 elseif S{i,j}(ii,jj) == -1
                     S{i,j}(ii,jj) = S{i,j}(ii,jj) - Data(numData);
                      numData = numData + 1;
                 end
            end
        end
        S{i,j}(1,1) = a;
        temp = (S{i,j}-SS{i,j}).*Q;
        pixel_d=IDCT(temp);                    %���任���򡪡����ز�
        Dis(i,j)=sum(sum(pixel_d.^2));    %���㵱ǰ��ʧ��
        %�ļ����Ͷȼ���
        size1 = getcodelength( S{i,j},jpeg_info );
     	size2 = getcodelength( SS{i,j},jpeg_info );
        if size2 == 0
        else
            add(i,j) = (size1 - size2);%
        end
    end
end
end