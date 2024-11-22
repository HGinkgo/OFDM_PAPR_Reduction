function txSymbols = Power_normalization(txDataTDCP)
% 此函数用于信号功率归一
    Signal_Power = abs(txDataTDCP);
    msv = mean(Signal_Power.^2);
    txSymbols = txDataTDCP / sqrt(msv);                                  
end

