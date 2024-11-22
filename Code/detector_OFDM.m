function estBits = detector_OFDM(rxData, H, nTx, symbolOrder, FFTsize, overFac, SNRdB,SC)
    numSubcarriers = FFTsize/overFac;
    % H = reshape(squeeze(H),nTx,[]);
    % rxDataEq = rxData./H;                          % ZF 均衡
    % var = 10^(-SNRdB/10);
    % rxDataEq = conj(H).*rxData./(conj(H).*H+var);  % MMSE 均衡
    
    rxDataEq = rxData;
    deMap = [rxDataEq(:,1:numSubcarriers/2) rxDataEq(:,end-numSubcarriers/2+1:end)]; 
    if SC==1
    deMap = ifft(deMap,[],2).*sqrt(length(deMap));
    end
    estBits = qamdemod(deMap, 2^symbolOrder, 'OutputType', 'bit', 'UnitAveragePower', true);
    estBits = reshape(estBits,1,length(estBits(:)));
    
    % numSubcarriers = FFT_Size/overFac;
    % deMap=[rxData(:,1:numSubcarriers/2) rxData(:,end-numSubcarriers/2+1:end)]; % baseband data
    % H(:,:,numSubcarriers/2+1:end-numSubcarriers/2) = [];
    % estBits = zeros(1,nTx*numSubcarriers*symbolOrder);
    % bits = de2bi(0:2^(nTx*symbolOrder)-1, 'left-msb')';
    % symbols = qammod(bits(:), 2^symbolOrder, 'InputType', 'bit', 'UnitAveragePower', true);
    % map = reshape(symbols,nTx,[]);
    % for iSubcarrier=1:numSubcarriers
    %     H_i = H(:,:,iSubcarrier);  %获得第i个子载波上的信道信息
    %     rxData_i = deMap(:,iSubcarrier);
    %     dist = sum(abs(rxData_i - H_i*map).^2,1);
    %     [~, index] = min(dist);%找出其中距离的最小值
    %     estBits(1,(iSubcarrier-1)*nTx*symbolOrder+1:iSubcarrier*nTx*symbolOrder) = bits(:,index).';  % detected bits 得到检测比特  
end

