 function payload = getpayload_HS(S)
 [m,n] = size(S);
 payload=zeros(m,n);
 for i=1:m
    for j=1:n
        payload(i,j)=sum(sum(abs(S{i,j})==1)); %�˿���Ϊ1�ĸ���
%         payload(i,j)=sum(S{i,j}(:)~=0); %�˿��в�Ϊ0�ĸ���        
        if abs(S{i,j}(1,1))==1
            payload(i,j)=payload(i,j)-1;
        end
    end
 end
        