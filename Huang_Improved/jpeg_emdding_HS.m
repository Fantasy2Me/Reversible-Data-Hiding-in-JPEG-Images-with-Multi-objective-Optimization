 function [S_stego] = jpeg_emdding_HS(Data,S,x)
 [m,n] = size(S);
payload = length(Data);
%ѡ�����Щ����Ƕ��󣬿�ʼǶ���㷨
numData = 1;
for i = 1:m
    if numData > payload
        break;
    end
    for j = 1:n
        if numData > payload
            break;
        end
        if x(i,j) == 1
        a = S{i,j}(1,1);
        S{i,j}(1,1) = 0;
        for ii = 1:8
            if numData > payload
                break;
            end
            for jj = 1:8
                if numData > payload
                    break;
                end
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
        end
    end
end
S_stego = S;

end