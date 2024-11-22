function txsymbols = signal_compensation(rxData,rxDataNoise1, H, nTx, symbolOrder, FFTsize, overFac, SNRdB, SC ,SE)
%% 接收机设计，对损失信号进行补偿

    numSubcarriers = FFTsize/overFac;
    rxDataEq = rxData;
    deMap = [rxDataEq(:,1:numSubcarriers/2) rxDataEq(:,end-numSubcarriers/2+1:end)]; 
    if SC==1
    deMap = ifft(deMap,[],2).*sqrt(length(deMap));
    end
    estBits = qamdemod(deMap, 2^symbolOrder, 'OutputType', 'bit', 'UnitAveragePower', true);
    estBits = reshape(estBits,1,length(estBits(:)));

    modSymbols = qammod(estBits(:), 2^symbolOrder, 'InputType', 'bit', 'UnitAveragePower', true);
    txSymbols = reshape(modSymbols,nTx,[]);         % 初始传输信号

    %% IFFT 转为时域信号
    txDataFD = zeros(nTx,FFTsize);
    txDataFD(:,1:numSubcarriers/2) = txSymbols(:,1:numSubcarriers/2);
    txDataFD(:,end-numSubcarriers/2+1:end) = txSymbols(:,end-numSubcarriers/2+1:end);  %过采样
    txDataTD = ifft(txDataFD,[],2).*sqrt(FFTsize).*sqrt(overFac); 

    % if SE == 1
    %     u = 8;
    %     txDataTD_compand = u_law(txDataTD,u);
    % elseif SE == 2
    %     txDataTD_compand = TL(txDataTD);
    % elseif SE == 3
    %     txDataTD_compand = CNPC(txDataTD);
    % elseif SE == 4
    %     txDataTD_compand = method4(txDataTD);
    % end
    txDataTD_compand = TL(txDataTD);
    noise = txDataTD - txDataTD_compand;

    txsymbols = rxDataNoise1 + noise;
    rxDataNoise2 = fft(txsymbols,FFTsize,2)./(sqrt(FFTsize)*sqrt(overFac));
    H = reshape(squeeze(H),nTx,[]);
    txsymbols = rxDataNoise2./H;                 % ZF 均衡
end